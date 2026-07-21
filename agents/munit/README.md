# MUnit Agent

Generates comprehensive MUnit 2.x test suites for MuleSoft APIs — covering happy path, error scenarios, and edge cases — with mocks for all external connectors (HTTP, Anypoint MQ, Salesforce, Database, etc.).

## Activate

Type `/use-munit` in a new Cursor chat.

## Folder Structure

```
munit/
├── rules/
│   ├── intent-gen-munit.mdc          ← main entry point
│   └── gen-munit-implementation.mdc  ← full MUnit generation standards
├── examples/                          ← reference MUnit test suites
├── templates/                         ← MUnit XML and test data templates
└── README.md
```

## Inputs → `project/input_munit/`

Place any of these before running `/use-munit`:
- Mule XML flow files (`src/main/mule/*.xml`) from the generated project
- The full Mule project root (reference via `@<project-path>/` in chat)
- RAML spec for endpoint-driven test scenario coverage

If the folder is empty, @mention the target project directly in chat.

**Additional context (optional) → `project/input_develop/`**

If `jira-*.md` and `confluence-design.md` are present in `project/input_develop/` (produced by `/use-develop` or `/use-raml-from-jira`), the agent automatically reads them to:
- Derive test cases directly from JIRA acceptance criteria
- Identify downstream systems and set up the correct mocks
- Populate fixture JSON with realistic field values from the Confluence design

## Outputs → `project/output_munit/` or in-project `src/test/munit/`

```
src/test/munit/
└── {flow-name}-test-suite.xml

src/test/resources/
└── testdata/
    └── {suite}/
        ├── business-inbound/
        └── business-outbound/
```

## Tips

- The agent analyzes your flow files to identify all endpoints, connectors, and error paths before generating tests
- Mocks are created for every external dependency — no real connections are required to run tests
- Store secrets in `~/.zshrc` and reference via `${VAR}` — never hardcode credentials in test config
- MUnit test output feeds directly into the Postman agent for fixture-based collection generation
