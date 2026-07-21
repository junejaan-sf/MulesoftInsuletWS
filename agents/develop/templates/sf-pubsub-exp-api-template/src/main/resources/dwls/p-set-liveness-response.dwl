%dw 2.0
output application/json
---
{
	apiName: Mule::p('app.name'),
	version: Mule::p('app.version'),
	correlationId: correlationId,
	timestamp: now() >> Mule::p('timezone'),
	status: Mule::p('message.systemAlive')
}
