# shipment-sync-prc-api — Migration Solution Design

> Scope: the `/outbound-deliveries/{deliveryNumber}` delivery-shipment sync flow only (SAP + Salesforce NA).
> Baselined on the legacy `na-delivery-shipment-prc-api` + notes. A migrated build was provided —
> per-finding Migration Status is folded into §6, and legacy-vs-migrated behavior is called out in §4.
> Companion Gap Analysis: `shipment-sync-prc-api-gap-analysis.md` (`Ref: GAP-shipment-sync-prc-api`).

---

## 1. Application Overview

| Title | Description |
|---|---|
| Application Technical Name | `shipment-sync-prc-api` (legacy baseline: `na-delivery-shipment-prc-api`) |
| Application Business Name | Shipment Sync Process API |
| Business Domain | Shipment |
| Available Versions | v1 (`1.0.0`) — legacy baseline was `1.0.0-SNAPSHOT` |
| Purpose of API | Event-driven process API that synchronizes outbound delivery/shipment details originating from Pitney Bowes to the SAP and Salesforce NA system APIs. It subscribes to Anypoint MQ, transforms each event into the downstream contract, and forwards it as a delivery-number–keyed update. |
| Mule Application Type | Process (prc) — asynchronous / event-driven (Anypoint MQ subscriber; no inbound business HTTP listener) |
| API Type | Internal process API (system-to-system integration; not externally exposed) |
| GitHub Repo URL | https://github.com/CFSW-E2E-Mulesoft/shipment-sync-prc-api |
| Healthcheck Endpoints | `GET /api/ping`, `GET /api/health-check` (present in migrated build; absent in legacy) |
| Exchange Specification URL | TBC |
| Monitoring Dashboard URL | TBC |
| API Manager URL | TBC |
| Runtime URLs | TBC (NA + EU CloudHub deployments; downstream host observed as `dev2.na.insuletintegrations.com`) |
| Postman Collection File | TBC |
| Properties Configured | MQ (`mq.url`, delivery-shipment SAP/SF queues, `mq.max.local.messages`); SAP sys API (`sap-shipment-sys-api.host/path/responsetimeout`); Salesforce NA sys API (`sf-shipment-sys-api.host/path/responsetimeout`); retry (`retry.attempts`, `retry.interval`); request timeouts; logger (`encryptionKey`, `sensitiveFields`, `safeKeys`); `mule-internal-app` client id/secret. Migrated: YAML (`config.yaml` + `config-{env}-na.yaml` + `config-{env}-eu.yaml`). Legacy: `.properties` per env (`dev/qa/uat/prod`). |
| Azure Vault Keys and Credentials Details | Migrated: Azure Key Vault (`Mule-DEV`) — `mule-internal` client id/secret, MQ client id/secret, `global-logger-encryption-key`. Legacy: **no vault** — inline AES-encrypted values in `.properties` + secure-properties module. |
| Depends on Mule Apps/APIs | `sap-shipment-sys-api` (SAP outbound-deliveries), `sf-na-sys-api` / `sf-shipment-sys-api` (Salesforce NA outbound-deliveries). Upstream producer: Pitney Bowes (via Anypoint MQ). |
| Insulet Connectors/Libraries Used | Anypoint MQ Connector; Custom Logger Connector (`module-logger`); Error Handler Plugin (`module-error-handler-plugin`); Azure Key Vault Properties Provider; Validation module; Tracing module. Legacy equivalent: `common-logging-error-handling-module`, secure-configuration-property module, scripting module, CloudHub connector. |
| Other Libraries and Connectors Used | HTTP Connector, Sockets Connector, TLS context. |
| API Manager Policies Applied | Client ID Enforcement (API-to-API automated policy) — TBC |
| Parent-POM | Migrated: `mule-common-pom:1.0.13`. Legacy: `com.mycompany:my-app:1` (non-standard). |

---

## 2. Non-Functional Requirements

