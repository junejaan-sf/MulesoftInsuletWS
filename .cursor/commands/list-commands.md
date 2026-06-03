# /list-commands

Print all available workspace commands with a one-line description, and flag any drift between this file and `.cursor/commands/`.

## Action (exactly two steps — do not read individual command files)

### Step 1 — drift check (one shell call)

Run this single command:

```bash
for f in .cursor/commands/*.md; do
  n=$(basename "$f" .md)
  [ "$n" = "README" ] && continue
  [ "$n" = "list-commands" ] && continue
  echo "$n"
done | sort
```

Compare its output to the **EXPECTED** set below. If they match, skip the warning. If they differ, prepend a `> ⚠ Drift detected` callout listing:
- **Added** (in folder, not in EXPECTED) — these are missing from the table.
- **Removed** (in EXPECTED, not in folder) — these are stale rows in the table.

Then advise the user to update the EXPECTED list and the TABLE below.

### Step 2 — print the table

Print the TABLE below verbatim (after the warning callout, if any). Nothing else.

---

## EXPECTED

```
use-build
use-develop
use-docs
use-munit
use-postman
use-raml
use-raml-from-jira
use-raml-to-exchange
use-regression
use-review
```

## TABLE

| Command | Description |
|---------|-------------|
| `/list-commands` | Show every available command in this workspace with a one-line description. |
| `/use-build` | Build Validator — auto-detects mvn package vs test phase and auto-fixes common build/MUnit failures. |
| `/use-develop` | Generate Mule flows, sub-flows, and DataWeave from JIRA story, Confluence design, and RAML in `project/input_develop/`. |
| `/use-docs` | Produce a Confluence-ready HTML doc and Word fallback for a Mule project. |
| `/use-munit` | Generate MUnit test suites for Mule XML flows, optionally seeded by JIRA + Confluence context. |
| `/use-postman` | Generate a Postman collection for an API from RAML/OpenAPI specs and MUnit fixtures. |
| `/use-raml` | Generate or update a RAML API spec from a design doc, existing spec, or chat description. |
| `/use-raml-from-jira` | Generate a RAML spec by fetching a JIRA story and its linked Confluence design page. |
| `/use-raml-to-exchange` | Fetch JIRA + Confluence, generate/update the RAML spec, upgrade common-fragment-library, then publish to Anypoint Exchange. |
| `/use-regression` | Run a Postman collection from `agents/postman/examples/` as a regression suite and write HTML + JSON reports. |
| `/use-review` | Code Review — evaluate a Mule project against the consolidated implementation ruleset and report CRITICAL/MAJOR/MINOR findings. |

---

<!--
MAINTENANCE — when you add/remove/rename a command:
1. Update the EXPECTED list above (one slug per line, sorted).
2. Add/remove/rename the matching row in TABLE (keep alphabetical).
The Step-1 drift check will flag mismatches automatically until you do.
-->
