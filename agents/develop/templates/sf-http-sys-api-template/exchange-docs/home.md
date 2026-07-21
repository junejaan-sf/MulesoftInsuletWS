# sf-http-sys-api-template

Template skeleton for a MuleSoft Salesforce HTTP synchronous system API.

## Patterns Covered
- HTTP synchronous REST endpoints (POST, GET, PUT) via APIKit
- Salesforce standard connector: `create`, `query`, `upsert`, `update`, `get-server-timestamp`
- Salesforce composite connector: `execute-composite-request`
- ObjectStore RecordType ID caching
- Azure Key Vault for all secrets
- Insulet Custom Logger Connector (INFO without-payload + DEBUG encrypted)
- Global error handler with Salesforce-specific error mappings

## How to Use
1. Rename all `{resource}` placeholders to your target entity (e.g., `patient`, `provider`)
2. Replace `{sf-object}` with the Salesforce sObject name (e.g., `Lead`, `Account`)
3. Update `global-config.xml` with the correct APIKit RAML version and API ID
4. Fill in DWL stubs with actual field mappings
5. Update `config.properties` and env-specific properties for your org
