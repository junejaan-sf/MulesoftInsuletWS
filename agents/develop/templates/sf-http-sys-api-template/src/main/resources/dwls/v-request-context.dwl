%dw 2.0
output application/java
---
/**
 * Sets vars.requestContext at the main flow entry point.
 * Values are consumed by all loggers (sourceSystem, targetSystem)
 * and by error handlers (originalPayload).
 *
 * Input:  HTTP listener attributes + properties
 * Output: vars.requestContext (Java Map)
 */
{
    headers:         attributes.headers default {},
    queryParams:     attributes.queryParams default {},
    uriParams:       attributes.uriParams default {},
    originalPayload: payload default "",
    requestPath:     attributes.requestPath,
    // sourceSystem: prefer inbound header; fall back to property
    sourceSystem:    attributes.headers.sourceSystem default Mule::p('sourceSystem'),
    targetSystem:    Mule::p('targetSystem')
}
