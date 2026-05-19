%dw 2.0
output application/json
/**
 * Final response payload for the update-record operation.
 *
 * Replace "recordId" and "vars.recordId" with the actual identifier field
 * extracted from the primary SAPI response (e.g., accountId, leadId).
 * Rename this file to p-{your-operation}-response.dwl.
 */
---
{
	recordId: vars.recordId default ""
}
