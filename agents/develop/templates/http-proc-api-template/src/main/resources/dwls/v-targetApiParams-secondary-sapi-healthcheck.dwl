%dw 2.0
output application/json
/**
 * targetApiParams for secondary SAPI health-check GET.
 *
 * Replace "secondary.sapi" with your actual secondary SAPI property prefix.
 * Rename this file to v-targetApiParams-{your-sapi-name}-healthcheck.dwl.
 * Duplicate for each additional downstream SAPI referenced in health-check-ready.xml.
 */
---
{
	requestMethod: Mule::p("secondary.sapi.healthCheck.method") default "GET",
	requestPath: Mule::p("secondary.sapi.healthCheck.path") default "/api/v1/health-check",
	requestProtocol: Mule::p('secondary.sapi.protocol'),
	requestHost: Mule::p('secondary.sapi.host'),
	requestPort: Mule::p('secondary.sapi.port'),
	requestBasePath: Mule::p('secondary.sapi.basePath'),
	headers: {
		"x-request-id": correlationId,
		"client_id": Mule::p("secondary.sapi.client_id") default "",
		"client_secret": Mule::p("secondary.sapi.client_secret") default "",
		"sourceSystem": vars.requestContext.sourceSystem default "",
		"targetSystem": vars.requestContext.targetSystem default ""
	},
	uriParams: {},
	queryParams: {},
	requestPayload: null
}
