/**
 * p-mq-message-transform.dwl
 * Transforms the incoming MQ message payload into the request shape
 * expected by the downstream sys API.
 *
 * REPLACE THIS PASS-THROUGH WITH ACTUAL FIELD MAPPING.
 *
 * Example:
 *   output application/json
 *   ---
 *   {
 *       externalId: payload.transactionId,
 *       recordType: payload.eventType,
 *       data: payload.body
 *   }
 */
%dw 2.0
output application/json
---
payload
