%dw 2.0
output application/java
/**
 * Maps Salesforce RecordType query results to a flat list of
 * { Id, SobjectType, Name } records for storage in ObjectStore.
 *
 * Each item is stored under key "SobjectType|Name"
 * (e.g., "Lead|Patient", "Account|Provider").
 *
 * Input:  payload (Iterator<Map> from salesforce:query — RecordType rows)
 * Output: Array<Map> with { Id, SobjectType, Name }
 */
---
payload map (record) -> {
    Id:          record.Id,
    SobjectType: record.SobjectType,
    Name:        record.Name
}
