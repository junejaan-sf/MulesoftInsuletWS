Design the migration of an existing MuleSoft API to Insulet standards, with an optional comparison against an already-migrated version — Confluence-ready Markdown.

# Migration Design Agent

@agents/migration-design/input/

@agents/migration-design/rules/intent-gen-migration-design.mdc

---

**Input folder scanned:** `agents/migration-design/input/`

**Recognized inputs:**
- Existing/legacy Mule API project (the API to be designed — the design is baselined on this) —
  drop it in `agents/migration-design/input/` or `@mention` its folder path in chat.
- Notes (`.md` / `.txt`) — target requirements, known gaps, and endpoint scope.
- Confluence LLD — provide a page URL/ID; the agent pulls it read-only via the Atlassian MCP.
- **Already-migrated API (optional)** — drop it in `agents/migration-design/input/migrated-api/`
  (or `@mention` it). When present, the design appends a single consolidated delta at the end
  comparing the legacy-based design against the migrated API.

**Output will be written to two files:**
- `agents/migration-design/output/{api-technical-name}-migration-design.md` — the main design.
- `agents/migration-design/output/{api-technical-name}-gap-analysis.md` — the companion Gap
  Analysis & Migration Decisions (`Ref: GAP-{api}`), referenced by id from the main design.

The main design has 6 core sections: Application Overview, Non-Functional Requirements, High-Level
Architecture, Interface Specification (Source → Target → Transformation mapping), MUnit Coverage,
and Standards Compliance (with detailed remediation) — plus a final Migration Delta section only
when an already-migrated API is provided. Gap Analysis and Open Questions live in the companion file.

> DDD naming and Salesforce Classic→NextGen mapping are intentionally out of scope — the user
> handles those manually.

> One agent per chat. Start a new chat with `/use-migration-design` for each API.
> The agent is read-only — it never modifies the source project and makes no live Salesforce calls.
