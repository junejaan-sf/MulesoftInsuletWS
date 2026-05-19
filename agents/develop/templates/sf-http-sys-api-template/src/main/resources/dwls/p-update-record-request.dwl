%dw 2.0
/**
 * p-update-record-request.dwl
 *
 * Maps the PUT /records/{id} request body + URI parameter to a Salesforce
 * sObject array suitable for the upsert connector operation.
 *
 * Input:
 *   payload               — deserialized request body from the HTTP Listener
 *   attributes.uriParams  — URI parameters (contains 'id')
 *
 * Output: application/java — Array<Object> required by the SF upsert connector
 *
 * Pattern mirrors p-update-provider-account-request.dwl from sfl-crm-persona-sys-api:
 *   - SF record Id always included from uriParams
 *   - Optional fields use conditional inclusion: (field) if (!isEmpty(value))
 *
 * Replace field names with the actual sObject API names for your implementation.
 */
output application/java
---
[
    {
        "Id": attributes.uriParams.'id',
        ("Name":         payload.name)        if (!isEmpty(payload.name)),
        ("Status__c":    payload.status)      if (!isEmpty(payload.status)),
        ("Description":  payload.description) if (!isEmpty(payload.description))
    }
]