| Type | Description |
|---|---|
| Authentication | Client ID / Client Secret enforcement between Mule apps (API Manager automated policy); downstream calls send `client_id` / `client_secret` headers. Exact policy config — TBC |
| Response Time | TBC (downstream response timeouts observed: SAP ~60s, Salesforce NA ~105s) |
| Number of transactions to be processed | TBC |
| Spike Control | TBC (MQ prefetch `maxLocalMessages = 1` throttles concurrent consumption) |
| Rate-Limiting SLA | TBC |

---

## 3. High-Level Architecture

```mermaid
flowchart LR
    PB["Pitney Bowes<br/>(shipment/delivery events)"] -->|publishes| MQ["Anypoint MQ<br/>pb-delivery-shipment-sap-mq<br/>pb-delivery-shipment-sf-mq"]
    MQ -->|subscribe (prefetch=1)| PRC["shipment-sync-prc-api<br/>Transform PB event → downstream<br/>delivery contract, keyed on deliveryNumber"]
    PRC --> DECIDE{"Target<br/>system?"}
    DECIDE -->|SAP queue| SAP["SAP Shipment System API<br/>PATCH /outbound-deliveries-na/{deliveryNumber}"]
    DECIDE -->|Salesforce queue| SF["Salesforce NA System API<br/>PATCH /outbound-deliveries/{deliveryNumber}"]
    PRC -.->|on failure| ERR["Error handling:<br/>retry then DLQ / alert notification"]
```

The API is fully asynchronous: each downstream target is fed by its own MQ queue, and a message is transformed into that target's delivery-update contract and PATCHed by delivery number. Cross-cutting request-context capture, correlation-ID propagation, and Custom Logger entry/exit logging apply to every flow and are described once per endpoint in §4 (not shown as diagram nodes).

---

## 4. Interface Specification

Because this is an event-driven process API, the "resource" is the MQ-triggered delivery-shipment sync operation rather than an inbound business HTTP endpoint. The downstream target contract is `PATCH /outbound-deliveries/{deliveryNumber}`.

**Resources**

| Resource Name | Supported Methods | Description |
|---|---|---|
| Delivery Shipment Sync → SAP (MQ: `pb-delivery-shipment-sap-mq`) | MQ Subscribe → downstream `PATCH /outbound-deliveries-na/{deliveryNumber}` | In scope. Sync outbound delivery/shipment details to the SAP system API. |
| Delivery Shipment Sync → Salesforce NA (MQ: `pb-delivery-shipment-sf-mq`) | MQ Subscribe → downstream `PATCH /outbound-deliveries/{deliveryNumber}` | In scope. Sync outbound delivery/shipment details to the Salesforce NA system API. |
| `GET /api/ping` | GET | In scope (platform). Liveliness probe. |
| `GET /api/health-check` | GET | In scope (platform). Readiness probe. |
| Proof of Delivery (MQ: `pb-pod-sap-mq` → `POST /api/pods`) | MQ Subscribe → downstream POST | Out of scope for Infinity scope |
| Pick & Ship notification | MQ Subscribe | Out of scope for Infinity scope |
| Returns | MQ Subscribe | Out of scope for Infinity scope |
| Goods Receipt | MQ Subscribe | Out of scope for Infinity scope |
| Inventory Status update | MQ Subscribe | Out of scope for Infinity scope |
| Shipment Status update | MQ Subscribe | Out of scope for Infinity scope |

---

### 4.1 Delivery Shipment Sync → SAP

Triggered by an Anypoint MQ message on the SAP delivery-shipment queue. `deliveryNumber`, `correlationId`, `entityId`, and `messageId` are carried as MQ message properties; the shipment details are the message body.

#### 4.1.1 Input

| Field | Type | Required? | Description |
|---|---|---|---|
| deliveryNumber | String | Yes | Delivery number (MQ property) used as the downstream URI path parameter. |
| correlationId | String | Yes | End-to-end tracing id (MQ property). |
| entityId | String | No | Business entity id for logging/tracing (MQ property). |
| salesOrderNumber | String | Yes | Sales order number. |
| distributionChannel | String | No | Distribution channel code. |
| packingSlipId | String | Yes | Packing slip identifier. |
| package | Array | Yes | One or more package/tracking entries. The first entry is used for the downstream fields below. |
| package[].trackingNumber | String | Yes | Carrier tracking number. |
| package[].carrierUsed | String | Yes | Carrier name. |
| package[].serviceUsed | String | Yes | Shipping service level. |
| package[].shippingCost | Number | No | Shipping cost for the package. |

