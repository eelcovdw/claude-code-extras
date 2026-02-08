---
name: code-review
description: Review a git diff for bugs, security issues, and improvements
context: fork
model: opus
argument-hint: [optional: custom review focus]
---

Review only the changes on the current branch. Use `git merge-base main HEAD` to find where the branch diverged, then review `git diff $(git merge-base main HEAD)..HEAD`. If on main with no branch changes, review the last commit.

Only review code from this branch's commits, not unrelated changes from main.

Frame feedback as questions, not commands. Provide specific file paths and line numbers. $ARGUMENTS

## Comment labels

Use Conventional Comments, prefix every comment with one of these labels:

- **issue:** A specific problem. Pair with a suggestion when possible.
- **suggestion:** A proposed improvement. Be explicit about what and why.
- **todo:** A small, trivial, but necessary change.
- **nitpick:** A trivial preference-based request. Non-blocking.
- **question:** A potential concern you're not sure about. Ask for clarification.
- **thought:** An idea that popped up from reviewing. Non-blocking.
- **chore:** A process-related task that must be done before merging.
- **note:** Something the reader should take note of. Non-blocking.

## Output Format

Group comments by file, with line numbers. End with a brief summary of the overall changes.
