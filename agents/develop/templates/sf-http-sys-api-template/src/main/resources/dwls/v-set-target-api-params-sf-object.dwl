%dw 2.0
/**
 * v-set-target-api-params-sf-object.dwl
 *
 * Sets the targetApiParams variable consumed by execute-sf-create-flow
 * to identify which Salesforce sObject to write to.
 *
 * Output: application/json — { sfObject: String }
 *
 * Pattern mirrors v-set-target-api-params-lead-object.dwl from sfl-crm-persona-sys-api.
 * The sfObject value is read from config.properties (sfl.sfObjectName).
 */
output application/json
---
{
    sfObject: Mule::p('sfl.sfObjectName')
}
