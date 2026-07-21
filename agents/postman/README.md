# Postman Agent

Generates Postman v2.1 collections for MuleSoft HTTP APIs — with per-environment folders (local, DEV, QA, UAT, PROD), happy path and negative scenarios, and all secrets replaced with collection variables.

## Activate

Type `/use-postman` in a new Cursor chat.

## Folder Structure

```
postman/
├── rules/
│   ├── intent-gen-postman.mdc           ← main entry point (full lookup chain)
│   └── gen-postman-implementation.mdc   ← full Postman generation standards
├── examples/                             ← reference Postman collections
├── templates/                            ← collection structure templates
└── README.md
```

## Inputs → `project/input_postman/`

Place any of these before running `/use-postman`:
- RAML or OpenAPI spec (`.raml`, `.yaml`) for the target API
- MUnit test XML files — the agent extracts request/response fixtures from these
- Or just the API name — the agent auto-locates the spec via its lookup chain

If the folder is empty, provide the API name in chat and the agent will search for the spec.

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
│   └── Negative/
├── DEV/
│   ├── Happy Path/
│   └── Negative/
...
```

## Tips

- Non-HTTP flows (MQ subscribers, schedulers, file/JMS listeners) are automatically excluded — the agent will list skipped flows in chat
- Never hardcode `client_id`, `client_secret`, or bearer tokens — always use `{{collection_variable}}` syntax
- Negative scenarios are limited to `{400, 401, 404, 500}` — only codes evidenced in your spec or MUnit tests
