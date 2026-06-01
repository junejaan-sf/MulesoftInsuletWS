# Regression / Integration Test Agent

@agents/regression/rules/intent-run-regression.mdc
@agents/regression/rules/run-regression-implementation.mdc

---

**Collections available:** `agents/postman/examples/`

The agent will scan for `*.postman_collection.json` files in `agents/postman/examples/` and ask you which one to run if more than one is found.

**Before running**, open the target collection file and ensure the `variable` array has non-empty values for:
- `anypoint_client_id`
- `anypoint_client_secret`

The agent will validate these are set and stop with instructions if they are missing or placeholder.

**Output will be written to:** `project/output_regression/{api-name}-{ENV}-{timestamp}.html` and `.json`

> One agent per chat. Start a new chat with `/use-regression` for each new test run.
> Never hardcode `client_id` or `client_secret` in any file — set them in the collection's Variables tab only.
