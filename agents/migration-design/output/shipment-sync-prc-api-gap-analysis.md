# shipment-sync-prc-api — Gap Analysis & Migration Decisions
> Ref: GAP-shipment-sync-prc-api
> Companion to: shipment-sync-prc-api-migration-design.md

Scope: the `/outbound-deliveries/{deliveryNumber}` delivery-shipment sync flow (SAP + Salesforce NA),
baselined on the legacy `na-delivery-shipment-prc-api` and the provided migrated `shipment-sync-prc-api` build.

---

## A. Requirement / Gap Mapping

| Requirement / Gap (source) | Addressed By (design point) | Status | Migrated baseline |
|---|---|---|---|
| Keep the process API name aligned to the migrated API (`shipment-sync-prc-api`) | §1 Application Technical Name | Covered | ✓ |
| Sync outbound delivery details to SAP keyed on `deliveryNumber` | §4.1 | Covered | ✓ |
| Sync outbound delivery details to Salesforce NA keyed on `deliveryNumber` | §4.2 | Covered | ✓ |
| Consume delivery-shipment events from Anypoint MQ | §3, §4 resources | Covered | ✓ |
| Move secrets from inline `.properties` to Azure Key Vault | §6.1 | Covered (residual) | ◐ |
| Adopt global-error-handler + `customErrors.dwl` + structured error response | §6.2 | New | ◐ |
| Replace built-in logger with Custom Logger + tracepoints/masking | §6.3 | Covered | ✓ |
| Standardize parent POM (`mule-common-pom`) and semantic version | §6.4 | Covered | ✓ |
| Standardize properties structure (layered YAML per env/region) | §6.5 | Covered (cleanup) | ◐ |
| Add downstream retry / resilience (`until-successful`) | §4 Functional Differences, §6.2 | New | ✓ |
| Add health-check (`/api/ping`, `/api/health-check`) endpoints | §6.9 | New | ✓ |
| Publish API/interface asset to Anypoint Exchange | §6.8 | New | ✗ |
| MUnit coverage for the in-scope delivery-shipment flows | §6.10 | New | ✗ |
| Define/confirm `header { source, region }` downstream envelope | §4 mapping notes, §6.6 | New | ◐ |
| Non-functional requirements (auth, response time, TPS, spike, rate-limit) | §2 | TBC | — |

---

## B. Open Questions & Migration Decisions

- **Exchange / interface asset:** No project RAML or Exchange asset exists. Confirm the interface contract (health checks + MQ event contracts) to publish, and provide the Exchange Specification URL.
- **`header { source, region }` envelope:** Is this envelope required by the SAP and Salesforce NA system APIs? On the SAP flow `source`/`region` are built from an unset context (empty); on the SF flow `region` is hard-set to `NA`. Decide the authoritative source and populate consistently, or drop the envelope.
- **Salesforce NA base path change:** Legacy config used `/api/outbound-deliveries`; migrated uses `/sf/outbound-deliveries`. Confirm the correct current path for the SF sys API.
- **Duplicated retry config:** `config.yaml` defines `retry.attempts`/`retry.interval` twice (`3/1000` and `3/60000`). Confirm the intended retry interval and remove the duplicate.
- **Property typos:** `http.basPath` (→ `basePath`) and `sap-shipment-sys-api.post` (referenced as `requestPort`) look like typos; confirm intended keys so `Mule::p(...)`/`p(...)` lookups resolve.
- **DLQ handling:** Legacy defined `pb-delivery-shipment-sap-dlq` / `pb-delivery-shipment-sf-dlq`. Confirm the migrated build must publish to these DLQs on failure and notify on DLQ-publish failure.
- **Azure Key Vault bootstrap credentials:** The vault provider config carries literal `clientId`/`tenantId`/`clientSecret`. Confirm these will be externalized (not committed) before production.
- **Runtime / monitoring / API Manager URLs and NFRs:** Provide deployment URLs, monitoring dashboard, API Manager instance, and NFR sizing (auth policy, response time, TPS, spike, rate-limit) to replace the §1/§2 `TBC` cells.
- **Region coverage:** Migrated build carries both NA and EU MQ/config; confirm whether EU delivery-shipment sync is in scope for this migration or NA-only.
- **Assumption:** The first `package[0]` entry is the one mapped downstream (both legacy and migrated behave this way); confirm multi-package events never require iterating all packages.

---

## C. Functional Differences (Legacy vs Migrated vs Target Design)

| Aspect / Behavior | Legacy | Migrated | vs. Target Design | Impact / Decision |
|---|---|---|---|---|
| Downstream request body shape | Flat JSON (no envelope) | Wraps business fields under `header { source, region }` | Diverges — target contract not confirmed | Confirm downstream expectation (§6.6); align or remove wrapper |
| `source` / `region` population | Not present in payload | SF flow sets `region: "NA"`; SAP flow reads from unset context (empty) | Diverges (inconsistent) | Define single request-context source; populate both flows consistently |
| Salesforce NA path | `/api/outbound-deliveries/{deliveryNumber}` | `/sf/outbound-deliveries/{deliveryNumber}` | Diverges | Verify correct SF sys API path |
| SAP field names | `salesOrderNumber`, `trackingNumber`, `carrierUsed` | Same (SAP flow) | Matches | None |
| Salesforce field names | `salesOrderNumber`, `trackingNumber`, `carrierUsed` (legacy SF flow) | Renamed: `salesOrderNr`, `trackingId`, `carrierName` | Matches migrated intent (SF contract) | Confirm SF sys API expects the renamed fields |
| Retry / resilience | Single HTTP request, no retry | `until-successful` (`retry.attempts`/`retry.interval`) raising `APP:CONNECTIVITY_FAILED` | Exceeds legacy; matches target resilience intent | Resolve duplicate retry keys (§B) |
| Downstream invocation | Static per-target HTTP request configs (`HTTP_Request_configuration_SAP`, SF config) | Single shared dynamic flow driven by `targetApiParams` (host/port/method/path/uriParams) | Matches target (consolidation) | Behavior-neutral; ensure `requestPort` key resolves |
| Correlation handling | `correlationId` header + `sendCorrelationId=ALWAYS` | Same, via shared request flow | Matches | None |
| Logging | Built-in `logger` + module log-event flows, no masking | Custom Logger masked/encrypted, tracepoints, entity details | Matches/exceeds target | None (see §6.3) |
| Error response | `alertMessage` + CloudHub notification only | `customErrors.dwl` mapping + structured response (handler currently commented out) | Partially matches target | Activate global handler (§6.2) |
| DLQ on failure | DLQ queues defined; no explicit publish shown | No DLQ publish for these flows | Diverges | Add DLQ publish + failure notification |
| Endpoint set | POD + shipdetails (SAP/SF) in one prc-api | Adds pickship, returns, goods-receipt, inventory-status, status-update flows | Out of scope additions | Out of scope for Infinity scope — no action here |
| Health checks | None | `/api/ping`, `/api/health-check` present | Matches target | None |
| MUnit | Shipdetails suite (SAP/SF/timeout) + POD suite present | No delivery-shipment suite (health-check suite only) | Regresses vs legacy for in-scope flows | Add suites (§6.10) |
