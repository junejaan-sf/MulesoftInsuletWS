/**
 * v-notification-input-body.dwl
 * Builds the payload for send-notification-sub-flow.
 * Adjust recipients, subject, and body format to match your notification API contract.
 */
%dw 2.0
output application/json
---
{
    subject: "Error in " ++ app.name ++ " [" ++ Mule::p('mule.env') ++ "]",
    body: "An unrecoverable error occurred in " ++ app.name ++ ".\n\n"
        ++ "CorrelationId: " ++ correlationId ++ "\n"
        ++ "TransactionId: " ++ (vars.requestContext.entityDetails.transactionId default "N/A") ++ "\n"
        ++ "ErrorType: " ++ ((error.errorType.namespace default "UNKNOWN") ++ ":" ++ (error.errorType.identifier default "UNKNOWN")) ++ "\n"
        ++ "ErrorMessage: " ++ (error.description default "N/A") ++ "\n"
        ++ "Environment: " ++ Mule::p('mule.env') ++ "\n"
        ++ "Timestamp: " ++ (now() as String {format: "yyyy-MM-dd'T'HH:mm:ss.SSSZ"}),
    recipients: [Mule::p('notification.recipient.email')],
    priority: "HIGH"
}
