%dw 2.0
/**
 * p-create-record-response.dwl
 *
 * Maps the Salesforce SaveResult (stored in vars.recordResponse) to the
 * outbound API create response body.
 *
 * Input:  vars.recordResponse — result of execute-sf-create-flow
 * Output: application/json
 *
 * Pattern mirrors p-set-create-leads-response.dwl from sfl-crm-persona-sys-api.
 * Extend with additional fields returned from secondary queries if required
 * (e.g., the reference project also retrieves an IndividualId after lead creation).
 */
output application/json
---
{
    "id": vars.recordResponse.items[0].payload.id
}
