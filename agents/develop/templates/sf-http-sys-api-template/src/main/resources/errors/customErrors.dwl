/**
 * Custom error mappings for the Salesforce HTTP sys-api error handler.
 * Used by module-error-handler-plugin:process-error in global-error-handler.xml.
 *
 * Each entry maps an error type string to { code, reason, message }.
 * Add APP:* entries for every custom raise-error type defined in the implementation flows.
 */
%dw 2.0
output application/json
import * from module_error_handler_plugin::common

/**
 * previousError: extracts the nested error message from composite
 * scopes (scatter-gather, until-successful, standard errors).
 */
var previousError = do {
    var nested = [
        error.childErrors..errorMessage.payload,        // Composite/scatter-gather
        error.suppressedErrors..errorMessage.payload,   // Until-Successful
        error.exception.errorMessage.typedValue         // Standard error (must go last)
    ] dw::core::Arrays::firstWith !isEmpty($)
    ---
    if (nested is Array)
        toString(nested map (toString($)) distinctBy $)
    else
        toString(nested)
}

---
{
    // ── Salesforce Standard Connector Errors ─────────────────────────────────
    "SALESFORCE:CONNECTIVITY": {
        "code": 503,
        "reason": "Service Unavailable",
        "message": "Unable to connect to Salesforce: " ++ (error.description default "")
    },
    "SALESFORCE:NOT_FOUND": {
        "code": 404,
        "reason": "Not Found",
        "message": "Requested Salesforce resource not found: " ++ (error.description default "")
    },
    "SALESFORCE:LIMIT_EXCEEDED": {
        "code": 429,
        "reason": "Too Many Requests",
        "message": "Salesforce API limit exceeded: " ++ (error.description default "")
    },
    "SALESFORCE:INVALID_INPUT": {
        "code": 400,
        "reason": "Bad Request",
        "message": "Invalid input for Salesforce operation: " ++ (error.description default "")
    },
    "SALESFORCE:TIMEOUT": {
        "code": 504,
        "reason": "Gateway Timeout",
        "message": "Salesforce operation timed out: " ++ (error.description default "")
    },
    "SALESFORCE:UNAVAILABLE": {
        "code": 503,
        "reason": "Service Unavailable",
        "message": "Salesforce is temporarily unavailable: " ++ (error.description default "")
    },

    // ── Salesforce Composite Connector Errors ────────────────────────────────
    "SALESFORCE-COMPOSITE:CONNECTIVITY": {
        "code": 503,
        "reason": "Service Unavailable",
        "message": "Unable to connect to Salesforce Composite API: " ++ (error.description default "")
    },
    "SALESFORCE-COMPOSITE:TIMEOUT": {
        "code": 504,
        "reason": "Gateway Timeout",
        "message": "Salesforce Composite API timed out: " ++ (error.description default "")
    },

    // ── APP Custom Errors ─────────────────────────────────────────────────────
    // APP:RECORD_CREATION_FAILED — SF returned success=false during create
    // Conditionally included when vars.recordStatus == false:
    //   ("APP:RECORD_CREATION_FAILED": { ... }) if (!vars.recordStatus default false),

    "APP:RECORD_CREATION_FAILED": {
        "code": 400,
        "reason": "Record Create Operation Failed",
        "message": if (!isEmpty(previousError)) previousError else error.description
    },
    "APP:RECORD_NOT_FOUND": {
        "code": 404,
        "reason": "Not Found",
        "message": error.description
    },
    "APP:RECORD_UPDATE_FAILED": {
        "code": 400,
        "reason": vars.recordUpdateStatus default "Bad Request",
        "message": error.description
    },

    // ── Connectivity Wrapper ──────────────────────────────────────────────────
    "APP:CONNECTIVITY_FAILED": {
        code: 503,
        reason: "Service Unavailable",
        message: if (!isEmpty(previousError)) previousError else error.description
    },

    // ── Validation ────────────────────────────────────────────────────────────
    "VALIDATION:INVALID_BOOLEAN": {
        code: 400,
        reason: "Bad Request",
        message: error.description
    },
    "APIKIT:BAD_REQUEST": {
        code: 400,
        reason: "Bad Request",
        message: error.description
    },
    "APIKIT:NOT_FOUND": {
        code: 404,
        reason: "Not Found",
        message: error.description
    },
    "APIKIT:METHOD_NOT_ALLOWED": {
        code: 405,
        reason: "Method Not Allowed",
        message: error.description
    },
    "APIKIT:UNSUPPORTED_MEDIA_TYPE": {
        code: 415,
        reason: "Unsupported Media Type",
        message: error.description
    },

    // ── HTTP Pass-Through ─────────────────────────────────────────────────────
    "HTTP:INTERNAL_SERVER_ERROR": {
        code: 500,
        reason: "Internal Server Error",
        message: if (!isEmpty(previousError)) previousError else error.description
    },

    // ── Catch-All ─────────────────────────────────────────────────────────────
    "MULE:UNKNOWN": {
        code: error.exception.errorMessage.attributes.statusCode default 500,
        reason: error.exception.errorMessage.attributes.reasonPhrase default "Internal Server Error",
        message: if (!isEmpty(previousError)) previousError else error.description
    }
}
