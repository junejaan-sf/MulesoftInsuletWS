%dw 2.0
/**
 * p-create-record-request.dwl
 *
 * Maps the incoming POST /records request body to a Salesforce sObject array
 * suitable for the create connector operation.
 *
 * Input:
 *   payload          — deserialized request body from the HTTP Listener
 *   vars.recordCreationRecordTypeId — RecordType Id fetched from ObjectStore cache
 *
 * Output: application/java — Array<Object> required by the SF create connector
 *
 * Pattern mirrors p-create-lead-request.dwl from sfl-crm-persona-sys-api:
 *   - RecordTypeId always included from vars
 *   - All optional fields use conditional inclusion: (field) if (!isEmpty(value))
 *   - filterObject strips any remaining null values at the end
 *
 * Replace field names with the actual sObject API names for your implementation.
 */
output application/java
---
[
    {
        "RecordTypeId": vars.recordCreationRecordTypeId,
        "Name": payload.name,
        ("ExternalId__c":  payload.externalId)  if (!isEmpty(payload.externalId)),
        ("Status__c":      payload.status)       if (!isEmpty(payload.status)),
        ("Description":    payload.description)  if (!isEmpty(payload.description)),
        ("OwnerId":        payload.ownerId)       if (!isEmpty(payload.ownerId))
    } filterObject ((value, key) -> value != null)
]
