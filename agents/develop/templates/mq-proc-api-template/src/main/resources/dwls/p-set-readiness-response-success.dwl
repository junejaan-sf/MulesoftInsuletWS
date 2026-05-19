/**
 * p-set-readiness-response-success.dwl
 * Aggregates scatter-gather health-check results from all downstream
 * dependencies into the standard readiness response shape.
 *
 * Each scatter-gather route must produce a payload with at least:
 *   { apiName: <string>, status: <string> }
 * On route failure, the try/on-error-continue in health-check-ready.xml
 * sets { apiName: p('<system>.name'), status: p('message.systemDown') }.
 *
 * statusValue logic:
 *   If any dependency status is neither "up" nor "ready" → systemsNotReady
 *   Otherwise → systemsReady
 *
 * Exact consents-proc-api pattern.
 */
%dw 2.0
import * from dw::core::Arrays
output application/json
var statusValue =
    if (
        (payload pluck (value, key, index) -> value.payload.status)
            some (($ != p("message.systemUp")) and ($ != p("message.systemsReady")))
    )
        p("message.systemsNotReady")
    else
        p("message.systemsReady")
---
{
    apiName: p("app.name"),
    version: p("app.version"),
    correlationId: correlationId,
    timestamp: now() >> p("timezone"),
    dependencies: (payload pluck {
        name: ($.payload.apiName default $.payload.name),
        status: $.payload.status
    }),
    status: statusValue
}
