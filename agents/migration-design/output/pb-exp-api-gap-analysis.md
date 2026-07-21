# pb-exp-api — Gap Analysis & Migration Decisions
> Ref: GAP-pb-exp-api
> Companion to: pb-exp-api-migration-design.md

> Scope: `PATCH /outbound-deliveries/{deliveryNumber}` (Infinity scope). Compared against the
> already-migrated build in `input/migrated-api/pb-exp-api/`.

---

## A. Requirement / Gap Mapping

| Requirement / Gap (source) | Addressed By (design point) | Status | Migrated baseline |
|---|---|---|---|
| New migrated API must be named `pb-exp-api` | §1 Application Overview | Covered | ✓ |
| Accept shipment-details update per delivery and fan out to SAP | §4.1 (Route A) | Covered | ✓ |
| Conditionally route to Salesforce when `distributionChannel == 10` | §4.1 (Route B) | Covered | ✓ |
| Validate `addressString` is present | §4.1.2 Step 1 | Covered | ✓ |
| Return a meaningful success acknowledgement | §4.1.3 | Covered | ✓ |
| Adopt Insulet Custom Logger (Datadog) | §6.9 | Covered | ◐ (tracepoints/category not explicit) |
| Externalize configuration into env-specific property files | §1, §6.2 | Covered | ◐ (prod file malformed) |
| Zero clear-text secrets (Azure Key Vault) | §6.1 | New | ✗ |
| Effective PII masking in logs | §6.3 | New | ◐ |
| Standard Insulet error envelope + correct HTTP codes | §6.4 / §6.5 | New | ◐ |
| API Manager policy enforcement (autodiscovery + Client ID) | §6.6 | New | ✗ |
| Failure alerting/notification | §6.7 | New | ✗ |
| Async publish resilience (on-error-continue + DLQ) | §6.8 | New | ✗ |
| `/health-check` readiness endpoint | §6.10 | New | ✗ |
| Project-specific README / Exchange / Confluence docs | §6.11 | New | ✗ |
| NFR sizing (auth, response time, TPS, spike, rate-limit) | §2 | TBC | — |

---

## B. Open Questions & Migration Decisions

- **MQ message contract:** The migrated build changes the SAP/Salesforce queue message from the
  near-raw request to a normalized envelope wrapped with `source`/`target`/`region` and with
  empty-string placeholders for `deliveryDate`/`deliveryNumber`/`trackingNumber`. Confirm the SAP
  and Salesforce consumers accept the new shape and ignore the empty placeholders.
- **Success contract change:** The success body changed from `{}` to
  `{ "message": "shipment details are updated successfully" }`. Confirm the Pitney Bowes caller
  tolerates a non-empty 200 body.
- **Error status code:** Legacy mapped generic failures to HTTP 422. Standard prefers 500 / 503
  (and 400/401 for client errors). Decide whether 422 must be retained for any caller contract.
- **SAP host property naming (affects the out-of-scope GET):** the migrated flow reads
  `sap-shipment-sys-api.*` while `config-prod-na.yaml` defines `sap-account-order-sys-api.*`.
  Reconcile the property names before that endpoint is migrated.
- **Environment values:** Confirm `shipment.source` / `shipment.target` / `region` values and the
  correct AMQ queue names per environment (prod file currently prefixes `prod-...`).
- **NFRs:** Provide auth scheme, response-time SLA, expected TPS, spike control, and rate-limit SLA
  (currently TBC in §2).
- **TLS/transport:** Legacy terminated HTTPS in-app (JKS keystore); the migrated listener is plain
  HTTP (port only). Confirm TLS is offloaded at the CloudHub/load-balancer layer.
- **Assumption:** `deliveryNumber` (path param) is propagated as an MQ user property, not in the
  message body; confirm this matches consumer expectations.

---

## C. Functional Differences (Legacy → Migrated, and vs. Target Design)

| Aspect / Behavior | Legacy | Migrated | vs. Target Design | Impact / Decision |
|---|---|---|---|---|
| Success response body | `{}` | `{ "message": "shipment details are updated successfully" }` | Matches (meaningful ack desired) | Confirm caller tolerates non-empty body. |
| MQ message body | Inbound request published essentially as-received | Normalized fixed-schema envelope, `skipNullOn` applied | Matches (canonical message desired) | Consumers must accept new shape. |
| Message envelope metadata | None | `source` / `target` / `region` prepended | Exceeds legacy | Verify consumer parsing. |
| Placeholder fields | Absent | `deliveryDate` / `deliveryNumber` / `trackingNumber` = `""` | Diverges — empties add noise | Decide whether to omit vs. keep for shared schema. |
| `source` / `target` origin | Hard-coded (`PB`, `SAP and Salesforce`) | From config (`shipment.source`/`shipment.target`) | Matches (no hard-coding) | Ensure per-env values correct. |
| Salesforce routing | `distributionChannel == 10` → publish; else log | Same | Matches | No change. |
| Outbound publish retry | `until-successful` retries | `until-successful` retries | Matches | No change. |
| Publish failure handling | Error → 422 + CloudHub notification | Error → 422; **notification removed** | Diverges — alerting lost | Reinstate alerting (§6.7). |
| DLQ / message-loss protection | None | None | Diverges from async standard | Add on-error-continue + DLQ (§6.8). |
| Error response shape | `{ "message": ... }`, HTTP 422 / APIKit-specific codes | `{ "message": ... }`, HTTP 422 (APIKit codes dropped) | Diverges — no standard envelope | Adopt fixed envelope + codes (§6.4). |
| Debug payload logging | Plain DEBUG logger, unmasked | Custom Logger masked op, but `sensitiveFields` empty | Diverges — PII still exposed | Populate masking config (§6.3). |
| Transport security | HTTPS in-app (JKS) | Plain HTTP listener | Diverges (assumed LB offload) | Confirm TLS termination point. |
| API Manager binding | Autodiscovery present | Autodiscovery absent | Diverges — policies unenforced | Restore autodiscovery (§6.6). |
