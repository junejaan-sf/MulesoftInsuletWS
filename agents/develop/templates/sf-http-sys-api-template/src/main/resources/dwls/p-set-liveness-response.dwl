%dw 2.0
output application/json
---
/**
 * Liveness response for GET /ping.
 * No downstream calls — always returns "alive" if app is running.
 *
 * Output shape:
 *   { apiName, version, correlationId, timestamp, status: "alive" }
 */
{
    apiName:       p('app.name'),
    version:       p('app.version'),
    correlationId: correlationId,
    timestamp:     now() >> Mule::p('timezone'),
    status:        p('message.systemsAlive')
}
