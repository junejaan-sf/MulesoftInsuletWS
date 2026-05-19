%dw 2.0
output application/json
/**
 * targetApiParams for the secondary SAPI optional call in scatter-gather Route A.
 *
 * Replace "secondary.sapi" with your actual secondary SAPI property prefix.
 * Rename this file to v-{your-secondary-operation}-params.dwl.
 * Duplicate and rename for tertiary or additional operations if needed.
 */
var originalPayload = vars.requestContext.originalPayload default {}
---
{
	requestMethod: Mule::p('secondary.sapi.operation.method'),
	requestPath: Mule::p('secondary.sapi.operation.path'),
	requestProtocol: Mule::p('secondary.sapi.protocol'),
	requestHost: Mule::p('secondary.sapi.host'),
	requestPort: Mule::p('secondary.sapi.port'),
	requestBasePath: Mule::p('secondary.sapi.basePath'),
	// Adjust requestPayload to include only the fields required by the secondary SAPI.
	// Replace "optionalItems" with the actual field name from the inbound request payload.
	requestPayload: originalPayload.optionalItems default [],
	headers: {
		"x-request-id": correlationId,
		"client_id": Mule::p("secondary.sapi.client_id") default "",
		"client_secret": Mule::p("secondary.sapi.client_secret") default "",
		"sourceSystem": vars.requestContext.sourceSystem default "",
		"targetSystem": vars.requestContext.targetSystem default ""
	},
	uriParams: {},
	queryParams: {}
}
