/**
 * v-targetApiParams-{downstream-sys-api}-healthcheck.dwl
 * Sets vars.targetApiParams for the health-check scatter-gather route
 * targeting the downstream sys API.
 *
 * REPLACE {downstream-sys-api} with the actual system API name.
 */
%dw 2.0
output application/json
---
{
    host: Mule::p("{downstream-sys-api}.host"),
    basePath: Mule::p("{downstream-sys-api}.basePath") default "/",
    requestMethod: Mule::p("{downstream-sys-api}.healthCheck.method"),
    requestPath: Mule::p("{downstream-sys-api}.healthCheck.path"),
    headers: {
        "x-correlation-id": correlationId,
        "client_id": Mule::p("{downstream-sys-api}.client_id"),
        "client_secret": Mule::p("{downstream-sys-api}.client_secret"),
        "sourceSystem": Mule::p("app.name"),
        "targetSystem": Mule::p("{downstream-sys-api}.name")
    },
    uriParams: {},
    queryParams: {},
    requestPayload: {}
}
