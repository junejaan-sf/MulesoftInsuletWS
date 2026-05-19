/**
 * Custom error handling mappings for http-proc-api-template.
 * Replace {api-name} in the JSDoc with the actual API name.
 */
%dw 2.0
output application/json
import * from module_error_handler_plugin::common

var previousError = do {
    var nested = [
        error.childErrors..errorMessage.payload,
        error.suppressedErrors..errorMessage.payload,
        error.exception.errorMessage.typedValue
    ] dw::core::Arrays::firstWith !isEmpty($)
    ---
    if (nested is Array)
        toString(nested map (toString($)) distinctBy $)
    else
        toString(nested)
}

// Reusable function to extract and format Mule composite routing errors
fun extractRoutingErrors(errorMessage: Any): String =
    if (errorMessage is String and !isEmpty(errorMessage))
        (
            ((errorMessage as String) splitBy "\n")
                filter ($ contains "Route")
                map ((line) -> trim(line replace /^.*Exception:\s/ with ""))
        ) joinBy ", " default "No route-specific errors identified"
    else
        "Invalid or missing error message data"
---
{
    "APP:CONNECTIVITY_FAILED": {
        code: 503,
        reason: "Service Unavailable",
        message: if (!isEmpty(previousError)) previousError else error.description
    },
    "HTTP:INTERNAL_SERVER_ERROR": {
        code: 500,
        reason: "Internal Server Error",
        message: if (!isEmpty(previousError)) previousError else error.description
    },
    "HTTP:BAD_REQUEST": {
        code: 400,
        reason: "Bad Request",
        message: if (!isEmpty(previousError)) previousError else error.description
    },
    "HTTP:UNAUTHORIZED": {
        code: 401,
        reason: "Unauthorized",
        message: if (!isEmpty(previousError)) previousError else error.description
    },
    "HTTP:NOT_FOUND": {
        code: 404,
        reason: "Not Found",
        message: if (!isEmpty(previousError)) previousError else error.description
    },
    "HTTP:CONNECTIVITY": {
        code: 503,
        reason: "Service Unavailable",
        message: if (!isEmpty(previousError)) previousError else error.description
    },
    "HTTP:SERVICE_UNAVAILABLE": {
        code: 503,
        reason: "Service Unavailable",
        message: if (!isEmpty(previousError)) previousError else error.description
    },
    "HTTP:TIMEOUT": {
        code: 504,
        reason: "Gateway Timeout",
        message: if (!isEmpty(previousError)) previousError else error.description
    },
    "MULE:RETRY_EXHAUSTED": {
        code: 503,
        reason: "Service Unavailable",
        message: if (!isEmpty(previousError)) previousError else error.description
    },
    "MULE:COMPOSITE_ROUTING": {
        code: 400,
        reason: "Bad Request",
        message: extractRoutingErrors(if (!isEmpty(previousError)) previousError else error.description)
    },
    "MULE:UNKNOWN": {
        code: error.exception.errorMessage.attributes.statusCode default 500,
        reason: error.exception.errorMessage.attributes.reasonPhrase default "Internal Server Error",
        message: if (!isEmpty(previousError)) previousError else error.description
    }
}
