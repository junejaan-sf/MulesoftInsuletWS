# RAML Agent

Generates production-ready RAML 1.0 or OpenAPI 3.0 API specifications following Insulet API-Led Connectivity patterns, CommonLib usage, naming conventions, and exchange module standards.

## Activate

| What you have | Command |
|---------------|---------|
| Design doc, requirements, or chat description | `/use-raml` |
| JIRA story ID — generate locally | `/use-raml-from-jira` |
| JIRA story ID — generate + publish to Exchange | `/use-raml-to-exchange` |

## Folder Structure

```
raml/
├── rules/
│   ├── intent-gen-raml.mdc                     ← main entry point
│   ├── intent-gen-raml-from-jira.mdc           ← JIRA story → RAML workflow
│   ├── intent-gen-raml-from-jira-to-exchange.mdc ← JIRA → RAML → Exchange publish
│   └── gen-raml-implementation.mdc             ← full generation standards
├── examples/
│   ├── common-fragment-library/                ← shared RAML traits and types
│   └── sfl-test-consents-sys-api/             ← reference API spec
├── templates/                                  ← RAML structure templates
└── README.md
```

## Inputs → `project/input_raml/`

Place any of these before running `/use-raml`:
- Technical design document (`.md`, `.txt`)
- Existing RAML spec to update or extend

For JIRA-driven workflows, no input folder needed — use `/use-raml-from-jira` or `/use-raml-to-exchange` and provide the story ID directly in chat.

If the folder is empty, describe the API requirements directly in chat.

## Outputs → `agents/raml/examples/{api-spec-name}/`

Generated specs are placed in the `examples/` folder as siblings of the reference specs:

```
agents/raml/examples/
└── {api-spec-name}/
    ├── {api-spec-name}.raml
    ├── dataTypes/
    ├── examples/
    └── exchange_modules/
```

## Handoff to Develop Agent

Copy the generated spec to start the development agent:
`agents/raml/examples/{api-spec-name}/` → copy root RAML to `project/input_develop/`

## Tips

- The `common-fragment-library` in `examples/` contains shared traits — the ruleset references these automatically
- For JIRA-driven specs, use `/use-raml-from-jira` — it fetches the story, Confluence design page, and all field mappings automatically without any manual file prep
- API layer suffix is mandatory: `-sys-api-spec`, `-prc-api-spec`, or `-exp-api-spec`
