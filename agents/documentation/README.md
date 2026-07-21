# Documentation Agent

Generates Confluence-ready API documentation for MuleSoft projects — including architecture descriptions, flow summaries, endpoint references, data mappings, NFRs, and operational notes — from the actual source code.

## Activate

Type `/use-docs` in a new Cursor chat.

## Folder Structure

```
documentation/
├── rules/
│   ├── intent-gen-docs.mdc           ← main entry point
│   └── gen-docs-implementation.mdc   ← full documentation generation standards
├── examples/                          ← reference documentation outputs
├── templates/                         ← documentation structure templates
└── README.md
```

## Inputs → `project/input_docs/`

Place any of these before running `/use-docs`:
- Mule project root folder reference (via `@<project-path>/` in chat)
- RAML spec and Mule XML flow files
- Confluence export or supplemental design notes (`.md`, `.txt`)

If the folder is empty, @mention the Mule project directory directly in chat.

## Outputs → `project/output_docs/`

Two files per project:

| File | Purpose |
|------|---------|
| `{project-name}-confluence.html` | Self-contained HTML with embedded diagrams — paste into Confluence "Insert HTML" or use "Import HTML" |
| `{project-name}.docx` | Word fallback for Confluence "Import Word document" |

## Tips

- The agent reads your actual Mule XML, RAML, and property files — no manual input required beyond pointing it at the project
- Audience tone (technical vs. business) is configurable — the agent asks before generating
- Diagrams are rendered as embedded base64 PNG — no external dependencies in the output HTML
