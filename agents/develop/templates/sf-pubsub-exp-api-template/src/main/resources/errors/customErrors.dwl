/**
* Custom error mapping for the SF PubSub Exp API Template.
* Used by the module-error-handler-plugin:process-error in global-error-handler.xml.
*/
%dw 2.0
output application/json
import * from module_error_handler_plugin::common

/**
* Previous error nested in the Mule error object.
* Handles composite modules, Until-Successful, and standard errors.
*/
var previousError = do {
    var nested = [
        error.childErrors..errorMessage.payload,        // Composite (Scatter-Gather, Parallel-Foreach)
        error.suppressedErrors..errorMessage.payload,   // Until-Successful
        error.exception.errorMessage.typedValue         // Standard Error — must go last
    ] dw::core::Arrays::firstWith !isEmpty($)
    ---
    if (nested is Array)
        toString(nested map (toString($)) distinctBy $)
    else
        toString(nested)
}

---
{
    /*
    -----------------------------------------------------------------------
    APP Errors
    -----------------------------------------------------------------------
    */

    /**
    APP 503 Service Unavailable — custom connectivity failure raised by check-for-raise-error-sub-flow.
    */
    "APP:CONNECTIVITY_FAILED": {
        code: 503,
        reason: "Service Unavailable",
        message: if (!isEmpty(previousError)) previousError else error.description
    },

    /*
    -----------------------------------------------------------------------
    HTTP Errors
    -----------------------------------------------------------------------
    */

    /**
    HTTP 500 Pass Through — propagates detailed downstream failure reason.
    */
    "HTTP:INTERNAL_SERVER_ERROR": {
        code: 500,
        reason: "Internal Server Error",
        message: if (!isEmpty(previousError)) previousError else error.description
    },

    /**
    HTTP connectivity failure — downstream service unreachable.
    */
    "HTTP:CONNECTIVITY": {
        code: 503,
        reason: "Service Unavailable",
        message: if (!isEmpty(previousError)) previousError else error.description
    },

    /**
    HTTP timeout — downstream service did not respond in time.
    */
    "HTTP:TIMEOUT": {
        code: 504,
        reason: "Gateway Timeout",
        message: if (!isEmpty(previousError)) previousError else error.description
    },

    /**
    HTTP retry exhausted — all retry attempts failed.
    */
    "HTTP:RETRY_EXHAUSTED": {
        code: 503,
        reason: "Service Unavailable",
        message: if (!isEmpty(previousError)) previousError else error.description
    },

    /**
    HTTP service unavailable — downstream returned 503.
    */
    "HTTP:SERVICE_UNAVAILABLE": {
        code: 503,
        reason: "Service Unavailable",
        message: if (!isEmpty(previousError)) previousError else error.description
    },

    /*
    -----------------------------------------------------------------------
    Salesforce PubSub Errors (Pattern A — mule4-salesforce-pubsub-connector)
    -----------------------------------------------------------------------
    */

    /**
    Salesforce connectivity failure — gRPC endpoint unreachable or JWT auth failed.
    */
    "SALESFORCE-PUB-SUB:CONNECTIVITY": {
        code: 503,
        reason: "Salesforce PubSub Connectivity Error",
        message: if (!isEmpty(previousError)) previousError else error.description
    },

    /**
    Salesforce publish request timeout — gRPC call timed out.
    */
    "SALESFORCE-PUB-SUB:TIMEOUT": {
        code: 504,
        reason: "Salesforce PubSub Timeout",
        message: if (!isEmpty(previousError)) previousError else error.description
    },

    /**
    Salesforce retry exhausted — reconnection attempts exceeded.
    */
    "SALESFORCE-PUB-SUB:RETRY_EXHAUSTED": {
        code: 503,
        reason: "Salesforce PubSub Retry Exhausted",
        message: if (!isEmpty(previousError)) previousError else error.description
    },

    /*
    -----------------------------------------------------------------------
    Salesforce Streaming Errors (Pattern B — mule-salesforce-connector)
    -----------------------------------------------------------------------
    */

    /**
    Salesforce connectivity failure — CometD endpoint unreachable or JWT auth failed.
    */
    "SALESFORCE:CONNECTIVITY": {
        code: 503,
        reason: "Salesforce Connectivity Error",
        message: if (!isEmpty(previousError)) previousError else error.description
    },

    /**
    Salesforce not found — channel or object not found.
    */
    "SALESFORCE:NOT_FOUND": {
        code: 404,
        reason: "Salesforce Resource Not Found",
        message: if (!isEmpty(previousError)) previousError else error.description
    },

    /**
    Salesforce timeout — CometD streaming connection timed out.
    */
    "SALESFORCE:TIMEOUT": {
        code: 504,
        reason: "Salesforce Timeout",
        message: if (!isEmpty(previousError)) previousError else error.description
    },

    /**
    Salesforce API limit exceeded — rate limit or quota exceeded.
    */
    "SALESFORCE:LIMIT_EXCEEDED": {
        code: 429,
        reason: "Salesforce Limit Exceeded",
        message: if (!isEmpty(previousError)) previousError else error.description
    },

    /**
    Salesforce invalid input — malformed request or invalid channel name.
    */
    "SALESFORCE:INVALID_INPUT": {
        code: 400,
        reason: "Salesforce Invalid Input",
        message: if (!isEmpty(previousError)) previousError else error.description
    },

    /**
    Salesforce retry exhausted — reconnection attempts exceeded.
    */
    "SALESFORCE:RETRY_EXHAUSTED": {
        code: 503,
        reason: "Salesforce Retry Exhausted",
        message: if (!isEmpty(previousError)) previousError else error.description
    },

    /*
    -----------------------------------------------------------------------
    Anypoint MQ Errors
    -----------------------------------------------------------------------
    */

    /**
    MQ connectivity failure — broker unreachable.
    */
    "ANYPOINT-MQ:CONNECTIVITY": {
        code: 503,
        reason: "Anypoint MQ Connectivity Error",
        message: if (!isEmpty(previousError)) previousError else error.description
    },

    /**
    MQ publish failure — message could not be published.
    */
    "ANYPOINT-MQ:PUBLISHING": {
        code: 500,
        reason: "Anypoint MQ Publishing Error",
        message: if (!isEmpty(previousError)) previousError else error.description
    },

    /**
    MQ retry exhausted — all reconnect attempts failed.
    */
    "ANYPOINT-MQ:RETRY_EXHAUSTED": {
        code: 503,
        reason: "Anypoint MQ Retry Exhausted",
        message: if (!isEmpty(previousError)) previousError else error.description
    },

    /*
    -----------------------------------------------------------------------
    Catch-All
    -----------------------------------------------------------------------
    */

    /**
    Unknown / unclassified errors.
    */
    "MULE:UNKNOWN": {
        code: error.exception.errorMessage.attributes.statusCode default 500,
        reason: error.exception.errorMessage.attributes.reasonPhrase default "Internal Server Error",
        message: if (!isEmpty(previousError)) previousError else error.description
    }
}