Example event body:

```json
{
  "salesOrderNumber": "110002222",
  "distributionChannel": "11",
  "packingSlipId": "0080001254",
  "package": [
    { "trackingNumber": "TrackingNumber1", "carrierUsed": "FedEx", "serviceUsed": "Ground", "shippingCost": 13 },
    { "trackingNumber": "TrackingNumber2", "carrierUsed": "USPS", "serviceUsed": "Air", "shippingCost": 14 }
  ]
}
```

#### 4.1.2 Mapping (Source → Target → Transformation)

Cross-cutting (once per endpoint): on message receipt the flow captures request context (`correlationId`, `messageId`, `entityId`, source = `Pitney Bowes`, target = `SAP`, objectType) into a single context variable and emits Custom Logger entry/exit records; correlation id is propagated to the downstream call. These are not repeated per step below.

- **Step 0 — Consume & set context.** Subscribe to the SAP delivery-shipment MQ queue (prefetch = 1). Capture MQ properties and body into the request-context variable; log "request received".
- **Step 1 — Build SAP request payload.** Map the PB event to the SAP delivery-update contract (see mapping table). Log the masked/final SAP request.
- **Step 2 — Call SAP system API.** `PATCH /outbound-deliveries-na/{deliveryNumber}` via the shared outbound HTTP request flow, with `deliveryNumber` supplied as a URI parameter, correlation id forwarded, and connectivity retry (`until-successful`).
- **Step 3 — Complete.** On success, log "request processed"; on failure, route through the global error handler (retry-then-alert / DLQ).

| Source Field/Object | Target Field/Object | Transformation Logic | Notes |
|---|---|---|---|
| `deliveryNumber` (MQ property) | URI path `{deliveryNumber}` | Pass-through into the request URI | Keys the downstream delivery record |
| `salesOrderNumber` | `salesOrderNumber` | Pass-through | |
| `packingSlipId` | `packingSlipId` | Pass-through | |
| `package[0].trackingNumber` | `trackingNumber` | Take first package entry | Only the first package is mapped |
| `package[0].carrierUsed` | `carrierUsed` | Take first package entry | |
| `package[0].serviceUsed` | `serviceUsed` | Take first package entry | |
| `package[0].shippingCost` | `shippingCost` | Take first package entry | |
| context: source, region | `header.source`, `header.region` | Added by migrated build | **New in migrated** — legacy sent no `header` wrapper (see Functional Differences) |

#### 4.1.3 Output / Acknowledgement

As an event-driven flow there is no synchronous caller response; the acknowledgement is the successful downstream PATCH plus MQ ack. Downstream call status handling follows the PATCH profile:

| Method | Success | Client Errors | Server Error |
|---|---|---|---|
| PATCH | 200 | 400, 401 | 500 |

Add **502** when SAP returns its own error; add **503** (`APP:CONNECTIVITY_FAILED`) when the downstream connection fails after retries.

Success (downstream) example:

```json
{ "data": { "deliveryNumber": "0080001254", "status": "updated" } }
```

Fixed error-response format:

```json
{
  "correlationId": "a1b2c3d4-1234-5678-abcd-ef1234567890",
  "errorCode": "APP:CONNECTIVITY_FAILED",
  "description": "Delivery shipment sync to SAP could not be completed.",
  "errorDetails": [
    { "message": "Downstream system API returned an error.", "code": "HTTP:INTERNAL_SERVER_ERROR" }
  ]
}
```

---

### 4.2 Delivery Shipment Sync → Salesforce NA

Triggered by an Anypoint MQ message on the Salesforce delivery-shipment queue. Same MQ-property/body model as §4.1, with an additional `addressString` field and Salesforce-specific field names.

