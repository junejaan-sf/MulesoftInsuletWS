%dw 2.0
/**
 * p-get-records-query.dwl
 *
 * Builds the SOQL query string for the GET /records operation.
 * The result is stored in vars.queryPayload and passed to execute-sf-query-flow.
 *
 * Input:  attributes.queryParams — HTTP query parameters from the request
 * Output: application/json — { "query": String }
 *
 * Pattern mirrors p-set-provider-accounts-query.dwl from sfl-crm-persona-sys-api:
 *   - Base query read from config.properties (sfl.getRecordsQuery)
 *   - Dynamic WHERE/AND clauses appended from query params using string concatenation
 *   - Conditional clauses use inline if/else to keep the query clean
 *
 * Replace the field names and query param keys with those for your sObject.
 */
output application/json
---
{
    "query": Mule::p('sfl.getRecordsQuery')
        ++ (if (!isBlank(attributes.queryParams.externalId default ""))
                " AND ExternalId__c = '" ++ attributes.queryParams.externalId ++ "'"
            else "")
        ++ (if (!isBlank(attributes.queryParams.status default ""))
                " AND Status__c = '" ++ attributes.queryParams.status ++ "'"
            else "")
}
