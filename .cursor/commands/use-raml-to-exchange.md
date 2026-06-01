# RAML to Exchange Agent

Full end-to-end workflow: fetches JIRA stories, generates/updates the RAML spec from Confluence design, upgrades common-fragment-library to the latest Exchange version, then publishes an editable asset via Design Center.

@agents/raml/rules/intent-gen-raml-from-jira-to-exchange.mdc

---

**How to use:**

Generate RAML from a JIRA story and publish to Exchange:

```
publish raml NGCRMI-1875
```

Multiple stories for the same API:
```
publish raml NGCRMI-1875 NGCRMI-1886
```

Publish an already-generated local spec (skip JIRA/Confluence fetch):
```
publish exchange sfmc-consents-sys-api-spec
```

**What the agent does automatically:**
1. Fetches the JIRA story (summary, description, acceptance criteria, technical notes)
2. Extracts the Confluence design page URL from technical notes
3. Fetches the Confluence page (endpoints, fields, HTTP status codes, Salesforce mappings)
4. Resolves all design decisions without asking you
5. Generates or updates the RAML spec
6. Saves JIRA and Confluence context to `project/input_develop/`
7. Verifies and upgrades `common-fragment-library` to the latest Exchange version
8. Publishes the spec as an editable asset via Anypoint Design Center

**Output:**
- RAML spec: `agents/raml/examples/{api-spec-name}/`
- Context files: `project/input_develop/jira-{STORY-ID}.md` + `project/input_develop/confluence-design-{STORY-ID}.md`
- Exchange URL: `https://anypoint.mulesoft.com/exchange/{groupId}/{api-spec-name}/{version}/`

**Credentials required** (must be present in `.env`):
- `JIRA_EMAIL` and `JIRA_TOKEN` — for Jira and Confluence access
- `ANYPOINT_CLIENT_ID` and `ANYPOINT_CLIENT_SECRET` — for Anypoint Exchange publish

> One agent per chat. Use `/use-raml-from-jira` if you only want local RAML generation without publishing to Exchange.
