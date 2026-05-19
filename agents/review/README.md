# Review Agent

Performs a comprehensive, standards-based code review of MuleSoft projects against all Insulet review rulesets — covering naming, logging, error handling, DataWeave, security, MUnit, POM, Maven, and API design.

## Activate

Type `/use-review` in a new Cursor chat.

## Folder Structure

```
review/
├── rules/
│   ├── intent-review.mdc                  ← main entry point
│   ├── review-api-design-standards.mdc
│   ├── review-dataweave-standards.mdc
│   ├── review-development-flow.mdc
│   ├── review-error-handling.mdc
│   ├── review-logging-standards.mdc
│   ├── review-maven-settings.mdc
│   ├── review-mule-flow-naming.mdc
│   ├── review-mule-global-config.mdc
│   ├── review-munit-testing.mdc
│   ├── review-pom-maven-standards.mdc
│   ├── review-properties-config.mdc
│   └── review-security-standards.mdc
├── examples/                               ← reference review reports
└── README.md
```

## How to Provide Code

@mention the target project in chat after activating:

```
@<your-mule-project-path>/  please review this project
```

Or paste specific files for a targeted review.

## Output — Structured Review Report

```
Summary Table
  → each ruleset | pass/fail | finding count by severity

Findings by Severity
  CRITICAL  — must fix before merge (security, compliance, operational gaps)
  MAJOR     — should fix before merge (correctness, standards violations)
  MINOR     — optional improvements, housekeeping

What's Done Well
  → areas where the code correctly follows standards

Recommended Priority
  → tiered action list with suggested timelines
```

## Review Standards Covered

| Ruleset | Covers |
|---------|--------|
| `review-mule-flow-naming.mdc` | Flow, sub-flow, and processor naming conventions |
| `review-mule-global-config.mdc` | Global config and connector config structure |
| `review-error-handling.mdc` | Error handler patterns, on-error-propagate vs continue |
| `review-logging-standards.mdc` | Insulet Custom Logger usage, log levels, PII masking |
| `review-dataweave-standards.mdc` | DWL externalization, script naming, inline limits |
| `review-properties-config.mdc` | Property file structure and environment config |
| `review-security-standards.mdc` | Secret management, encryption, credential handling |
| `review-munit-testing.mdc` | MUnit coverage, mock completeness, assertion quality |
| `review-api-design-standards.mdc` | RAML structure, naming, CommonLib usage |
| `review-pom-maven-standards.mdc` | POM artifact naming, dependency management |
| `review-maven-settings.mdc` | Maven settings.xml, Exchange credentials |
| `review-development-flow.mdc` | Pre-PR checklist and development flow gate |
