%dw 2.0
output application/json
---
{
	/*
	  Produces consistent MQ user-properties regardless of which connector pattern fired.

	  Subscribe Channel Listener (Pattern A — PubSub / gRPC):
	    payload.replayId and payload.eventId are top-level fields.

	  Replay Channel Listener (Pattern B — Streaming / CometD):
	    replayId is nested under payload.data.event.replayId.
	*/
	"replayId": payload.replayId default (payload.data.event.replayId default ""),
	"eventId": payload.eventId default "",
	"correlationId": correlationId,
	"sourceSystem": Mule::p('sourceSystem'),
	"targetSystem": Mule::p('targetSystem')
}
