---
name: review-commit
description: Run automated code review on a specific commit
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash
  - Task
---

Run the commit-review skill to perform automated code review on a specific commit.

The argument is a commit ref. Examples:

- `/review-commit abc1234` — review a specific commit by SHA
- `/review-commit HEAD~3` — review the commit three behind HEAD

Dispatch five specialized agents (general, types, simplify, security, async-perf) in parallel to analyze the commit diff, then print findings to the terminal grouped by severity.

Follow the orchestration steps in `${CLAUDE_PLUGIN_ROOT}/skills/commit-review/SKILL.md`.