#### 4.2.1 Input

| Field | Type | Required? | Description |
|---|---|---|---|
| deliveryNumber | String | Yes | Delivery number (MQ property) used as the downstream URI path parameter. |
| correlationId | String | Yes | End-to-end tracing id (MQ property). |
| entityId | String | No | Business entity id for logging/tracing (MQ property). |
| salesOrderNumber | String | Yes | Sales order number. |
| packingSlipId | String | Yes | Packing slip identifier. |
| addressString | String | No | Delivery address string (Salesforce-only field). |
| package | Array | Yes | Package/tracking entries; the first entry is mapped downstream. |
| package[].trackingNumber | String | Yes | Carrier tracking number. |
| package[].carrierUsed | String | Yes | Carrier name. |
| package[].serviceUsed | String | Yes | Shipping service level. |
| package[].shippingCost | Number | No | Shipping cost for the package. |

Example event body:

```json
{
  "salesOrderNumber": "110002222",
  "packingSlipId": "0080001254",
  "addressString": "123 Main St, Acton, MA 01720",
  "package": [
    { "trackingNumber": "TrackingNumber1", "carrierUsed": "FedEx", "serviceUsed": "Ground", "shippingCost": 13 }
  ]
}
```

#### 4.2.2 Mapping (Source → Target → Transformation)

Cross-cutting (once per endpoint): request-context capture (source = `Pitney Bowes`, target = `Salesforce`), Custom Logger entry/exit, and correlation-id propagation apply as in §4.1.

- **Step 0 — Consume & set context.** Subscribe to the Salesforce delivery-shipment MQ queue (prefetch = 1). Capture MQ properties and body; log "request received".
- **Step 1 — Build Salesforce request payload.** Map the PB event to the Salesforce delivery-update contract (see table). Log the masked/final Salesforce request.
- **Step 2 — Call Salesforce NA system API.** `PATCH /outbound-deliveries/{deliveryNumber}` via the shared outbound HTTP request flow with `deliveryNumber` URI parameter, correlation id forwarded, and connectivity retry.
- **Step 3 — Complete.** On success, log "request processed"; on failure, route through the global error handler.

| Source Field/Object | Target Field/Object | Transformation Logic | Notes |
|---|---|---|---|
| `deliveryNumber` (MQ property) | URI path `{deliveryNumber}` | Pass-through into the request URI | Keys the downstream delivery record |
| `salesOrderNumber` | `salesOrderNr` | Rename to Salesforce field name | Field name differs from SAP mapping |
| `packingSlipId` | `packingSlipId` | Pass-through | |
| `package[0].trackingNumber` | `trackingId` | Take first package entry; rename | |
| `package[0].carrierUsed` | `carrierName` | Take first package entry; rename | |
| `package[0].serviceUsed` | `serviceUsed` | Take first package entry | |
| `package[0].shippingCost` | `shippingCost` | Take first package entry | |
| `addressString` | `addressString` | Pass-through | Salesforce-only field |
| context: source, region | `header.source`, `header.region` | Added by migrated build | **New in migrated** — legacy sent no `header` wrapper |

#### 4.2.3 Output / Acknowledgement

| Method | Success | Client Errors | Server Error |
|---|---|---|---|
| PATCH | 200 | 400, 401 | 500 |

Add **502** when Salesforce NA returns its own error; add **503** (`APP:CONNECTIVITY_FAILED`) on downstream connectivity failure after retries.

Success (downstream) example:

```json
{ "data": { "deliveryNumber": "0080001254", "status": "updated" } }
```

Fixed error-response format:

```json
{
  "correlationId": "a1b2c3d4-1234-5678-abcd-ef1234567890",
  "errorCode": "APP:CONNECTIVITY_FAILED",
  "description": "Delivery shipment sync to Salesforce NA could not be completed.",
  "errorDetails": [
    { "message": "Downstream system API returned an error.", "code": "HTTP:INTERNAL_SERVER_ERROR" }
  ]
}
```

---

