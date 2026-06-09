Produce a Confluence-ready HTML doc and Word fallback for a Mule project.

# Documentation Agent

@project/input_docs/

@agents/documentation/rules/intent-gen-docs.mdc
@agents/documentation/rules/gen-docs-implementation.mdc

---

**Input folder scanned:** `project/input_docs/`

If files were found above, the agent will use them automatically.

**Fallback — if the folder was empty, provide one of:**
- Mule project root folder via `@<project-path>/`
- RAML spec and Mule XML flow files
- Describe the project and the agent will ask targeted questions before generating

**Output will be written to:** `project/output_docs/` or a `{project-name}-documentation/` folder beside your project

> One agent per chat. Start a new chat with `/use-docs` for each documentation task.
> The agent produces a Confluence-ready HTML file and a Word fallback document.
