/**
 * p-request-context-vars-mq.dwl
 * Resolves the request context inside mq-consumer-sub-flow.
 * Called after Step 1 (mqAckToken/deliveryCount/transactionId/messageId captured from attributes).
 *
 * Exact consents-proc-api pattern:
 *   headers/queryParams/uriParams — from MQ attributes (may be empty, safe to default)
 *   originalPayload — preserved for error handler and DLQ
 *   sourceSystem/targetSystem — from MQ message properties, fallback to config
 *   entityDetails.replayId — from MQ message property (null for standard queues)
 *   entityDetails.transactionId — from MQ correlationId property or Mule correlationId
 *   entityDetails.messageId — MQ message identifier
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
        replayId: attributes.properties.replayId default null,
        transactionId: vars.transactionId default correlationId,
        messageId: vars.messageId default ""
    } else null
}
