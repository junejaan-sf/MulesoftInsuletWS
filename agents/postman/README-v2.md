# Postman Agent (v2)

Generates Postman v2.1 collections for MuleSoft HTTP APIs — with per-environment folders (local, DEV, QA, UAT, PROD), happy path and negative scenarios, seed-payload prompts per endpoint, optional Excel test-case workbook support, and all secrets replaced with collection variables.

> **Note:** This is the v2 README. The v1 README (`agents/postman/README.md`) is preserved unchanged for diffing. When you are ready to promote, rename `*-v2.*` files to replace the v1 originals.

## Activate

Type `/use-postman` in a new Cursor chat (configure it to load `intent-gen-postman-v2.mdc`).

## Folder Structure

```
postman/
├── rules/
│   ├── intent-gen-postman-v2.mdc           ← main entry point (full lookup chain)
│   └── gen-postman-implementation-v2.mdc   ← full Postman generation standards
├── examples/                                ← reference Postman collections
├── templates/                               ← collection structure templates
├── README.md                                ← v1 README (preserved)
└── README-v2.md                             ← this file
```

## Inputs → `project/input_postman/`

Place any of these before running `/use-postman`:
- RAML or OpenAPI spec (`.raml`, `.yaml`) for the target API
- MUnit test XML files — the agent extracts request/response fixtures from these
- Or just the API name — the agent auto-locates the spec via its lookup chain

If the folder is empty, provide the API name in chat and the agent will search for the spec.

### Test case workbook (optional, NGASIM-style)

Drop a single `.xlsx` into `project/input_postman/` and the agent will use it as the source of truth for negative scenarios. Required columns:

| Column | Content |
|---|---|
| Col A | TC ID + expected HTTP status (e.g., `NGASIM-3143_TC02_400 Bad Request_Missing Mobile Number`) |
| Col B | Test case description — drives payload mutation |
| Col H | Pre-requisites / setup notes (optional) |

When a workbook is found the agent announces it in chat, suppresses the MUnit-derived negative checklist, and runs each row through the §6.11 mutation library. If no workbook is provided, today's MUnit-driven flow is used **unchanged** — the workbook is entirely optional.

See `gen-postman-implementation-v2.mdc` §6.11 for the full list of supported mutation patterns (phone-starts-with-8, invalid-sf-id, datatype-violation, missing-required-field, field-exceeds-max-length, empty-payload, invalid-credentials, dependency-outage, non-existent-resource).

### Seed successful payloads

For every non-health endpoint (excluding `/ping`, `/health-check*`) the agent resolves the seed payload using a four-tier chain. **Stop at the first hit:**

**Tier 0 (highest priority) — Live-resolved seed payloads**
If `project/input_postman/{api}-seed-payloads.json` exists (produced by the `agents/testdata` Live Test Data Resolver), the agent reads real Salesforce record Ids and field values from it and uses them as the seed body. This is the recommended path for any POST/PUT endpoint that must succeed against a live Salesforce org. Run `/use-testdata` before `/use-postman` to produce the file. See the resolver pre-step section below for details.

**Tier 1 — User-supplied JSON**
Paste JSON at the STOP-and-ASK gate — validated against the RAML body schema; a mismatch warns but accepts.

**Tier 2 — MUnit `*-success-request.json`**
Auto-pulled from `src/test/resources/testdata/{suite}/business-inbound/`. Note: MUnit data is synthetic and will fail business-logic validation against a live SF org.

**Tier 3 — RAML example**
Inline `example:` block or `examples/` file under the resolved RAML root.

If none of the four tiers resolves, that endpoint is **aborted** with a clear chat error — no empty or placeholder bodies are ever emitted.

### Optional resolver pre-step (recommended for Salesforce system APIs)

Before running `/use-postman`, run the Live Test Data Resolver in a separate chat:

```
/use-testdata
```