### Functional Differences (Legacy vs Migrated)

Concise behavioral callout for the in-scope delivery-shipment sync (standards findings are in §6; full detail in companion **Part C**).

| Aspect | Legacy Behavior | Migrated Behavior | Note |
|---|---|---|---|
| Downstream request shape | Flat JSON body (no envelope) | Adds a `header { source, region }` wrapper before the business fields | Confirm downstream sys APIs accept/expect the new `header`; `source`/`region` are not populated on the SAP path (built from unset context) |
| Salesforce NA base path | `/api/outbound-deliveries` | `/sf/outbound-deliveries` | Path changed in migrated config — verify against the current SF sys API |
| Retry on downstream call | No explicit retry (single HTTP request) | `until-successful` retry (`retry.attempts` / `retry.interval`) around the HTTP call | New resilience behavior; connectivity failures raise `APP:CONNECTIVITY_FAILED` |
| Outbound HTTP invocation | Static per-target HTTP request config | Single shared dynamic request flow driven by `targetApiParams` (host/port/method/path/uriParams) | Behavior-neutral consolidation |
| Logging | Built-in Mule `logger` + module log-event flows | Custom Logger (`module-logger`) masked/encrypted with tracepoints | See §6 |
| `region` value | Not set | Set to `NA` on the Salesforce flow only; SAP flow leaves it unset | Inconsistent defaulting — flag for decision (Part C) |
| Retry config duplication | Single source | `retry.attempts`/`retry.interval` defined twice in `config.yaml` (`3/1000` and `3/60000`) | Ambiguous effective interval — flag for decision |

---

## 5. MUnit Coverage

> Unit-test coverage must be **80% or above** (per suite and overall). All external calls (HTTP,
> Salesforce, MQ, DB) must be mocked, with one test suite per flow file.

---

## 6. Standards Compliance & Migration Status

Migration Status below is assessed against the provided migrated build (`shipment-sync-prc-api`).
`✓ Done` items need no further action; remediation is retained only for `◐` / `✗` findings.
Findings are ordered CRITICAL → MAJOR → MINOR.

### 6.1 Clear-text secrets in configuration (CRITICAL)

- **Standard:** `review-security-standards`
- **Severity:** CRITICAL
- **Legacy Baseline:** Secrets stored as inline AES-encrypted values in `.properties` (MQ client secret, `mule-internal-app.clientSecret`) via the secure-properties module; no external vault.
- **Migration Status:** ◐ Partially migrated — secrets are now pulled from Azure Key Vault (`global-logger-encryption-key`, MQ + mule-internal credentials), **but** the Azure Key Vault Properties Provider config in `common/global-config.xml` hard-codes `clientId`, `tenantId`, and a literal `clientSecret`, and the connection config in the legacy still had an inline MQ secret. The vault bootstrap credentials are themselves clear-text in source.
- **Remediation:**
  1. Remove the literal `clientSecret`/`clientId`/`tenantId` from the Azure Key Vault provider config; supply them via environment/runtime properties or a deployment-time secure mechanism (pattern: `sfl-consents-sys-api` global config sourcing vault bootstrap from `${...}` properties, never literals).
  2. Confirm no `.properties`/YAML/XML/DWL file in the repo contains a clear-text or committed encrypted secret.
  3. Keep all functional secrets in Azure Key Vault referenced via `azure-key-vault-properties-provider::secret::...` only.

### 6.2 Error handling not aligned to the global-error-handler pattern (CRITICAL)

