---
name: review-code
description: Run automated code review on local changes
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash
  - Task
---

Run the code-review skill to perform automated code review on local changes.

The optional argument is a git ref to diff against. Use the optional `--agents` flag to run only specific agents. Examples:

- `/review-code` — review all uncommitted changes
- `/review-code main` — review diff against `main`
- `/review-code --agents security` — run only the security agent on uncommitted changes
- `/review-code main --agents security,types` — run security and types agents against `main`

Dispatch specialized agents (general, types, simplify, security, async-perf) in parallel to analyze the diff, then print findings to the terminal grouped by severity.

Follow the orchestration steps in `${CLAUDE_PLUGIN_ROOT}/skills/code-review/SKILL.md`.
