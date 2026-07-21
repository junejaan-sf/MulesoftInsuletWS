%dw 2.0
output application/json
/**
 * targetApiParams for the primary SAPI call in the update-record operation.
 *
 * Replace "primary.sapi" with your actual SAPI property prefix
 * (e.g., "sfl.crm.persona", "aspn.consents").
 * Rename this file to v-{your-operation}-params.dwl.
 */
var uriId = attributes.uriParams.id default ""
---
{
	requestMethod: Mule::p('primary.sapi.update.record.method'),
	requestPath: Mule::p('primary.sapi.update.record.path'),
	requestProtocol: Mule::p('primary.sapi.protocol'),
	requestHost: Mule::p('primary.sapi.host'),
	requestPort: Mule::p('primary.sapi.port'),
	requestBasePath: Mule::p('primary.sapi.basePath'),
	// Adjust requestPayload to include only the fields required by the primary SAPI.
	// Use conditional inclusion (if/else) for optional fields.
	requestPayload: payload default {},
	headers: {
		"x-request-id": correlationId,
		"client_id": Mule::p("primary.sapi.client_id") default "",
		"client_secret": Mule::p("primary.sapi.client_secret") default "",
		"sourceSystem": vars.requestContext.sourceSystem default "",
		"targetSystem": vars.requestContext.targetSystem default ""
	},
	uriParams: {
		"id": uriId
	},
	queryParams: {}
}
