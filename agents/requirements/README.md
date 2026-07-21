# Requirements Agent

Generates **fully detailed Agile integration user stories** as Markdown files (`.md`),
ready to copy-paste directly into Jira, following Insulet's standard format for MuleSoft
API-led connectivity work.

@agents/requirements/rules/intent-gen-user-story.mdc

---

## Activate

In a new chat, `@mention` the rule above, then supply the five inputs:

```
Context: [SF Consents] Mule Inbound - Consent Retrieval - sfl-consent-sys-api (NGONDL-931)
Source Material: N/A
Endpoints: GET /consents - Retrieve consents by partyId and consentNames
Mandatory Acceptance Criteria:
  - Retrieve consents for a given PartyID (happy path, HTTP 200)
  - Return HTTP 404 when no records found
  - Support multi-value comma-separated consentNames
References:
  Miro Board: N/A
  Confluence: https://confluence.prod.insulet.com/...
```

Or use the short trigger:

```
generate user story NGONDL-931
```

---

## What the agent does

1. **Parses the five inputs** — extracts Jira ID, API type (exp/proc/sys), role, and references.
2. **Drafts all four story sections:**
   - Description (`As a… I want… So that…`)
   - Acceptance Criteria (Gherkin: Given / When / Then) — converts your free-text ACs and
     adds standard ACs for the story type (happy path, error path, etc.)
   - Solution Outline (Technical Reference · Mapping Dictionary · Implementation Steps)
   - Notes & Constraints (Security · Performance · Dependencies)
3. **Writes a Cursor Canvas** (`.canvas.tsx`) with the full story rendered as a structured,
   collapsible, interactive document.
4. **Fixes compile errors automatically** before reporting the result.

---

## Inputs

| Field | Required | Description |
|-------|----------|-------------|
| Context | Yes | Jira ID, API name, business problem |
| Source Material | No | Spec links, data model docs (`N/A` if none) |
| Endpoints | No | HTTP method + path in scope (`N/A` for doc stories) |
| Mandatory Acceptance Criteria | Yes | Free-text scenarios to cover |
| References | No | Miro board and Confluence URLs (`N/A` if unavailable) |

---

## Output → Markdown File

The file is written to:
```
agents/requirements/output/<jira-id>-<slug>.md
```

Open it in the IDE or copy-paste the contents directly into a Jira story description field.

---

## Story format

```
Description
  As a [role], I want [goal] so that [value].

Acceptance Criteria   (Gherkin: Given / When / Then)
  AC 1: [Scenario Title]
  AC 2: ...

Solution Outline
  Technical Reference   — object/system, query logic, reference links
  Mapping Dictionary    — API field ↔ source field table
  Implementation Steps  — phased step-by-step guide

Notes & Constraints
  Security      — auth policies, NFR requirements
  Performance   — SLA targets
  Dependencies  — upstream APIs, fragments, docs
```

---

## Reference example

The canonical output example is the **Confluence Documentation Update** story, available at:
```
agents/requirements/output/confluence-doc-update-user-story.md
```

---

## Folder structure

```
requirements/
├── rules/
│   └── intent-gen-user-story.mdc   ← prompt rule
├── examples/                        ← reference inputs (add .md files here)
└── README.md
```
