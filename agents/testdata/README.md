# Live Test Data Resolver

Automatically generates real Salesforce test data for Postman seed payloads. Runs after MUnit and before Postman generation — it reads the Mule app's Salesforce connector operations and DataWeave mappings, queries live valid records (read-only), and writes a seed-payload artifact that the Postman v2 generator consumes as its highest-priority input.

MUnit fixtures stay synthetic. No Salesforce records are created.

## Why this exists

MUnit tests use mocked/synthetic data. When Postman runs real HTTP calls against a live Mule API, those synthetic record Ids and field values fail business-logic validation (record not found, Campaign + Lead already linked, etc.). This resolver closes the gap by sourcing real, valid values from the target Salesforce org.

## Architecture

```
MUnit (synthetic fixtures)
        │
        ▼
Live Test Data Resolver  ──[SOQL read-only]──▶ SF devint/devint2
        │
        ▼
project/input_postman/{api}-seed-payloads.json
        │
        ▼
Postman v2 generator (§6.5 Tier 0)
        │
        ▼
Newman / regression run
```

## Activate

Type `/use-testdata` in a new Cursor chat (configure it to load `intent-gen-testdata.mdc`).

You can also ask directly: *"Resolve live test data for sfl-campaigns-sys-api"* or *"Generate Postman seed payloads for my Mule API using real Salesforce data."*

## Folder Structure

```
testdata/
├── rules/
│   ├── intent-gen-testdata.mdc          ← main entry point
│   └── gen-testdata-implementation.mdc  ← full resolver algorithm
└── README.md                            ← this file
```

## Inputs

| Source | Location | Required |
|---|---|---|
| Mule flow files | `project/output_develop/{api}/src/main/mule/*.xml` | Yes |
| Properties files | `src/main/resources/properties/config.properties`, `config-dev.properties` | Yes |
| Request-mapping DWLs | `src/main/resources/dwls/p-*-input.dwl` | Yes |
| RAML spec | Auto-located via `gen-postman-implementation-v2.mdc` §4.1 lookup chain | Yes |
| SF MCP login | Configured in `mcp.json` under `user-salesforce-dx` | Yes |

No manual input files are needed. The resolver derives all mappings from the Mule app's own code.

## Output

```
project/input_postman/
└── {api}-seed-payloads.json
```

Keyed by `{METHOD} {path}`, with:
- `happy.body` — valid request body using real SF record Ids/values
- `negative.400.body` — body that intentionally triggers a 400 (real ids + bogus lookup key)
- `_provenance` — SOQL used, SF login alias, SObjects discovered, timestamp

## SF Login Selection

The resolver is **object-agnostic**: it probes the available SF CLI aliases using:

```sql
SELECT QualifiedApiName FROM EntityDefinition
WHERE QualifiedApiName IN ('<obj1>', '<obj2>', ...)
```

It selects the alias that can read **all** SObjects the endpoint touches. Known patterns for this workspace:

| SObjects | Alias to use |
|---|---|
| Lead, Account, Contact, Case, Task, Opportunity | `integration.persona` (base integration user) |
| Campaign, CampaignMember | `integration_campaign_devint2` (Marketing User license) |
| Mixed (e.g. Campaign + Lead) | `integration_campaign_devint2` if it can also read Lead; otherwise surface a gap note |

To add a new SF org login, follow the SF CLI JWT auth steps and add the alias to `mcp.json` under `user-salesforce-dx → --orgs`.

## Field-Role Taxonomy

| Role | What it is | How resolved |
|---|---|---|
| **lookup-key** | Field used in a `WHERE` clause to match an existing parent record (e.g. `Campaign_Key__c`, external Id, `Email`) | `SELECT DISTINCT <field> FROM <SObject> WHERE <field> != null LIMIT 10` |
| **foreign-key-id** | Salesforce relationship Id placed directly in the payload (e.g. `LeadId`, `AccountId`) | `SELECT Id FROM <SObject> WHERE <validity filter> LIMIT 10` |
| **plain-data** | Free-form value (name, phone, description) not used in SF lookup | Taken from RAML example or MUnit fixture; PII masked |

## Multi-Object Endpoints

When an endpoint queries one SObject and writes to another (e.g. query Campaign, create CampaignMember), the resolver resolves them in **topological order** — parents first, dependents after. Captured parent Ids flow into the dependent query's junction-exclusion filter so the happy-path call does not hit uniqueness constraint errors.

## Guardrails

- **Read-only.** Only `run_soql_query`, `list_all_orgs`, `get_username` are used. No Salesforce writes.
- **No secrets in output.** The artifact contains only record Ids and field values. Credentials are never written.
- **Fail gracefully.** If a field can't be resolved (0 records, unreadable object, undecodable DWL), that endpoint is omitted from the artifact. The Postman §6.5 chain falls back to MUnit/RAML automatically.
- **MUnit untouched.** Only `project/input_postman/` is written. MUnit XML and fixture JSON files are never modified.
- **PII masked.** Plain-data fields containing PII patterns (phone, email, SSN, DOB) are masked before writing.
- **Re-run before each regression pass.** The artifact records `resolvedAt`. Records may be deleted or reassigned between runs.

## Tips

- The resolver emits a resolution summary in chat after each run: every endpoint is marked RESOLVED (with org alias) or SKIPPED (with reason).
- Skipped endpoints still get a Postman request — via the §6.5 MUnit/RAML fallback. The skipped list tells you which calls may fail live.
- To force re-resolution (e.g. after a Salesforce data refresh), delete `project/input_postman/{api}-seed-payloads.json` and re-run `/use-testdata`.
- Multiple APIs can each have their own seed-payload file. The Postman agent loads only the file matching the API it is generating for.
