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

The argument is a commit ref. Use the optional `--agents` flag to run only specific agents. Examples:

- `/review-commit abc1234` — review a specific commit by SHA
- `/review-commit HEAD~3` — review the commit three behind HEAD
- `/review-commit abc1234 --agents security` — run only the security agent
- `/review-commit HEAD~3 --agents security,types` — run security and types agents

Dispatch specialized agents in parallel to analyze the commit diff, then print findings to the terminal grouped by severity. Built-in agents: `general`, `types`, `simplify`, `security`, `async-perf`. Custom agents use the `custom:<name>` prefix (e.g., `--agents security,custom:no-console-log`).

Follow the orchestration steps in `${CLAUDE_PLUGIN_ROOT}/skills/commit-review/SKILL.md`.
