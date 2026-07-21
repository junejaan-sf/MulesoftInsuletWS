%dw 2.0
output application/json
---
{
	"sourceSystem": Mule::p('sourceSystem'),
	"targetSystem": Mule::p('targetSystem'),
	/*
	  HTTP requests (ping / health-check): headers, queryParams, uriParams are populated.
	  Salesforce events: these attributes are absent; eventId/replayId come from payload.

	  Subscribe Channel Listener (Pattern A — PubSub / gRPC):
	    payload.replayId and payload.eventId are top-level fields.

	  Replay Channel Listener (Pattern B — Streaming / CometD):
	    replayId is nested under payload.data.event.replayId.
	*/
	"headers": attributes.headers default {},
	"queryParams": attributes.queryParams default {},
	"uriParams": attributes.uriParams default {},
	("eventId": payload.eventId) if(!isEmpty(payload.eventId default "")),
	("replayId": payload.replayId default (payload.data.event.replayId default 0)) if(!isEmpty(payload))
}
