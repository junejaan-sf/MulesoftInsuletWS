# Confluence Documentation Update — User Story

**Jira ID:** TBD
**Type:** User Story
**Domain:** Integration Architecture · Documentation
**APIs in scope:** 10
**Layers:** Experience · System · Process

---

## Description

As an **Integration Architect**, I want to update the Confluence documentation for all in-scope MuleSoft APIs to match the latest documentation format defined by the **aspn-exp-api** reference page — including standardized section structure and embedded flow diagrams — so that all integration API pages are consistent, discoverable, and accurate for developers and stakeholders.

**APIs in scope (10):**

| API | Layer |
|-----|-------|
| `sfl-consents-exp-api` | Experience |
| `sfl-consents-sys-api` | System |
| `sfl-crm-persona-sys-api` | System |
| `sfl-cases-sys-api` | System |
| `sfl-campaigns-sys-api` | System |
| `sfmc-consents-sys-api` | System |
| `accounts-proc-api` | Process |
| `leads-proc-api` | Process |
| `consents-proc-api` | Process |
| `drupal-exp-api` | Experience |

---

## Acceptance Criteria

### AC 1 — Documentation Format Alignment

**Given** each of the 10 in-scope APIs has an existing or new Confluence page in the Mule space.
**When** the documentation is reviewed against the reference page `aspn-exp-api`.
**Then:**
- Each API page must be restructured to match the exact section layout defined by the `aspn-exp-api` reference.
- All mandatory sections present in the reference (Overview, Architecture, Flow Description, API Specification, Error Handling) must be present in every updated page.
- Formatting, heading hierarchy, and naming conventions must be consistent across all 10 pages.

---

### AC 2 — Flow Diagrams Added

**Given** the `aspn-exp-api` reference Confluence page contains embedded flow diagrams illustrating integration flows.
**When** each API page is created or updated as part of this story.
**Then:**
- A flow diagram matching the style and level of detail of the `aspn-exp-api` reference must be added to each API page.
- Flow diagrams must accurately represent the request/response flow, including any orchestration or transformation layers.
- Diagrams must be embedded directly in the Confluence page (not linked externally) unless a Miro board link is available.

---

### AC 3 — Full API Scope Coverage

**Given** the scope of this story includes exactly 10 APIs: `sfl-consents-exp-api`, `sfl-consents-sys-api`, `sfl-crm-persona-sys-api`, `sfl-cases-sys-api`, `sfl-campaigns-sys-api`, `sfmc-consents-sys-api`, `accounts-proc-api`, `leads-proc-api`, `consents-proc-api`, and `drupal-exp-api`.
**When** the documentation update sprint is completed.
**Then:**
- All 10 APIs must have an updated Confluence page before the story is marked Done.
- A tracking table or checklist must be maintained in the parent Confluence page or Jira story to show completion status per API.

---

### AC 4 — Review & Approval

**Given** all 10 API pages have been updated and flow diagrams have been added.
**When** the Integration Architect performs a final review of each page.
**Then:**
- Each updated page must be reviewed and approved by the Integration Architect or designated technical owner.
- Any review comments must be resolved before the story moves to Done.
- Page version history in Confluence must reflect the update with a meaningful change comment.

---

## Solution Outline

All Confluence pages reside in the `Mule` Confluence space. The formatting standard is derived from the `aspn-exp-api` reference page. No source system integration or data mapping is required — this is a documentation update task.

- **Miro Board:** N/A
- **Confluence Reference:** [aspn-exp-api](https://confluence.prod.insulet.com/wiki/spaces/Mule/pages/575537786/aspn-exp-api)

---

### Technical Reference

- **Reference page:** [aspn-exp-api — Confluence · Mule space](https://confluence.prod.insulet.com/wiki/spaces/Mule/pages/575537786/aspn-exp-api)
- **Confluence space:** `Mule`
- **Format standard:** `aspn-exp-api` section layout including Overview, Architecture, Flow Description, API Specification, Error Handling, and References sections, with embedded flow diagrams per flow.

---

### Mapping Dictionary

Section mapping from the reference format to each target API page.

| Section | Description | Required |
|---------|-------------|:--------:|
| Overview | Purpose, owner, version, and Exchange link | Yes |
| Architecture | Layer (Exp / Proc / Sys), consumers, upstream systems | Yes |
| Flow Description | Step-by-step narrative of each main flow | Yes |
| Flow Diagram | Embedded diagram matching `aspn-exp-api` style | Yes |
| API Specification | RAML/OAS reference, Exchange asset link | Yes |
| Error Handling | HTTP error codes, error schema, retry strategy | Yes |
| References | Miro board, related Jira stories, related Confluence pages | Yes |

---

### Technical Implementation Steps

#### 1. Reference Analysis

- **Audit `aspn-exp-api` page:** Review the reference Confluence page to extract the exact section structure, diagram style, and formatting conventions to be replicated.
- **Define documentation template:** Document the section checklist (Overview, Architecture, Flow Description, API Spec, Error Handling, References) that each page must contain.

#### 2. Per-API Documentation Update

- **Create or locate Confluence page:** For each of the 10 APIs, locate the existing page in the Mule Confluence space or create a new one under the appropriate parent.
- **Apply reference format:** Restructure the page content to match the section layout from `aspn-exp-api`. Reuse and adapt existing content where valid.
- **Add flow diagrams:** Embed a flow diagram for each API reflecting its integration flow. Diagrams may be created in Confluence draw.io or imported from Miro if available.
- **Update API specification section:** Ensure the API spec section references the correct Anypoint Exchange asset and version.

#### 3. Review & Publish

- **Internal review:** Share updated pages with the Integration Architect for review. Capture feedback and resolve all comments.
- **Publish & version:** Publish each page with a version comment (e.g., `Updated to match aspn-exp-api documentation standard`).
- **Update tracking checklist:** Mark each API as complete in the story tracking table once its page is approved and published.

---

### API Tracking Checklist

| API | Layer | Page Exists | Format Updated | Flow Diagram Added | Approved |
|-----|-------|:-----------:|:--------------:|:-----------------:|:--------:|
| `sfl-consents-exp-api` | Experience | — | — | — | — |
| `sfl-consents-sys-api` | System | — | — | — | — |
| `sfl-crm-persona-sys-api` | System | — | — | — | — |
| `sfl-cases-sys-api` | System | — | — | — | — |
| `sfl-campaigns-sys-api` | System | — | — | — | — |
| `sfmc-consents-sys-api` | System | — | — | — | — |
| `accounts-proc-api` | Process | — | — | — | — |
| `leads-proc-api` | Process | — | — | — | — |
| `consents-proc-api` | Process | — | — | — | — |
| `drupal-exp-api` | Experience | — | — | — | — |

---

## Notes & Constraints

### Security

> **Warning:** Confluence edit access to the `Mule` space is required for all contributors. Ensure permissions are granted before the sprint begins.

### Performance

No runtime performance requirements apply — this is a documentation-only story. Target completion of all 10 API pages within the agreed sprint.

### Dependencies

- The `aspn-exp-api` Confluence reference page must be finalized and approved before documentation work on the 10 APIs begins.
- Flow diagrams require accurate knowledge of each API flow; align with the respective API developers if diagrams are not yet available.
- Miro boards are currently N/A; this dependency should be revisited if boards become available during the sprint.
