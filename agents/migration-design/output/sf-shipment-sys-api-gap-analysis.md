# sf-shipment-sys-api — Gap Analysis & Migration Decisions
> Ref: GAP-sf-shipment-sys-api
> Companion to: sf-shipment-sys-api-migration-design.md

Baselined on the legacy `sf-na-sys-api` + notes; Migrated baseline column assessed against
`input/migrated-api/sf-shipment-sys-api/`. Scope: `PATCH /outbound-deliveries/{deliveryNumber}`.

---

## A. Requirement / Gap Mapping

| Requirement / Gap (source) | Addressed By (design point) | Status | Migrated baseline |
|---|---|---|---|
| Write outbound-delivery shipment details to Salesforce (notes) | §4.1 PATCH `/outbound-deliveries/{deliveryNumber}` | Covered | ✓ |
| Create `IntegrationQueue__c` (channel "Tracking Inbound") (derived) | §4.1.2 Step 1–2 | Covered | ✓ |
| Validate Salesforce create success (derived) | §4.1.2 Step 2 | Covered | ✓ |
| Standard Insulet error envelope + HTTP status mapping (LLD/standards) | §4.1.3, §6.3 | New | ◐ |
| Effective PII masking (`addressString`) (standards) | §6.1 | New | ◐ |
| Custom Logger connector dependency restored (standards) | §1, §6.2 | New | ◐ |
| Readiness health check `/api/health-check` (standards) | §4 Resources, §6.4 | New | ✗ |
| Secrets via Azure Key Vault (standards) | §1, §6.7 | Covered | ✓ (TLS keystore pwd ◐) |
| Client ID Enforcement via Autodiscovery (standards) | §2, §6.8 | Covered | ✓ |
| Standard parent POM (standards) | §1, §6.10 | Covered | ✓ |
| Non-functional sizing (response time, TPS, spike, rate-limit) | §2 (TBC) | TBC | — |

---

## B. Open Questions & Migration Decisions

- **Caller contract / field names:** the migrated build renames request fields
  (`salesOrderNumber→salesOrderNr`, `trackingNumber→trackingId`, `carrierUsed→carrierName`). Confirm
  the calling layer (`pb-exp-api` / `na-delivery-shipment-prc-api`) sends the new names.
- **`IntegrationQueue__c` downstream processing:** confirm the Salesforce-side automation that
  consumes the "Tracking Inbound" channel record and updates the `Shipment__c` object.
- **Salesforce config selection:** the endpoint uses `Salesforce_Config_NA`; confirm this is correct
  for all in-scope regions/environments.
- **Create-failure semantics:** confirm the desired HTTP status on a failed create (design proposes
  502 `SALESFORCE:CONNECTIVITY`) and whether retry/replay is required.
- **Custom Logger dependency:** confirm the intended `mule-custom-logger-connector` version to
  restore in the POM (currently commented out while the config references it).
- **Downstream credentials:** confirm the vault key mappings (`na-shipment-sf-consumer-key`,
  `na-shipment-sf-store-password`) and Salesforce keystore per environment.
- **Datadog dashboard / API Manager / Exchange / repo URLs:** provide the concrete URLs (left TBC).

---

## C. Functional Differences (Legacy → Migrated, and vs. Target Design)

| Aspect / Behavior | Legacy (`sf-na-sys-api`) | Migrated (`sf-shipment-sys-api`) | vs. Target Design | Impact / Decision |
|---|---|---|---|---|
| Request field names | `salesOrderNumber`, `trackingNumber`, `carrierUsed`, `addressString` | `salesOrderNr`, `trackingId`, `carrierName`, `addressString` | Matches target (aligned naming) | Caller contract change — confirm (Part B). |
| Channel property key | `sf.pb.shipmentdetails.channel` (`"Tracking Inbound"`) | `salesforce.pb.shipmentdetails.channel` (`"Tracking Inbound"`) | Matches target | Same value; verify per environment. |
| Salesforce object mapping | `IntegrationQueue__c` { Channel__c, SO_Number__c, TrackingNumber__c, CarrierUsed__c, ShippingLabel__c } | Identical fields | Matches target | No change. |
| Salesforce config | `Salesforce_Config` | `Salesforce_Config_NA` | Matches target | Confirm region mapping. |
| Success response | `{ id }` | `{ id }` | Matches target | Unchanged. |
| Error mapping | Common logging module set-error-response (standardized body) | `na-common-error-handler`: `{ description, type, message }` as `application/java`, no `httpStatus` → 500 | **Diverges** from target (fixed Insulet JSON envelope + HTTP codes) | Decision: implement §6.3 remediation. |
| Logging | Common logging module (event received/processed) | Custom Logger masked payload + tracepoints | Matches target (masking + dependency gaps) | Decisions: §6.1 masking, §6.2 restore dependency. |
| PII masking | Placeholder (`['dummy']`) — unmasked | `sensitive.fields: ["name"]` — `addressString`/`trackingId` still unmasked | **Diverges** from target | Decision: §6.1 remediation. |
