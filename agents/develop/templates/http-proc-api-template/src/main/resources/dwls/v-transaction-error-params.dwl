%dw 2.0
output application/json
/**
 * targetApiParams for POST /transactions-errors on sfl-crm-persona-sys-api.
 * This DWL is shared across all proc APIs — the error logging SAPI is always sfl-crm-persona-sys-api.
 *
 * Replace {externalReferenceId} with the primary entity ID extracted from the primary SAPI response
 * (e.g., vars.accountId, vars.leadId). Remove the field if not applicable.
 */
var ctx = vars.requestContext default {}
var err = vars.errorDetails default error
import buildErrorCatalog from errors::errorCatalog
var errorCatalog = buildErrorCatalog(p('sourceSystem') default "")
var correlationIdFromAttributes = attributes.correlationId default null
var correlationIdFromHeaders = ctx.headers.'x-correlation-id' default ctx.headers.'X-Correlation-Id' default ctx.headers.correlationId default null
var correlationIdFromEvent = correlationId default null
var resolvedCorrelationId = correlationIdFromAttributes default correlationIdFromHeaders default correlationIdFromEvent default ""
---
{
	requestMethod: "POST",
	requestPath: Mule::p('sfl.crm.persona.transactionsErrorsPath'),
	requestProtocol: Mule::p('sfl.crm.persona.protocol'),
	requestHost: Mule::p('sfl.crm.persona.host'),
	requestPort: Mule::p('sfl.crm.persona.port'),
	requestBasePath: Mule::p('sfl.crm.persona.basePath'),
	requestPayload: {
		muleAppName: Mule::p("app.name"),
		correlationId: resolvedCorrelationId,
		errorType: (err.errorType.namespace default "UNKNOWN") ++ ":" ++ (err.errorType.identifier default "UNKNOWN"),
		errorMessage: write(vars.errorMessage, "application/json") default err.description default err.message default "",
		errorTimestamp: (now() as DateTime >> "EST") as LocalDateTime,
		payloadData: write(ctx.originalPayload, "application/json") default "",
		resolvedFlag: Mule::p('ie.resolvedFlag') as Boolean,
		transactionId: vars.errorTransactionId default errorCatalog.genericIntegrationError,
		responseData: error.description default error.detailedDescription,
		sourceSystem: p('sourceSystem'),
		transactionType: Mule::p('ie.transactionType'),
		// Replace vars.{primaryId} with the actual primary identifier variable extracted in the orchestration sub-flow
		externalReferenceId: vars.{primaryId} default ""
	},
	headers: {
		"x-request-id": correlationId,
		"client_id": Mule::p("sfl-crm-persona-api.client_id") default "",
		"client_secret": Mule::p("sfl-crm-persona-api.client_secret") default "",
		"sourceSystem": ctx.sourceSystem default Mule::p("app.name") default "",
		"targetSystem": ctx.targetSystem default Mule::p("targetSystem") default ""
	},
	uriParams: {},
	queryParams: {}
}
