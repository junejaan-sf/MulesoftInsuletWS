# Code Review Agent

@agents/review/rules/intent-review.mdc

---

**How to provide the code to review:**

Point the agent at your Mule project by @mentioning it in chat:

```
@<your-project-path>/  review this project
```

Or paste specific files directly in chat for a targeted review.

**The agent evaluates against all review standards:**
- Flow naming, global config structure, error handling
- Logging, DataWeave, properties, security
- MUnit coverage, POM/Maven standards, API design

**Output:** Structured report with CRITICAL / MAJOR / MINOR findings and a priority action list.

> One agent per chat. Start a new chat with `/use-review` for each review task.
