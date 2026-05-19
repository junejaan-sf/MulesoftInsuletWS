%dw 2.0
output application/json

/**
 * Readiness response for GET /health-check.
 * Reads payload set by healthcheck-sub-flow — if the try scope
 * succeeded the payload is a timestamp string (SF is up);
 * if the error handler ran it set { name, status: "down" }.
 *
 * Output shape:
 *   { apiName, version, correlationId, timestamp, status, dependencies[{ name, status }] }
 */
var isDown = if (payload is Object)
                (payload.status != null and (payload.status == p('message.systemDown')))
             else
                false

var apiStatusValue = if (isDown) p('message.systemsNotReady') else p('message.systemsReady')

---
{
    apiName:       Mule::p('app.name'),
    version:       p('app.version'),
    correlationId: correlationId,
    timestamp:     now() >> Mule::p('timezone'),
    status:        apiStatusValue,
    dependencies: [{
        "name":   p('targetSystem'),
        "status": if (isDown) p('message.systemDown') else p('message.systemsReady')
    }]
}
