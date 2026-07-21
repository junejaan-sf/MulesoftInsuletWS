%dw 2.0
output application/java
---
{
	headers: attributes.headers default {},
	queryParams: attributes.queryParams default {},
	uriParams: attributes.uriParams default {},
	originalPayload: payload default {},
	requestPath: attributes.requestPath default "",
	sourceSystem: attributes.headers.sourceSystem default p('sourceSystem'),
	targetSystem: attributes.headers.targetSystem default p('targetSystem')
}
