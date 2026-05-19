# sf-pubsub-exp-api-template

**Pattern:** v3 §3.3 — Salesforce Pub/Sub Event App (Experience API)

This is the canonical Insulet skeleton template for consuming Salesforce Platform Events and publishing them to Anypoint MQ. It supports two connector patterns — choose the one that matches your Salesforce org setup.

---

## Two Connector Patterns

### Pattern A — Subscribe Channel Listener (PubSub / gRPC) ✅ Preferred
- **Connector:** `mule4-salesforce-pubsub-connector:1.2.0` (new, high-throughput gRPC)
- **Config:** `salesforce-pubsub_config`
- **Listener flow:** `sfl-subscribe-channel-event-listener-flow`
- **Process sub-flow:** `subscribe-channel-event-sub-flow`
- **ReplayId:** persisted to Object Store (`pub-sub-object-store_config`) — enables resume on restart
- **Channel property:** `sfl.channelName=/event/<YourEvent__e>`

### Pattern B — Replay Channel Listener (Streaming / CometD)
- **Connector:** `mule-salesforce-connector` (classic)
- **Config:** `salesforceConfig`
- **Listener flow:** `sfl-replay-channel-event-listener-flow`
- **Process sub-flow:** `replay-channel-event-sub-flow`
- **ReplayId:** managed automatically via `FROM_LAST_REPLAY_ID` (no Object Store needed)
- **Channel property:** `sfl.streamingChannel=/event/<YourEvent__e>`

---

## How to Use This Template

1. Copy to your workspace under `generated-projects/{event-name}-exp-api/`
2. **Replace** all `sf-pubsub-exp-api-template` references with your API name (e.g. `aspn-exp-api`)
3. **Replace** channel placeholders in `config.properties`:
   - Pattern A: `sfl.channelName=/event/<YourEvent__e>`
   - Pattern B: `sfl.streamingChannel=/event/<YourEvent__e>`
4. **Replace** MQ queue placeholders in each `config-{env}.properties`
5. **Replace** `p-mq-publish-payload.dwl` with your actual payload transformation
6. **Add** your Salesforce JWT keystore under `src/main/resources/certs/`
7. **Register** the RAML spec in Anypoint Exchange and update `api.raml.version` in `pom.xml`
8. **Activate** one pattern by disabling (commenting out) the listener flow for the other in `sf-pubsub-exp-api-template.xml`
9. **Fill in** the `api.id` in each `config-{env}.properties`

---

## Project Structure

```
src/main/mule/
├── sf-pubsub-exp-api-template.xml         Main flow (HTTP listener + APIKit + both SF listeners)
├── common/
│   ├── global-config.xml                  All global configs (both connector options)
│   ├── global-error-handler.xml           Error handler + check-for-raise-error sub-flow
│   └── common-utility.xml                 mq-publish-sub-flow + mq-dlq-publish-sub-flow
└── implementation/
    ├── subscribe-channel-event-sub-flow.xml  Pattern A (PubSub, with OS replayId)
    └── replay-channel-event-sub-flow.xml     Pattern B (Streaming, no OS)

src/main/resources/
├── dwls/
│   ├── v-request-context.dwl              Context variable (dual HTTP + SF event)
│   ├── p-mq-publish-payload.dwl           Event → MQ body transform (replace with real logic)
│   ├── v-mq-properties.dwl                MQ user properties (normalises PubSub vs Streaming)
│   ├── v-notification-input-body.dwl      Notification body shape
│   ├── p-set-liveness-response.dwl        /ping response
│   └── p-set-readiness-response.dwl       /health-check response
├── errors/customErrors.dwl                Full v3 canonical + Salesforce error types
├── log4j2.xml                             DataDog + file appenders, 3 AsyncLogger categories
└── properties/
    ├── config.properties                  Shared keys (channel names, MQ region, logger.*)
    ├── config-local.properties
    ├── config-dev.properties
    ├── config-qa.properties
    ├── config-uat.properties
    └── config-prod.properties
```

---

## CI/CD Pipeline

GitHub Actions workflows are not included in this template version. They will be added separately as a standalone versioned set of workflow files.

---

## Authors

- Template authors: Shubham Bajpayee
- Jira: _(add story link)_
- Anypoint Exchange: _(add link after publishing)_
- Confluence: _(add link)_
