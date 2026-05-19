/**
 * v-targetApiParams-sfl-crm-persona-sys-api.dwl
 * Sets vars.targetApiParams for the integration error logging call
 * to sfl-crm-persona-sys-api (transaction-errors endpoint).
 *
 * Used by: common-log-integration-error-details-sub-flow
 *
 * Expects vars.transactionErrorRequest to be set before this DWL is evaluated.
 */
%dw 2.0
output application/json
---
{
    host: Mule::p("sfl-crm-persona-sys-api.host"),
    basePath: Mule::p("sfl-crm-persona-sys-api.basePath") default "/",
    requestMethod: Mule::p("sfl-crm-persona-sys-api.transactionErrors.method"),
    requestPath: Mule::p("sfl-crm-persona-sys-api.transactionErrors.path"),
    headers: {
        "x-correlation-id": correlationId,
        "client_id": Mule::p("sfl-crm-persona-sys-api.client_id"),
        "client_secret": Mule::p("sfl-crm-persona-sys-api.client_secret"),
        "sourceSystem": vars.requestContext.sourceSystem default Mule::p("app.name"),
        "targetSystem": Mule::p("sfl-crm-persona-sys-api.name")
    },
    uriParams: {},
    queryParams: {},
    requestPayload: vars.transactionErrorRequest
}
