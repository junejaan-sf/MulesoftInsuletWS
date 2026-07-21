# http-proc-api-template

Scaffold template for a synchronous HTTP Process API (Pattern 3.1 — proc layer).

## Pattern Overview

This template demonstrates the standard Insulet proc-API orchestration pattern:

1. **Primary SAPI call** — synchronous HTTP request to `{downstream-sys-api}` (the core business operation).
2. **Scatter-gather** — parallel execution of two optional downstream calls, each guarded by a `<choice>` element so either or both can be skipped based on the request payload.
3. **Async error logging** — all errors are asynchronously logged to `sfl-crm-persona-sys-api /transactions-errors` via `async-error-flow-sub-flow`.
4. **Dynamic outbound config** — a single `outbound-sapi-http-request_config` resolves `host`, `port`, and `basePath` from `vars.targetApiParams` at runtime; all downstream SAPIs share this one config.

## Placeholder Tokens (replace globally before use)

| Token | Replace With | Example |
|---|---|---|
| `{api-name}` | API artifact ID | `accounts-proc-api` |
| `{api-spec}` | RAML spec artifact ID | `accounts-proc-api-spec` |
| `{api-spec-artifact-id}` | RAML spec artifact ID (pom.xml) | `accounts-proc-api-spec` |
| `{api-version}` | RAML spec version | `1.0.1` |
| `{operation}` | Main business operation name | `update-provider-account` |
| `{operation-http-method}` | HTTP method for main operation | `PUT` |
| `{operation-path}` | APIKit path segment (with parentheses for params) | `providers\accounts\(id)` |
| `{downstream-sys-api}` | Primary downstream system API name | `sfl-crm-persona-sys-api` |
| `{secondary-sys-api}` | Optional secondary downstream SAPI (scatter-gather route A) | `sfl-consents-sys-api` |
| `{secondary-operation}` | Sub-flow name for secondary SAPI | `query-and-update-consent` |
| `{tertiary-sys-api}` | Optional tertiary downstream SAPI (scatter-gather route B) | `sfl-campaigns-sys-api` |
| `{tertiary-operation}` | Sub-flow name for tertiary SAPI | `create-campaign-member` |
| `{source-system}` | Inbound source system name | `Drupal` |
| `{target-system}` | Outbound target system name | `Salesforce` |

## Files to Create After Scaffold

After replacing placeholder tokens, add the following implementation-specific files:

- `implementation/{secondary-operation}.xml` — secondary SAPI sub-flow (e.g., consents GET + PUT)
- `implementation/{tertiary-operation}.xml` — tertiary SAPI sub-flow (e.g., campaign membership POST)
- `dwls/v-{secondary-operation}-params.dwl` — targetApiParams for secondary operation
- `dwls/v-{tertiary-operation}-params.dwl` — targetApiParams for tertiary operation
- Corresponding MUnit test data in `src/test/resources/testdata/`
