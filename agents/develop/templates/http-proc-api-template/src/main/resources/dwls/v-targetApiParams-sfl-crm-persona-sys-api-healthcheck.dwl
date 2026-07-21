%dw 2.0
output application/json
/**
 * targetApiParams for sfl-crm-persona-sys-api health-check GET.
 * This SAPI is always included in the health-check as it handles error logging.
 */
---
{
	requestMethod: Mule::p("sfl.crm.persona.healthCheck.method") default "GET",
	requestPath: Mule::p("sfl.crm.persona.healthCheck.path") default "/api/v1/health-check",
	requestProtocol: Mule::p('sfl.crm.persona.protocol'),
	requestHost: Mule::p('sfl.crm.persona.host'),
	requestPort: Mule::p('sfl.crm.persona.port'),
	requestBasePath: Mule::p('sfl.crm.persona.basePath'),
	headers: {
		"x-request-id": correlationId,
		"client_id": Mule::p("sfl-crm-persona-api.client_id") default "",
		"client_secret": Mule::p("sfl-crm-persona-api.client_secret") default "",
		"sourceSystem": vars.requestContext.sourceSystem default "",
		"targetSystem": vars.requestContext.targetSystem default ""
	},
	uriParams: {},
	queryParams: {},
	requestPayload: null
}
