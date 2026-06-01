# Insulet MuleSoft Agent Commands

Type any command in a Cursor chat to activate the corresponding agent.

## Agent Commands

| Command | Agent | Input |
|---------|-------|-------|
| `/use-raml` | RAML — from design doc or chat | `project/input_raml/` |
| `/use-raml-from-jira` | RAML — from JIRA story + Confluence | Story ID in chat |
| `/use-raml-to-exchange` | RAML — from JIRA + publish to Exchange | Story ID in chat |
| `/use-develop` | MuleSoft App Development | `project/input_develop/` |
| `/use-munit` | MUnit Test Generation | `project/input_munit/` |
| `/use-build` | Build Validator — mvn package + test, auto-fix | `project/output_develop/` |
| `/use-postman` | Postman / Integration Testing | `project/input_postman/` |
| `/use-docs` | Documentation | `project/input_docs/` |
| `/use-review` | Code Review | — (point at project via @mention) |

## How It Works

1. Place your input files in the relevant `project/input_XX/` folder before running the command
2. Type the command — the agent auto-reads the input folder and loads the ruleset
3. If the folder is empty, the agent falls back to asking you in chat
4. Review the output before using it — all AI-generated content must be validated

## Recommended Workflow

```
/use-notebooklm → extract design examples from NotebookLM notebook
/use-raml       → review RAML output
/use-develop    → review Mule app
/use-build      → validate package build (mvn clean package, auto-fix)
/use-munit      → review test suites
/use-build      → validate test run (mvn clean test, auto-fix)
/use-postman    → review collection
/use-docs       → review documentation
/use-review     → final quality gate
```

## Shared Context: `project/input_develop/`

When `/use-develop` or `/use-raml-from-jira` runs, it saves `jira-*.md` and `confluence-design.md` into `project/input_develop/`. Both `/use-munit` and `/use-postman` automatically check this folder — no extra steps needed. The richer the context files, the better the generated test cases, fixtures, and request bodies.

## Design Examples: `agents/design/examples/`


## Tips

- One agent per chat — start a new chat with the relevant command for each task
- Use Claude Sonnet (Thinking) for standard tasks; Claude Opus (Thinking) for complex ones
- Keep unrelated projects outside this workspace to improve agent focus
