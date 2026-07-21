%dw 2.0
output application/json
---
/*
  Transform the incoming Salesforce platform event payload into the MQ message body.

  Pattern A (PubSub / gRPC — Subscribe Channel Listener):
    payload.replayId    — top-level replay ID
    payload.eventId     — top-level event ID
    payload.data.*      — event-specific fields

  Pattern B (Streaming / CometD — Replay Channel Listener):
    payload.data.event.replayId   — nested replay ID
    payload.data.payload.*        — event-specific fields
    payload.channel               — streaming channel name

  IMPORTANT: Replace this pass-through with the actual transformation logic
  for the specific integration (e.g. map to a canonical data model).
*/
payload
