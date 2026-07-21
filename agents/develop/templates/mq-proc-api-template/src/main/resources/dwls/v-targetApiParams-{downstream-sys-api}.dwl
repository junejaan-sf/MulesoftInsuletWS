/**
 * v-targetApiParams-{downstream-sys-api}.dwl
 * Sets vars.targetApiParams for calls to the downstream sys API
 * from mq-consumer-sub-flow.
 *
 * REPLACE:
 *   - {downstream-sys-api} with the actual system API name (e.g. sfmc-consents-sys-api)
 *   - Property keys {downstream-sys-api}.* with the actual prefix
 *   - requestPayload mapping if payload transform is needed beyond p-mq-message-transform.dwl
 */
%dw 2.0
output application/json
---
{
    host: Mule::p("{downstream-sys-api}.host"),
    basePath: Mule::p("{downstream-sys-api}.basePath") default "/",
    requestMethod: Mule::p("{downstream-sys-api}.request.method"),
    requestPath: Mule::p("{downstream-sys-api}.request.path"),
    headers: {
        "x-correlation-id": correlationId,
        "client_id": Mule::p("{downstream-sys-api}.client_id"),
        "client_secret": Mule::p("{downstream-sys-api}.client_secret"),
        "sourceSystem": vars.requestContext.sourceSystem default Mule::p("app.name"),
        "targetSystem": Mule::p("{downstream-sys-api}.name")
    },
    uriParams: {},
    queryParams: {},
    requestPayload: payload
}
