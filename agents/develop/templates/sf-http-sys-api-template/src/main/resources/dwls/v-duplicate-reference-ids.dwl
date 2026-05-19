%dw 2.0
/**
 * v-duplicate-reference-ids.dwl
 *
 * Detects duplicate referenceId values in the compositeRequest array.
 * Result stored in vars.duplicateReferenceIds; an empty array means no duplicates.
 *
 * Input:  payload.compositeRequest — Array of composite sub-request objects
 * Output: application/json — Array<String> of duplicate referenceId values, or []
 *
 * Pattern is an exact copy from sfl-crm-persona-sys-api.
 */
output application/json

fun findDuplicateReferenceIds(requests: Array) = do {
    var allIds = requests map $.referenceId
    var uniqueIds = allIds distinctBy $
    ---
    if (sizeOf(allIds) == sizeOf(uniqueIds))
        null
    else
        (allIds groupBy $
            filterObject (sizeOf($) > 1)
            pluck { referenceId: $$})
}
---
do {
    var duplicates = findDuplicateReferenceIds(payload.compositeRequest)
    ---
    if (isEmpty(duplicates))
        []
    else
        duplicates.referenceId
}
