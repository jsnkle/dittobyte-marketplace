---
name: review-file
description: Run automated code review on entire files or a directory
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash
  - Task
---

Run the file-review skill to perform automated code review on complete file contents.

The argument is a file path or directory. Examples:

- `/review-file src/auth/service.ts` — review a single file
- `/review-file src/utils/` — review all source files in a directory

Dispatch five specialized agents (general, types, simplify, security, async-perf) in parallel to analyze the file contents, then print findings to the terminal grouped by severity.

Follow the orchestration steps in `${CLAUDE_PLUGIN_ROOT}/skills/file-review/SKILL.md`.
