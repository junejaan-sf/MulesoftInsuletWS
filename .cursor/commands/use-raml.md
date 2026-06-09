Generate or update a RAML API spec from a design doc, existing spec, or chat description.

# RAML / API Specification Agent

@project/input_raml/

@agents/raml/rules/intent-gen-raml.mdc
@agents/raml/rules/gen-raml-implementation.mdc

---

**Input folder scanned:** `project/input_raml/`

If files were found above, the agent will use them automatically.

**Fallback — if the folder was empty, provide one of:**
- Technical design document (`.md`, `.txt`) describing the API requirements
- Existing RAML spec to update or extend
- Describe the API requirements directly in chat

**Output will be written to:** `agents/raml/examples/{api-spec-name}/`

> One agent per chat. Start a new chat with `/use-raml` for each new API spec task.
>
> **Other RAML workflows:**
> - `/use-raml-from-jira` — generate from a JIRA story ID (fetches story + Confluence design automatically)
> - `/use-raml-to-exchange` — same as above, plus publishes the spec to Anypoint Exchange
