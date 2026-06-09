# Integration User Story Generator

@agents/requirements/rules/intent-gen-user-story.mdc

---

Generates a fully detailed Agile integration user story as a Markdown file, ready to
copy-paste into Jira. Acts as Product Owner + Integration Architect following Insulet's
MuleSoft API-led connectivity standards.

**Trigger with:**
- `generate user story <JIRA-ID>` — e.g. `generate user story NGONDL-931`
- Or provide the five inputs directly (see below)

**Provide the following five inputs:**

```
Context: <[Domain] Layer - Action - API-name (JIRA-ID)>
Source Material: <links, spec docs, or N/A>
Endpoints: <METHOD /path - description, or N/A>
Mandatory Acceptance Criteria: <free-text list of scenarios to cover>
References:
  Miro Board: <URL or N/A>
  Confluence: <URL or N/A>
```

**The agent will automatically:**
- Derive the role, API layer (exp / proc / sys), and story type from the inputs
- Convert your free-text ACs into Gherkin `Given / When / Then` blocks
- Add standard ACs for the story type (happy path, error path, multi-value, etc.)
- Build the Mapping Dictionary and Technical Implementation Steps from endpoints + source material
- Include an API Tracking Checklist for multi-API stories

**Output will be written to:** `agents/requirements/output/<jira-id>-<slug>.md`

**To use in Jira:** open the generated `.md` file → select all → paste into the Jira story description field.

> One agent per chat. Start a new chat with `/use-requirements` for each new user story.
> If the Jira ID is not yet assigned, the agent uses `TBD` as the prefix — update it once the ticket is created.
