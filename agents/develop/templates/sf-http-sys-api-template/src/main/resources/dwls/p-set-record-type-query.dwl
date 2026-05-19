%dw 2.0
output application/json
/**
 * Builds a SOQL query to retrieve all active RecordType IDs for the
 * sObjects listed in the 'recordtype.sobjects' property.
 *
 * Input:  Mule property 'recordtype.sobjects' — comma-separated sObject names
 *         e.g., "Lead,Account"
 *
 * Output: vars.queryPayload = { query: "<SOQL>" }
 *         Consumed by execute-sf-query-flow inside common-retrieve-record-type-sub-flow
 *
 * The result rows contain: Id, Name, DeveloperName, SObjectType
 * which are then stored in ObjectStore via p-set-record-type-mappings.dwl.
 */
---
{
    "query": "SELECT Id,Name,DeveloperName,SObjectType FROM RecordType WHERE IsActive=true AND SobjectType IN ('"
        ++ trim((Mule::p('recordtype.sobjects') replace "," with "','"))
        ++ "')"
}
