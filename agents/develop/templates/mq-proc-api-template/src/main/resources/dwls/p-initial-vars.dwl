/**
 * p-initial-vars.dwl
 * Resolves the HTTP request context on entry to the main flow.
 * Sets vars.requestContext used by all downstream loggers and connectivity flows.
 *
 * Mirrors the consents-proc-api p-initial-vars.dwl shape:
 *   headers/queryParams/uriParams — passed through from HTTP attributes
 *   originalPayload — preserved for error logging
 *   sourceSystem/targetSystem — from attributes.properties fallback to config
 *   entityDetails — correlationId for HTTP flows (no transactionId/messageId)
 */
%dw 2.0
output application/java
var originalPayload = vars.originalPayload default payload default {}
---
{
    headers: attributes.headers default {},
    queryParams: attributes.queryParams default {},
    uriParams: attributes.uriParams default {},
    originalPayload: originalPayload,
    sourceSystem: attributes.properties.sourceSystem default Mule::p("sourceSystem"),
    targetSystem: attributes.properties.targetSystem default Mule::p("targetSystem"),
    entityDetails: if (originalPayload is Object) {
        correlationId: correlationId
    } else null
}
