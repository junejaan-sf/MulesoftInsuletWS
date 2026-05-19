%dw 2.0
output application/json
/**
 * targetApiParams for the primary SAPI health-check GET.
 *
 * Replace "primary.sapi" with your actual SAPI property prefix.
 * Rename this file to v-targetApiParams-{your-sapi-name}-healthcheck.dwl.
 */
---
{
	requestMethod: Mule::p("primary.sapi.healthCheck.method") default "GET",
	requestPath: Mule::p("primary.sapi.healthCheck.path") default "/api/v1/health-check",
	requestProtocol: Mule::p('primary.sapi.protocol'),
	requestHost: Mule::p('primary.sapi.host'),
	requestPort: Mule::p('primary.sapi.port'),
	requestBasePath: Mule::p('primary.sapi.basePath'),
	headers: {
		"x-request-id": correlationId,
		"client_id": Mule::p("primary.sapi.client_id") default "",
		"client_secret": Mule::p("primary.sapi.client_secret") default "",
		"sourceSystem": vars.requestContext.sourceSystem default "",
		"targetSystem": vars.requestContext.targetSystem default ""
	},
	uriParams: {},
	queryParams: {},
	requestPayload: null
}
