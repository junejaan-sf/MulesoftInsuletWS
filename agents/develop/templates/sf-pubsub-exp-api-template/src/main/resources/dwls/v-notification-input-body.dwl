%dw 2.0
output application/json
---
/*
  Notification payload shape sent to the Notification Utility API on error.
  Adjust the message, subject, and recipients per integration requirements.
*/
{
	"subject": "Integration Error: " ++ Mule::p('app.name'),
	"body": {
		"apiName": Mule::p('app.name'),
		"correlationId": correlationId,
		"errorType": (error.errorType.namespace default "UNKNOWN") ++ ":" ++ (error.errorType.identifier default "UNKNOWN"),
		"errorDescription": error.description default "An unhandled error occurred",
		"timestamp": now() as String {format: "yyyy-MM-dd'T'HH:mm:ss.SSSZ"},
		"sourceSystem": Mule::p('sourceSystem'),
		"targetSystem": Mule::p('targetSystem')
	},
	"recipients": [
		"<replace-with-notification-recipient-email>"
	]
}
