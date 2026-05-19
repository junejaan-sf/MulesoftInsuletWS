/**
 * p-set-common-success-response.dwl
 * Standard success response payload used by success-response-sub-flow.
 * Sets HTTP status 200 and wraps the downstream response.
 */
%dw 2.0
output application/json
---
{
    status: "success",
    message: "Message processed successfully",
    correlationId: correlationId,
    transactionId: vars.requestContext.entityDetails.transactionId default correlationId
}
