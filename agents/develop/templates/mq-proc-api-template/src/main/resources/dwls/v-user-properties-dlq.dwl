/**
 * v-user-properties-dlq.dwl
 * Builds the user-property headers to attach when publishing
 * a failed message to the Dead Letter Queue.
 *
 * These properties are readable by operators to diagnose DLQ messages
 * without deserialising the body.
 */
%dw 2.0
output application/json
---
{
    "ErrorCode": vars.errorCode as String default "500",
    "ErrorMessage": vars.errorMessage default error.description default "Processing error",
    "TransactionId": vars.requestContext.entityDetails.transactionId default correlationId,
    "MessageId": vars.requestContext.entityDetails.messageId default "",
    "SourceSystem": vars.requestContext.sourceSystem default Mule::p('sourceSystem'),
    "TargetSystem": vars.requestContext.targetSystem default Mule::p('targetSystem'),
    "ErrorTimestamp": now() as String {format: "yyyy-MM-dd'T'HH:mm:ss.SSSZ"},
    "DeliveryCount": vars.deliveryCount as String default "1"
}
