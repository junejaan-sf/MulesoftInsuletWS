%dw 2.0
/**
 * p-composite-request.dwl
 *
 * Transforms the inbound POST /composites body into the Salesforce Composite
 * API request format expected by execute-sf-composite-flow.
 *
 * Input:  payload — { allOrNone: Boolean, compositeRequest: Array<Object> }
 * Output: application/json
 *
 * Pattern is an exact copy from sfl-crm-persona-sys-api:
 *   - Passes allOrNone through
 *   - Maps each sub-request; omits 'body' for GET methods
 */
output application/json
---
{
    allOrNone: payload.allOrNone,
    compositeRequest: (payload.compositeRequest) map ((item, index) -> {
        "method":      item.method,
        "url":         item.url,
        "referenceId": item.referenceId,
        ("body": item.body) if (upper(item.method) != "GET")
    })
}