- **Standard:** `review-error-handling`
- **Severity:** CRITICAL
- **Legacy Baseline:** A single `on-error-propagate (type=ANY)` common handler that logs via the common module and builds an `alertMessage`, then calls a CloudHub notification flow. No `customErrors.dwl`, no error-type→HTTP-status mapping, no structured error response, no DLQ.
- **Migration Status:** ◐ Partially migrated — the migrated build adds `errors/customErrors.dwl` (`APP:CONNECTIVITY_FAILED`→503, `HTTP:INTERNAL_SERVER_ERROR`→500, `MULE:UNKNOWN`→derived), an error-handler-plugin `process-error`, `until-successful` retry raising `APP:CONNECTIVITY_FAILED`, and error loggers with `tracepoint="EXCEPTION"`. **However** the `global-error-handler` element and the `check-for-raise-error-sub-flow` are commented out (STUDIO-commented) in `common/global-error-handler.xml`, so the referenced default handler is not active; and there is no DLQ publish / DLQ-failure notification for these MQ-driven flows (queues `*-dlq` exist in legacy config).
- **Remediation:**
  1. Un-comment / restore the `global-error-handler` and `check-for-raise-error-sub-flow` so `defaultErrorHandler-ref="global-error-handler"` resolves at runtime (pattern: `leads-proc-api` / `sfl-consents-sys-api` `common/global-error-handler.xml`).
  2. For event-driven flows add `on-error-continue` (prevent message loss) plus a DLQ publish and a notification on DLQ-publish failure (map to `pb-delivery-shipment-sap-dlq` / `pb-delivery-shipment-sf-dlq`).
  3. Ensure the structured error response conforms to the fixed Insulet error format (`correlationId`, `errorCode`, `description`, `errorDetails[]`).
  4. Keep both error loggers (`build-error-log-without-payload` INFO + a masked/encrypted DEBUG logger) with explicit `tracepoint="EXCEPTION"`.

### 6.3 Built-in Mule logger instead of Custom Logger (MAJOR)

- **Standard:** `review-logging-standards`
- **Severity:** MAJOR
- **Legacy Baseline:** Uses built-in `<logger>` (DEBUG "Snapshot of POD payload") and the common log-event-received/processed/error flows; no `module-logger`, no tracepoints, no masking/encryption.
- **Migration Status:** ✓ Done — migrated build uses the Custom Logger Connector (`module-logger`) throughout (entry/exit/error), with `build-log-with-masked-payload`, `sensitiveFields`/`safeKeys`, encryption key from vault, and explicit tracepoints (`APPLICATION_EVENT`, `TRANSFORMATION`, `BEFORE/AFTER_HTTP_REQUEST`, `FLOW_END`, `EXCEPTION`).

### 6.4 Non-standard parent POM and versioning (MAJOR)

- **Standard:** `review-pom-maven-standards`
- **Severity:** MAJOR
- **Legacy Baseline:** Parent `com.mycompany:my-app:1` (placeholder), version `1.0.0-SNAPSHOT`, no `mule-common-pom`.
- **Migration Status:** ✓ Done — migrated inherits `mule-common-pom:1.0.13`, version `1.0.0`, `app.name`/`app.version` properties set, `mule-maven-plugin` pinned.

### 6.5 Properties format & structure not standardized (MAJOR)

- **Standard:** `review-properties-config`
- **Severity:** MAJOR
- **Legacy Baseline:** Env-named flat `.properties` files (`dev.properties`, `qa.properties`, …) with a `${env}.properties` loader; secrets inline; no `config-${mule.env}` convention.
- **Migration Status:** ◐ Partially migrated — migrated uses layered YAML (`config.yaml` + `config-${mule.env}-na.yaml` + `config-${mule.env}-eu.yaml`) with vault references, which is acceptable as a project-wide YAML decision. **Remaining:** duplicated `retry.attempts`/`retry.interval` keys in `config.yaml` (two different values) and a couple of typo keys (`http.basPath`, `sap-shipment-sys-api.post`) should be cleaned up.
- **Remediation:**
  1. De-duplicate the retry keys in `config.yaml` and keep a single authoritative `retry.attempts` / `retry.interval`.
  2. Fix property typos (`basPath`→`basePath`, `sap-shipment-sys-api.post`→intended port/path key) so referenced `Mule::p(...)` lookups resolve.
  3. Confirm all per-environment values (hosts, queue names, timeouts) live in the `config-${mule.env}-{region}.yaml` files only.

### 6.6 Downstream request envelope / field defaulting not defined in target contract (MAJOR)