This auto-derives real Salesforce record Ids and field values for every POST/PUT endpoint by:
1. Reading the Mule app's Salesforce connector operations from flow XML.
2. Tracing payload-field → SObject.field mappings from request DataWeave files.
3. Querying live, valid records read-only from the SF devint/devint2 org via the Salesforce MCP.
4. Writing `project/input_postman/{api}-seed-payloads.json` as the Tier 0 input.

No Salesforce records are created. MUnit fixtures are not modified. The resolver is entirely optional — if the file is absent, `/use-postman` falls through to Tier 1 (user JSON) as before.

**When to re-run the resolver:** The artifact records `resolvedAt`. If Salesforce data has changed (records deleted, Campaign+Lead already linked, etc.), delete the file and re-run `/use-testdata` before the next regression pass.

### Required negative coverage

Every non-health endpoint will always emit at least one `400`, `401`, and `404` negative request. If your workbook or MUnit tests didn't supply one for a given endpoint, the agent **synthesizes** the missing request(s) from the mutation library defaults and reports the synthesized list in a single chat note. `500` remains optional and is emitted only when evidenced by the workbook or MUnit.

See `gen-postman-implementation-v2.mdc` §6.12 for synthesis details and the sanctioned `404`-gap exception.

**Additional context (optional) → `project/input_develop/`**

If `jira-*.md` and `confluence-design.md` are present in `project/input_develop/` (produced by `/use-develop` or `/use-raml-from-jira`), the agent automatically reads them to:
- Populate request body examples with realistic field values from the Confluence design
- Add meaningful descriptions to requests using endpoint details from the spec
- Name scenarios using acceptance criteria language from the JIRA story

## RAML Lookup Chain (automatic)

The agent finds the spec in this order — stopping at the first hit:
1. `pom.xml` dependency coordinates → Anypoint Exchange
2. Local Maven cache (`~/.m2/`)
3. `agents/raml/examples/{api-name}-spec/` (workspace)
4. `src/main/resources/api/` (in-project)
5. Asks you if all four miss

## Outputs → `agents/postman/examples/`

```
agents/postman/examples/
└── {api-name}.postman_collection.json
```

Collection structure per environment:
```
{API Name}
├── local/
│   ├── Happy Path/
│   └── Negative/           ← floor: at least 400 + 401 + 404 per non-health endpoint
├── DEV/
│   ├── Happy Path/
│   └── Negative/
...
```

## Request Naming Conventions

| Scenario | Name format | Example |
|---|---|---|
| Happy path (all modes) | `{METHOD} {path} — Happy Path` | `POST /api/v1/consents/opt-ins — Happy Path` |
| Workbook-driven negative | `{TICKET}_{TC_ID}_{STATUS}_{SHORT_TITLE}` | `NGASIM-3143_TC02_400 Bad Request_Missing Mobile Number` |
| Synthesized required-floor (workbook run) | `{TICKET}_SYN_{code}_{endpoint-label}` | `NGASIM-3143_SYN_401_consents-opt-ins` |
| MUnit-derived negative | `{METHOD} {path} — {code} {scenario}` | `POST /api/v1/consents/opt-ins — 400 Validation Error` |
| Synthesized required-floor (MUnit run) | `synth-{method}-{path-slug}-{code}` | `synth-post-consents-opt-ins-401` |

## Tips

- Non-HTTP flows (MQ subscribers, schedulers, file/JMS listeners) are automatically excluded — the agent will list skipped flows in chat
- Never hardcode `client_id`, `client_secret`, or bearer tokens — always use `{{collection_variable}}` syntax; the only sanctioned exception is the literal `"invalid-client-id"` / `"invalid-client-secret"` pair used in the `401` invalid-credentials test
- Negative scenarios are limited to `{400, 401, 404, 500}` — the floor forces `400`, `401`, `404` for every non-health endpoint; `500` is optional
- Drop multiple `.xlsx` workbooks into `project/input_postman/` and the agent will ask you to pick one; remove all of them to revert to the MUnit-driven path
