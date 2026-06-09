# Design Agent

Produces technical / solution design documents for MuleSoft integration projects —
Application Overview, Non-Functional Requirements, High-Level Architecture diagrams, and
Interface Specifications — **before any code is written**. Output is Confluence- and
Jira-ready Markdown that becomes the primary input for the RAML and develop agents.

## Rules

The agent ships three primary rules plus the NotebookLM extraction set.

| Rule | Purpose | Trigger |
|------|---------|---------|
| `intent-gen-confluence-design.mdc` | **Main solution-design generator.** Hybrid generator that auto-pulls context from Jira, NotebookLM, and external API docs, confirms gaps, then writes a single 4-section design document matching Insulet's canonical Confluence pages. | `confluence design <api-name>` or `solution design <JIRA-ID>` |
| `sf-design-validation.mdc` | **Salesforce design-time validation.** Read-only validation of SF objects, fields, picklist values, auto-populated fields, and operations (composite graph, SOQL, INSERT/UPDATE/UPSERT) against a live org. Produces an Open Questions report + context block. | Auto-invoked from Step 2.5 of the design generator when an endpoint touches Salesforce |
| `design-standards-reference.mdc` | **Internal standards digest.** Compact design-phase summary of Insulet naming, URL, error-handling, logging, security, RAML, and field-naming standards. Read silently by the design agent to keep output consistent with the develop/RAML/review agents. Not surfaced in the output document. | Read internally during generation |

### NotebookLM extraction rules

| Rule | Purpose |
|------|---------|
| `intent-gen-design-from-notebooklm.mdc` | Current NotebookLM → initial design draft extraction |
| `intent-gen-design-from-notebooklm_v1.mdc` | Initial Confluence-doc draft per API (used by `use-notebooklm.md`) |
| `intent-gen-design-from-notebooklm_v2.mdc` | Alternate extraction format for downstream agents expecting the older structure |
| `use-notebooklm.md` | Activation guide for the NotebookLM extraction workflow |

## Folder Structure

```
design/
├── rules/
│   ├── intent-gen-confluence-design.mdc        ← main solution-design generator
│   ├── sf-design-validation.mdc                ← Salesforce design-time validation
│   ├── design-standards-reference.mdc          ← internal standards digest
│   ├── intent-gen-design-from-notebooklm.mdc   ← NotebookLM extraction
│   ├── intent-gen-design-from-notebooklm_v1.mdc
│   ├── intent-gen-design-from-notebooklm_v2.mdc
│   └── use-notebooklm.md                        ← NotebookLM activation guide
├── examples/       ← reference design documents (git-ignored working files)
├── templates/      ← design document templates
└── README.md
```

## Activate

In a new Cursor chat, `@mention` the rule you need, then provide the trigger:

```
@agents/design/rules/intent-gen-confluence-design.mdc
solution design NGONDL-931
```

or for NotebookLM-driven drafts:

```
@agents/design/rules/intent-gen-design-from-notebooklm_v1.mdc
notebooklm Drupal
```

## Inputs

No fixed input folder — the design generator pulls context from live sources via MCP:

- **Jira** (read-only): feature + sys-api stories
- **NotebookLM** (read): notebook query for business purpose, endpoints, mappings, rules
- **External docs**: any reference links you paste (`WebFetch`)
- **Salesforce** (read-only): live org metadata when an endpoint targets SF

You only need to confirm the gaps the agent surfaces in Step 2 (API name, domain, endpoints in scope, caller/downstream systems).

## Outputs → `agents/design/output/`

- `{api-technical-name}-design.md` — the solution design document (4 sections: Application
  Overview, Non-Functional Requirements, High-Level Architecture, Interface Specifications),
  optionally followed by an `## Open Questions` SF-validation section.

NotebookLM extraction drafts are written to `agents/design/examples/{api-technical-name}.md`.

## Handoff

The design document produced here becomes the primary input for the downstream agents:

```
agents/design/output/{api}-design.md
        → /use-raml      (@mention the design doc)
        → /use-develop   (richer business context than Jira/Confluence alone)
        → /use-docs      (complete TBC fields once code exists)
```