- **Standard:** `review-dataweave-standards` / `review-api-design-standards`
- **Severity:** MAJOR
- **Legacy Baseline:** Sent a flat body with no `header` wrapper; `source`/`region` were not part of the payload.
- **Migration Status:** ◐ Partially migrated — migrated adds a `header { source, region }` wrapper, but `source`/`region` are read from an unset context on the SAP flow (produces empty/undefined) and `region` is only set to `NA` on the Salesforce flow. The envelope is not yet a confirmed downstream contract.
- **Remediation:**
  1. Confirm with the SAP and Salesforce NA system API owners whether the `header { source, region }` envelope is required; align the mapping accordingly.
  2. Populate `source`/`region` consistently for both flows (single source of truth in the request-context variable), or remove the wrapper if downstream does not expect it.
  3. Externalize the mapping into `dwls/` `p-`-prefixed scripts (pattern: gold-standard process API DWL layout).

### 6.7 Global configuration hygiene (MINOR)

- **Standard:** `review-mule-global-config`
- **Severity:** MINOR
- **Legacy Baseline:** Global config split across `global.xml`; multiple static per-target HTTP request configs; commented-out TLS trust-store.
- **Migration Status:** ◐ Partially migrated — migrated centralizes config in `common/global-config.xml` with a single dynamic HTTP request config driven by `targetApiParams`. **Remaining:** two near-identical MQ configs (`Anypoint_MQ_Config_eu` / `_na`) and a commented-out dynamic request config / TLS trust-store left in place.
- **Remediation:**
  1. Remove dead/commented config blocks; keep only active elements.
  2. Verify both MQ configs are genuinely needed (NA vs EU); otherwise consolidate.
  3. Ensure all config-element `name`/`doc:name` pairs match and no literals remain.

### 6.8 No API specification / Exchange asset (MINOR)

- **Standard:** `review-api-design-standards`
- **Severity:** MINOR
- **Legacy Baseline:** N/A — event-driven API, no RAML.
- **Migration Status:** ✗ Not yet migrated — no project RAML/spec or Exchange asset is present for this process API (README references a template spec only). Even for an MQ-driven API, the health-check endpoints and an interface contract should be documented in Exchange.
- **Remediation:**
  1. Publish an interface/asset entry (at minimum the health-check contract and an integration description) to Anypoint Exchange, and record the Exchange Specification URL in §1.
  2. Document the MQ event contracts (queue names, message properties, payload shape) alongside the asset.

### 6.9 Health-check endpoints (MINOR)

- **Standard:** `review-api-design-standards`
- **Severity:** MINOR
- **Legacy Baseline:** N/A — legacy had no `/api/ping` or `/api/health-check`.
- **Migration Status:** ✓ Done — migrated build ships liveliness/readiness endpoints (`p-set-liveness-response.dwl`, `p-set-readiness-response.dwl`, health-check MUnit suite).

### 6.10 MUnit coverage for in-scope flows (MAJOR)

- **Standard:** `review-munit-testing`
- **Severity:** MAJOR
- **Legacy Baseline:** Had a shipdetails test suite (SAP success, SF success, SAP timeout) and a POD suite — external HTTP calls mocked.
- **Migration Status:** ✗ Not yet migrated — the migrated repo contains a health-check suite and sample data for other flows, but **no test suite for the delivery-shipment (`outbound-deliveries/{deliveryNumber}`) flows**. The in-scope SAP and SF sync flows are currently untested.
- **Remediation:**
  1. Add one MUnit suite per in-scope flow file (SAP sync, SF sync) with ≥1 positive and ≥1 negative case each; mock the MQ subscriber input and the downstream HTTP request.
  2. Include a connectivity-failure case that asserts `APP:CONNECTIVITY_FAILED` handling and retry behavior.
  3. Achieve ≥80% coverage per suite and overall.

---

> Handoff: this design feeds `/use-raml` (interface/health-check contract) and `/use-develop` (build).
> Companion Gap Analysis & Migration Decisions: `shipment-sync-prc-api-gap-analysis.md` (`Ref: GAP-shipment-sync-prc-api`).
