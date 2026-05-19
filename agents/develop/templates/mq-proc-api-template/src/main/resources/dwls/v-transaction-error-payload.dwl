/**
 * v-transaction-error-payload.dwl
 * Constructs the integration error record for sfl-crm-persona-sys-api.
 * Shape matches the transaction-errors API contract.
 *
 * Set vars.transactionErrorRequest before calling
 * common-log-integration-error-details-sub-flow.
 *
 * resolvedFlag: always false on create (controlled by ie.resolvedStatus property)
 */
%dw 2.0
output application/json
---
{
    muleAppName: app.name,
    muleCorrelationId: correlationId,
    transactionId: vars.requestContext.entityDetails.transactionId default correlationId,
    errorTimestamp: now() as String {format: "yyyy-MM-dd'T'HH:mm:ss.SSSZ"},
    errorMessage: (
        vars.errorCode as String default ""
    ) ++ " - " ++ (
        vars.errorMessage default
        error.description default
        "Processing error"
    ),
    payloadData: vars.originalPayload default payload,
    resolvedFlag: Mule::p('ie.resolvedStatus') as Boolean default false,
    errorType: (
        (error.errorType.namespace default "UNKNOWN") ++
        ":" ++
        (error.errorType.identifier default "UNKNOWN")
    ),
    sourceSystem: vars.requestContext.sourceSystem default Mule::p('sourceSystem'),
    targetSystem: vars.requestContext.targetSystem default Mule::p('targetSystem')
}
