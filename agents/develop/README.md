# Develop Agent

Generates complete MuleSoft 4 applications from a RAML spec or technical design — including Mule XML flows, DataWeave transformations, global config, error handlers, property files, and POM — following Insulet implementation standards.

## Activate

Type `/use-develop` in a new Cursor chat.

## Folder Structure

```
develop/
├── rules/
│   ├── intent-gen-mule.mdc              ← main entry point
│   └── implementation-ruleset_v4.mdc   ← full Mule 4 generation standards
├── examples/                            ← Mule app templates and reference projects
├── templates/
│   ├── sf-http-sys-api-template/       ← HTTP listener system API template (add when available)
│   ├── mq-proc-api-template/           ← Anypoint MQ consumer process API template (add when available)
│   └── sf-pubsub-exp-api-template/     ← Salesforce Pub/Sub experience API template (add when available)
└── README.md
```

## Inputs → `project/input_develop/`

Place any of these before running `/use-develop`:
- RAML or OpenAPI spec (`.raml`, `.yaml`) — primary driver
- Technical design document (`.md`, `.txt`) with flow and connector details
- Sample payloads (`.json`) for accurate DataWeave transformations
- Field mapping tables (`.md`) for source-to-target mappings

The agent also auto-generates two context files into this folder when started from `/use-raml-from-jira`:
- `jira-{STORY-ID}.md` — JIRA story requirements, acceptance criteria, technical notes
- `confluence-design.md` — endpoint definitions, field mappings, downstream system details

These files are shared across agents — `/use-munit` and `/use-postman` both check this folder automatically to enrich their output.

If the folder is empty, describe the requirements directly in chat.

## Outputs → `project/output_develop/`

A complete Mule project structure:

```
{project-name}/
├── src/main/mule/
│   ├── {api-name}-spec.xml
│   ├── implementation/
│   └── common/
├── src/main/resources/
│   ├── dwls/
│   ├── errors/
│   └── properties/
├── src/test/munit/
└── pom.xml
```

## Adding Templates

Drop Mule project templates into `templates/` and `examples/`. The ruleset in `implementation-ruleset_v4.mdc` will reference them automatically once placed at:
- `agents/develop/templates/sf-http-sys-api-template/`
- `agents/develop/templates/mq-proc-api-template/`
- `agents/develop/templates/sf-pubsub-exp-api-template/`

## Handoff

Output project → use `/use-munit`, `/use-postman`, `/use-docs`, and `/use-review` in separate chats.

## Ruleset Standards (`implementation-ruleset_v4.mdc`)

Key standards enforced during generation:

| Area | Standard |
|------|----------|
| `mule-artifact.json` | `minMuleVersion: 4.9.0`, `javaSpecificationVersions: ["17"]`, no `secureProperties` when using Azure Key Vault |
| Property files | Required common keys: `timezone=EST`, `tier=Process`, `http.port`, `http.timeout`, `reconnection.frequency`, `reconnection.attempts`, `ie.resolvedFlag`, `ie.transactionType` |
| Health check messages | Lowercase values: `message.systemUp=up`, `message.systemDown=down`, `message.systemsAlive=alive`, `message.systemsReady=ready`, `message.systemsNotReady=not ready` |
| Logger | `logger.sensitiveKeyParts` — comprehensive 32-item PII list; `logger.safeKeys` — standard correlation IDs + app-specific non-PII entity IDs |
| Readiness DWL | `p-set-readiness-response-success.dwl` — scatter-gather payload wrapper via `(value.payload default value)`, includes `apiName`, `version`, `correlationId`, `timestamp` |
| Liveness DWL | `p-set-liveness-response.dwl` — uses `Mule::p(...)`, includes `apiName`, `version`, `correlationId`, `timestamp`, `status` |
| Retry | `retry.attempts=3` (not 2) |

## Tips

- Always provide the RAML spec for accurate connector configuration and DataWeave generation
- Store secrets in `~/.zshrc` and reference via `${VAR}` in Maven commands — never pass credentials directly
- The agent also reads all `review-*.mdc` standards during generation to pre-empt review findings
