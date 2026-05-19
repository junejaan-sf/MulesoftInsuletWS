%dw 2.0
/**
 * p-update-record-response.dwl
 *
 * Maps the Salesforce UpsertResult to the outbound API update response body.
 *
 * Input:  payload — result of execute-sf-upsert-flow (SaveResult array)
 * Output: application/json
 *
 * Pattern mirrors p-update-provider-account-response.dwl from sfl-crm-persona-sys-api.
 * Extend with additional fields if the API contract requires more than the updated Id.
 */
output application/json
---
{
    "id": payload.items.id[0] default ""
}
