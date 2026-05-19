# RAML from JIRA Agent

Generates a RAML API spec by fetching a JIRA story and its linked Confluence design page — no manual input required beyond the story ID.

@agents/raml/rules/intent-gen-raml-from-jira.mdc
@agents/raml/rules/gen-raml-implementation.mdc

---

**How to use:**

After activation, type the JIRA story ID(s) in chat:

```
raml NGCRMI-1875
```

Multiple stories for the same API:
```
raml NGCRMI-1875 NGCRMI-1886
```

**What the agent does automatically:**
1. Fetches the JIRA story (summary, description, acceptance criteria, technical notes)
2. Extracts the Confluence design page URL from technical notes
3. Fetches the Confluence page (endpoints, fields, HTTP status codes, Salesforce mappings)
4. Resolves all design decisions without asking you
5. Generates the RAML spec
6. Saves JIRA story details and Confluence design to `project/input_develop/` for use by the develop agent

**Output will be written to:**
- RAML spec: `agents/raml/examples/{api-spec-name}/`
- Context files: `project/input_develop/jira-{STORY-ID}.md` + `project/input_develop/confluence-design-{STORY-ID}.md`

**Credentials required** (must be present in `.env`):
- `JIRA_EMAIL` and `JIRA_TOKEN` — for Jira and Confluence access

> One agent per chat. Use `/use-raml-to-exchange` if you also want to publish to Anypoint Exchange after generation.
