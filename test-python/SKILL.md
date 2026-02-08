---
name: test-python
description: Run pre-commit and pytest, then summarize issues
context: fork
agent: Bash
model: haiku
---

Execute these commands in the current project directory and provide a concise summary:

1. Run: `uv run prek run --all-files`
2. Run: `uv run pytest`

Provide a summary with:
- Which checks passed/failed
- Specific files and line numbers with issues
- Test results and coverage percentage
- Keep it concise and actionable
