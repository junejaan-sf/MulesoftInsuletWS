%dw 2.0
/**
 * p-composite-response.dwl
 *
 * Maps the Salesforce Composite API response to the outbound API response body.
 *
 * Input:  payload — SF Composite response { compositeResponse: Array<Object> }
 * Output: application/json — Array<Object>
 *
 * Pattern is an exact copy from sfl-crm-persona-sys-api:
 *   - Iterates compositeResponse
 *   - Normalises success flag from httpStatusCode range
 *   - Conditionally includes id, totalSize body, created
 *   - Always includes referenceId and errors
 */
output application/json
---
payload.compositeResponse map ((item, index) -> {
    "body": {
        "success":    item.httpStatusCode >= 200 and item.httpStatusCode < 300,
        "statusCode": item.httpStatusCode,
        ("id":         item.body.id)          if (!isEmpty(item.body.id)),
        (responseBody: item.body)             if (!isEmpty(item.body.totalSize)),
        ("created":    item.body.created)     if (!isEmpty(item.body.created)),
        referenceId:   item.referenceId,
        "errors": if (item.body.success == true) [] else (item.body.message ++ item.body.errorCode default "")
    }
})
