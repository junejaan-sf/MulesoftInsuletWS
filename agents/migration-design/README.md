# Migration Design Agent

Produces a migration-oriented solution/technical design for an **existing** (legacy or
partially-migrated) MuleSoft API. Reads the actual Mule code plus notes and an optional
Confluence Low-Level Design, then writes a Confluence-ready Markdown design that documents the
reference API (baselined on the legacy code + notes), maps the provided requirements and gaps,
and highlights the Insulet standards missing in the current implementation. When an
already-migrated version of the API is provided, it appends a single consolidated delta at the
end comparing the legacy-based design against that migrated API.

It is fully read-only: it never modifies the source project and makes no live Salesforce org calls.

**Out of scope (handled by the user manually):** DDD naming (`exp`/`prc`/`sys`) and Salesforce
Classic→NextGen mapping. The agent documents names and Salesforce fields exactly as observed.

## Rules

| Rule | Purpose | Trigger |
|------|---------|---------|
| `intent-gen-migration-design.mdc` | **Main migration-design generator.** Analyses the existing API, extracts requirements/gaps from notes + Confluence LLD, and writes a 6-section Markdown design (plus a consolidated delta when a migrated API is provided). | `/use-migration-design`, `migration design <api-name>`, or an @mention of the rule |

### Reused rules (read silently — not duplicated here)

- `agents/design/rules/design-standards-reference.mdc` — canonical design-phase standards digest.
- Selected `agents/review/rules/review-*.mdc` — ground the Gap Analysis and MUnit Coverage.

## Folder Structure

```
migration-design/
├── rules/
│   └── intent-gen-migration-design.mdc   ← main migration-design generator
├── input/                                 ← drop the existing/legacy Mule API + notes here
│   └── migrated-api/                      ← drop the already-migrated API here (optional)
├── output/                                ← generated design docs
└── README.md
```

## Activate

Type `/use-migration-design` in a new Cursor chat, or @mention the rule:

```
@agents/migration-design/rules/intent-gen-migration-design.mdc
migration design <api-name>
```

## Inputs → `agents/migration-design/input/`

Provide any of these before running the agent:

- **Existing/legacy Mule API (required)** — drop the project into `agents/migration-design/input/`,
  or `@mention` its folder path in chat. The design is baselined on this API.
- **Notes (optional)** — `.md` / `.txt` describing target requirements, known gaps, and scope.
- **Confluence LLD (optional)** — a page URL/ID (pulled read-only via the Atlassian MCP).
- **Already-migrated API (optional)** — drop it into `agents/migration-design/input/migrated-api/`
  (or `@mention` it) to get per-finding migration status (folded into section 6) and a
  functional-difference comparison.

## Outputs → `agents/migration-design/output/`

- `{api-technical-name}-migration-design.md` — a 6-section design document:
  1. Application Overview
  2. Non-Functional Requirements
  3. High-Level Architecture
  4. Interface Specification (per-endpoint Source → Target → Transformation mapping; plus a concise
     Functional Differences callout when a migrated API is provided)
  5. MUnit Coverage (blank plan; 80%+ coverage note)
  6. Standards Compliance & Migration Status (each finding with legacy baseline, migration status
     against the migrated API when provided, and remediation grounded in the review rulesets and the
     per-layer gold-standard reference APIs; the legacy-vs-migrated comparison is folded in here as a
     per-finding status, not a separate delta section)
- `{api-technical-name}-gap-analysis.md` — companion file (`Ref: GAP-{api}`), referenced by id
  from the main design, containing the Requirement/Gap Mapping, Open Questions & Migration
  Decisions, and (when a migrated API is provided) a detailed Functional Differences table.

**Gold-standard reference APIs** (one per layer, consulted only to ground remediation):
`drupal-exp-api` (exp), `leads-proc-api` (proc), `sfl-consents-sys-api` (sys).

## Handoff

The migration design becomes input for the downstream agents:

```
agents/migration-design/output/{api}-migration-design.md
        → /use-raml      (@mention the design doc)
        → /use-develop   (richer migration context than Jira/Confluence alone)
```

> One agent per chat. Start a new chat with `/use-migration-design` for each API.
> All AI-generated output must be reviewed by a qualified MuleSoft developer before use.
