# NotebookLM → Initial Confluence API Documentation Agent

Generates initial Confluence API documentation drafts from a NotebookLM notebook —
one Markdown file per API discovered — following the canonical section structure from
`agents/documentation/rules/gen-docs-implementation.mdc` (Application Overview, NFRs,
High-Level Architecture, Interface Specifications). Runs before code exists; fields
knowable from JIRA stories are pre-populated, code-level fields are marked TBC.

@agents/design/rules/intent-gen-design-from-notebooklm_v1.mdc

---

**How to use:**

After activation, type the notebook name or business use case in chat:
  notebooklm Drupal

With an explicit use case name (when multiple notebooks exist):
  notebooklm "HCP Lead Creation"

**What the agent does automatically:**
1. Lists all NotebookLM notebooks and identifies the correct one
2. Fetches Studio Notes (sequence diagrams, architecture sketches, decision logs)
3. Runs 5 targeted queries for Application Overview, NFRs, Endpoints, Mapping, and Error Handling
4. Optionally fetches Confluence pages linked from JIRA sources (skipped silently if none found)
5. Identifies all distinct APIs in the notebook
6. Writes one initial Confluence doc draft per API to `agents/design/examples/`

**Output will be written to:**
- `agents/design/examples/{api-technical-name}.md` — one file per API
  e.g. `agents/design/examples/drupal-exp-api.md`
  e.g. `agents/design/examples/leads-prc-api.md`

**Output sections per file (following gen-docs-implementation.mdc):**
- §1 Application Overview (21-row table, TBC for code-level fields)
- §2 Non-Functional Requirements (5-row table)
- §3 High-Level Architecture (Mermaid flowchart)
- §4 Interface Specifications (per endpoint: Input, Backend Mapping & Logic, Output)
- §5 MUnit Coverage (empty — no code yet)

**Use the output files in downstream agents:**
- `/use-raml` — reference via `@agents/design/examples/{api-name}.md`
- `/use-develop` — same; provides richer business context than JIRA/Confluence alone
- `/use-docs` — run after code is implemented to complete TBC fields and generate full HTML + Word output

> One agent per chat. Start a new chat with `/use-notebooklm` for each notebook.
> The NotebookLM MCP must be authenticated — run `nlm login` in terminal if you see auth errors.

---

> **Previous version:** The v1 workflow (`intent-gen-design-from-notebooklm_v1.mdc`) produced a single raw design extraction dump with verbatim source content. Use it if you need the full extraction format for downstream agents that expect the older structure.
