# Design Agent

Produces technical design documents for MuleSoft integration projects — architecture diagrams, flow logic, data mapping tables, and implementation plans — before any code is written.

## Status

Placeholder — rules to be authored. Place design rulesets under `rules/` when ready.

## Folder Structure

```
design/
├── rules/          ← design ruleset (.mdc files) — to be added
├── examples/       ← reference design documents
├── templates/      ← design document templates
└── README.md
```

## Activate

When rules are available:
1. Use `/use-design` command in a new chat
2. Or @mention the intent rule directly: `@agents/design/rules/intent-gen-design.mdc`

## Inputs → `project/input_design/`

- Business requirements (`.md`, `.txt`)
- Meeting notes or architecture discussions
- Reference diagrams or existing design docs (paste screenshots in chat)

## Outputs → `project/output_design/`

- Technical design document with architecture diagrams
- Data mapping tables
- Implementation plan and flow descriptions

## Handoff

The design document produced here becomes the primary input for the RAML agent:
`project/output_design/` → copy to `project/input_raml/`
