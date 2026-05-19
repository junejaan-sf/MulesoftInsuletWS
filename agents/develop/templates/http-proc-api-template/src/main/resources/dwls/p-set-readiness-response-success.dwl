%dw 2.0
import * from dw::core::Arrays
output application/json
var statusValue = if ((payload pluck (value, key, index) -> (value.payload default value).status)
	some (($ != p('message.systemUp')) and ($ != p('message.systemsReady')))
) p('message.systemsNotReady') else p('message.systemsReady')
---
{
	apiName: p('app.name'),
	version: p('app.version'),
	correlationId: correlationId,
	timestamp: now() >> p('timezone'),
	dependencies: (payload pluck {
		"name": ($.payload.apiName default $.payload.name default $.apiName default $.name),
		"status": ($.payload default $).status
	}),
	status: statusValue
}
