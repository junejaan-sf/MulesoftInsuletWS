/**
 * customErrors.dwl
 * v3 canonical custom-errors map for module-error-handler-plugin:process-error.
 * Maps error types to HTTP status codes and reason phrases.
 *
 * Used by: global-error-handler.xml (Branch 2 on-error-continue)
 *
 * Keys are error type strings in NAMESPACE:IDENTIFIER format.
 * Values must have: httpStatus (Number), reason (String)
 */
%dw 2.0
output application/java
---
{
    "APP:BAD_REQUEST": {
        httpStatus: 400,
        reason: "Bad Request"
    },
    "APP:UNAUTHORIZED": {
        httpStatus: 401,
        reason: "Unauthorized"
    },
    "APP:FORBIDDEN": {
        httpStatus: 403,
        reason: "Forbidden"
    },
    "APP:NOT_FOUND": {
        httpStatus: 404,
        reason: "Not Found"
    },
    "APP:METHOD_NOT_ALLOWED": {
        httpStatus: 405,
        reason: "Method Not Allowed"
    },
    "APP:NOT_ACCEPTABLE": {
        httpStatus: 406,
        reason: "Not Acceptable"
    },
    "APP:CONFLICT": {
        httpStatus: 409,
        reason: "Conflict"
    },
    "APP:UNSUPPORTED_MEDIA_TYPE": {
        httpStatus: 415,
        reason: "Unsupported Media Type"
    },
    "APP:TOO_MANY_REQUESTS": {
        httpStatus: 429,
        reason: "Too Many Requests"
    },
    "APP:CONNECTIVITY_FAILED": {
        httpStatus: 503,
        reason: "Service Unavailable"
    },
    "APP:INTERNAL_SERVER_ERROR": {
        httpStatus: 500,
        reason: "Internal Server Error"
    },
    "APIKIT:BAD_REQUEST": {
        httpStatus: 400,
        reason: "Bad Request"
    },
    "APIKIT:NOT_FOUND": {
        httpStatus: 404,
        reason: "Not Found"
    },
    "APIKIT:METHOD_NOT_ALLOWED": {
        httpStatus: 405,
        reason: "Method Not Allowed"
    },
    "APIKIT:NOT_ACCEPTABLE": {
        httpStatus: 406,
        reason: "Not Acceptable"
    },
    "APIKIT:UNSUPPORTED_MEDIA_TYPE": {
        httpStatus: 415,
        reason: "Unsupported Media Type"
    },
    "HTTP:CLIENT_SECURITY": {
        httpStatus: 401,
        reason: "Unauthorized"
    },
    "HTTP:FORBIDDEN": {
        httpStatus: 403,
        reason: "Forbidden"
    },
    "HTTP:NOT_FOUND": {
        httpStatus: 404,
        reason: "Not Found"
    },
    "HTTP:METHOD_NOT_ALLOWED": {
        httpStatus: 405,
        reason: "Method Not Allowed"
    },
    "HTTP:TIMEOUT": {
        httpStatus: 504,
        reason: "Gateway Timeout"
    },
    "HTTP:CONNECTIVITY": {
        httpStatus: 503,
        reason: "Service Unavailable"
    },
    "HTTP:BAD_REQUEST": {
        httpStatus: 400,
        reason: "Bad Request"
    },
    "HTTP:TOO_MANY_REQUESTS": {
        httpStatus: 429,
        reason: "Too Many Requests"
    },
    "HTTP:INTERNAL_SERVER_ERROR": {
        httpStatus: 500,
        reason: "Internal Server Error"
    },
    "HTTP:SERVICE_UNAVAILABLE": {
        httpStatus: 503,
        reason: "Service Unavailable"
    },
    "MULE:EXPRESSION": {
        httpStatus: 500,
        reason: "Internal Server Error"
    },
    "MULE:UNKNOWN": {
        httpStatus: 500,
        reason: "Internal Server Error"
    }
}
