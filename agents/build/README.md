# Build Validator Agent

Self-healing Maven runner that validates the output of `/use-develop` and `/use-munit`. Runs `mvn clean package` and `mvn clean test` with the canonical Insulet VM args, classifies build/test failures, applies targeted patches, and iterates until the build is green or the attempt ceiling is reached.

## Activate

Type `/use-build` in a new Cursor chat.

## Folder Structure

```
build/
├── rules/
│   ├── intent-build.mdc              ← main entry point (trigger phrases + procedure)
│   └── build-implementation.mdc      ← VM-arg gate, secrets file, error catalog, fix recipes
├── examples/
│   ├── success-run.log               ← sample green build (package phase)
│   └── escalation-run.log            ← sample escalation (MUnit assertion failure)
└── README.md
```

## When to Run

| After this agent | Run this phase |
|------------------|---------------|
| `/use-develop`   | `package` — validates all Mule XML, DWL, POM |
| `/use-munit`     | `test` — runs full MUnit suite |

## Secrets Setup (one-time per project)

VM args (Azure + Anypoint creds) are loaded from a `chmod 600` file **outside the workspace**:

```
~/.insulet-mule/vmargs/{project}.properties
```

On the **first run** against a new project, the agent writes the template with empty values and stops — fill it in once, then re-run.

Override the path via `INSULET_VMARGS_FILE` for CI or alternative machines.

**Never commit this file. Never paste its contents into chat.**

## Canonical VM Args (Insulet standard)

```bash
# test phase
mvn clean test \
  -Dmule.env=dev \
  -Danypoint.platform.gatekeeper=disabled \
  -Danypoint.platform.client_id=... \
  -Danypoint.platform.client_secret=... \
  -DAZURE_TENANT_ID=... \
  -DAZURE_CLIENT_ID=... \
  -DAZURE_CLIENT_SECRET=... \
  -DMULE_AZURE_KEY_VAULT_NAME=...

# package phase — same 8 flags, just -DskipTests
mvn clean package -DskipTests <same flags>
```

## Auto-fix Classes (Balanced Mode)

| Error class | Auto-fix |
|---|---|
| Mule XML schema / namespace / flow-ref | yes |
| POM missing dep / version conflict | yes |
| Property key missing in env file | yes |
| DWL compile (import, cast, default) | yes |
| MUnit mock shape / namespace prefix | yes |
| Connector config missing required attr | yes |
| MUnit assertion logic failure | **escalate** |
| Credential / Azure Key Vault / TLS error | **escalate** |

## Outputs → `project/output_build/`

```
project/output_build/
├── {project}-{phase}-{timestamp}.log          ← combined run log (redacted)
├── {project}-{phase}-fixes.md                 ← before/after diff per attempt
└── {project}-{phase}-summary.json             ← { status, attempts, fixes_applied[], unresolved[] }
```

All logs are redacted against the loaded secret values before being written or shown in chat.

## Tips

- One agent per chat — start a new chat with `/use-build` for each validation run
- Default env is `dev`; say "use local" or "use qa" to override
- Say "use 10 attempts" to raise the ceiling; say "run package" or "run tests" to skip phase detection
- Never pass secret values in chat — the agent reads them from the secrets file only
- Never enable `mvn -X` unless you've reviewed the redaction behavior; verbose Maven output leaks more surface
