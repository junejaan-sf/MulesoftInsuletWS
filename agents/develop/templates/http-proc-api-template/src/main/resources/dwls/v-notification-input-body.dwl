%dw 2.0
output application/json
/**
 * Notification connector input body.
 * Used by send-notification-sub-flow (add to common-utility.xml if notification alerting is required).
 */
var ctx = vars.requestContext default {}
var err = vars.errorDetails default error
---
{
	"domain": p('app.name'),
	"environment": p('mule.env'),
	"transactionId": correlationId,
	"timestamp": now() as String,
	"message": err.description default "Error Received in API",
	"customProperties": {
		"Error Code": vars.httpStatus
	}
}
