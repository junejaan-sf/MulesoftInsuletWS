# sap-shipment-sys-api — Gap Analysis & Migration Decisions
> Ref: GAP-sap-shipment-sys-api
> Companion to: sap-shipment-sys-api-migration-design.md

Baselined on the legacy `sap-account-order-sys-api` + notes; Migrated baseline column assessed
against `input/migrated-api/sap-shipment-sys-api/`. Scope: `PATCH /outbound-deliveries/{deliveryNumber}`.

---

## A. Requirement / Gap Mapping

| Requirement / Gap (source) | Addressed By (design point) | Status | Migrated baseline |
|---|---|---|---|
| Post outbound-delivery shipment details to SAP (notes) | §4.1 PATCH `/outbound-deliveries/{deliveryNumber}` | Covered | ✓ |
| Deliver as a `DELVRY03`/`ZDELVRY03` (`SHPCON`) IDoc (derived from migrated build) | §4.1.2 Step 1–2 | Covered | ✓ |
| Connectivity retry on IDoc send (derived) | §4.1.2 Step 2 (`reconnection.*`, `until-successful`) | Covered | ✓ |
| Standard Insulet error envelope + HTTP status mapping (LLD/standards) | §4.1.3, §6.1 | New | ◐ |
| Readiness health check `/api/health-check` (standards) | §4 Resources, §6.3 | New | ✗ |
| Datadog monitoring enabled (standards) | §1 Monitoring, §6.2 | New | ✗ |
| Secrets via Azure Key Vault (standards) | §1, §6.8 | Covered | ✓ (TLS keystore pwd ◐) |
| Client ID Enforcement via Autodiscovery (standards) | §2, §6.9 | Covered | ✓ |
| Custom Logger + standard parent POM (standards) | §1, §6.10 | Covered | ✓ |
| Payload/PII masking effective for shipment fields (standards) | §6.4 | New | ◐ |
| Non-functional sizing (response time, TPS, spike, rate-limit) | §2 (TBC) | TBC | — |

---

## B. Open Questions & Migration Decisions

- **SAP partner profile / inbound processing:** confirm the SAP-side inbound partner profile and
  process code for `ZDELVRY03` / `SHPCON` so the delivery-confirmation IDoc is processed correctly
  per environment (`rcvprn DS4CLNT210`, `mandt 210` observed in dev-na).
- **Caller contract:** confirm the calling layer (`pb-exp-api` / `na-delivery-shipment-prc-api`) and
  the exact request field set — the design lists `packingSlipId`, `trackingId`, `carrierName`,
  `serviceUsed`, `shippingCost`. Are any additional delivery-item fields required?
- **Success response shape:** the migrated build returns `{ success, correlationId }` (legacy returned
  `{ status, message }`). Confirm the caller accepts the new shape.
- **IDoc-send failure semantics:** confirm the desired HTTP status on send failure (design proposes
  502 `APP:CONNECTIVITY_FAILED`) and whether a dead-letter / replay mechanism is required.
- **Reconnect strategy:** confirm bounded reconnect values for the SAP JCo/S4 configs (currently
  `reconnect-forever`).
- **Downstream host/credentials:** dev values observed (`vhiucds4ci.sap.insulet.com`,
  `fiori-dev.sap.insulet.com`); confirm per-environment hosts and the `shipment-sap-password` vault
  key mapping for QA/UAT/PROD.
- **Datadog dashboard / API Manager / Exchange / repo URLs:** provide the concrete URLs (left TBC).

---

## C. Functional Differences (Legacy → Migrated, and vs. Target Design)

| Aspect / Behavior | Legacy (`sap-account-order-sys-api`) | Migrated (`sap-shipment-sys-api`) | vs. Target Design | Impact / Decision |
|---|---|---|---|---|
| Endpoint | No `PATCH /outbound-deliveries`; shipment status posted via OData create under `POST /shipments` | New `PATCH /outbound-deliveries/{deliveryNumber}` | Matches target (this is the intended new system endpoint) | New capability — caller/SAP contract must be confirmed (Part B). |
| Integration mechanism | SAP S/4HANA OData `create-entity` (`ZOTC_POD_STATUS_UPDATE_SRV`) | SAP JCo **IDoc send** `DELVRY03`/`ZDELVRY03` (`SHPCON`) | Matches target | Requires JCo/IDoc shared libs + SAP partner profile. |
| Request shape | Complex nested `header`/`pod`/status payload | Flat shipment fields (`packingSlipId`, `trackingId`, `carrierName`, `serviceUsed`, `shippingCost`) | Matches target | Confirm mandatory fields with caller. |
| Success response | `{ status: "OK", message: <sapResponse> }` | `{ success: true, correlationId }` | Matches target | Confirm caller accepts new shape. |
| Error mapping | APIKit per-type handlers + common handler → 422 with `{ code, message, egReason }` | Main-flow global handler commented out; PATCH handler returns `{ description, code, message }` without `httpStatus` → 500 | **Diverges** from target (fixed Insulet envelope + correct HTTP codes) | Decision: implement §6.1 remediation. |
| Retry config | `sap.maxRetries` / `sap.msBetweenRetries` | `reconnection.attempts` / `reconnection.frequency` + connector `reconnect-forever` | Partially matches (unbounded reconnect) | Decision: bound reconnect (§6.7). |
| Logging | Common logging module + DEBUG loggers | Custom Logger with masked payload + tracepoints | Matches target (masking coverage gap) | Extend `sensitiveKeyParts` (§6.4). |
| Monitoring | CloudHub logs | Custom Logger, but Datadog appender commented out | **Diverges** from target | Decision: re-enable Datadog appender (§6.2). |
