/**
 * v-targetApiParams-sfl-crm-persona-sys-api-healthcheck.dwl
 * Sets vars.targetApiParams for the health-check scatter-gather route
 * targeting sfl-crm-persona-sys-api.
 *
 * Used by: health-check-ready-sub-flow
 */
%dw 2.0
output application/json
---
{
    host: Mule::p("sfl-crm-persona-sys-api.host"),
    basePath: Mule::p("sfl-crm-persona-sys-api.basePath") default "/",
    requestMethod: Mule::p("sfl-crm-persona-sys-api.healthCheck.method"),
    requestPath: Mule::p("sfl-crm-persona-sys-api.healthCheck.path"),
    headers: {
        "x-correlation-id": correlationId,
        "client_id": Mule::p("sfl-crm-persona-sys-api.client_id"),
        "client_secret": Mule::p("sfl-crm-persona-sys-api.client_secret"),
        "sourceSystem": Mule::p("app.name"),
        "targetSystem": Mule::p("sfl-crm-persona-sys-api.name")
    },
    uriParams: {},
    queryParams: {},
    requestPayload: {}
}
