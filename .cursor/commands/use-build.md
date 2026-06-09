Build Validator — auto-detect mvn package vs test phase and auto-fix common build/MUnit failures.

# Build Validator Agent

@agents/build/rules/intent-build.mdc
@agents/build/rules/build-implementation.mdc

---

**Target project:** `project/output_develop/` (auto-detected; asks if multiple projects present)

The agent auto-detects the build phase:
- If MUnit test files exist in the project → defaults to **test** phase (`mvn clean test`)
- Otherwise → defaults to **package** phase (`mvn clean package -DskipTests`)

Say "run package" or "run tests" to override detection. Say "use qa" or "use local" to override the default env (`dev`).

**Secrets:** VM args are loaded from `~/.insulet-mule/vmargs/{project}.properties` (chmod 600, outside the workspace). On first run the agent writes the template with empty values and stops — fill in the 6 keys once, then re-run.

Override the secrets file path: `export INSULET_VMARGS_FILE=/path/to/file`

**The agent will never ask you to paste secret values into chat.**

**Auto-fix classes (balanced mode):**
- Mule XML schema / namespace / flow-ref errors
- POM missing dependency / version conflict
- Property key missing in env files
- DataWeave compile errors (import, cast, default)
- MUnit mock shape / namespace prefix mismatch
- Connector config missing required attribute

**Always escalated (no auto-patch):**
- MUnit assertion logic failures
- Credential / Azure Key Vault / TLS errors

**Output will be written to:** `project/output_build/`
- `{project}-{phase}-{timestamp}.log` — combined run log (redacted)
- `{project}-{phase}-fixes.md` — before/after diff for each patch applied
- `{project}-{phase}-summary.json` — machine-readable result

> One agent per chat. Start a new chat with `/use-build` for each validation run.
> Never modify credential plumbing — those errors always escalate to you.
> Never commit or paste contents of the secrets file.
