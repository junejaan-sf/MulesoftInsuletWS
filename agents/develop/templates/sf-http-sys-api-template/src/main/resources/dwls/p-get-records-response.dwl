%dw 2.0
/**
 * p-get-records-response.dwl
 *
 * Maps the Salesforce SOQL query result array to the outbound API response body.
 *
 * Input:  payload — array of sObject records returned by execute-sf-query-flow
 * Output: application/json — Array<Object>
 *
 * Pattern mirrors p-set-provider-accounts-output-response.dwl from sfl-crm-persona-sys-api:
 *   - Uses `payload map (item, index) -> { ... }` to iterate records
 *   - Maps SF field API names to API-contract camelCase field names
 *
 * Replace the field mappings with the actual sObject fields for your implementation.
 */
output application/json
---
payload map (item, index) -> {
    id:          item.Id,
    name:        item.Name,
    externalId:  item.ExternalId__c,
    status:      item.Status__c
}
