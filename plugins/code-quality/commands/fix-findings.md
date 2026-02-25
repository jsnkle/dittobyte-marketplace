---
name: fix-findings
description: Plan and apply fixes for review findings
allowed-tools:
  - Read
  - Edit
  - Grep
  - Glob
  - Bash
---

Fix code review findings from the current conversation.

Reads findings produced by any review command (`/review-code`, `/review-file`, `/review-commit`, `/review-branch`, `/review-pr`), enters plan mode so you can approve the proposed fixes, then applies them.

- `/fix-findings` — fix all findings from the most recent review

No arguments or flags — operates on whatever review output is already in the conversation.

Follow the orchestration steps in `${CLAUDE_PLUGIN_ROOT}/skills/fix-findings/SKILL.md`.
