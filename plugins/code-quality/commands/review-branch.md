---
name: review-branch
description: Run automated code review on all branch changes since diverging from a base
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash
  - Task
---

Run the branch-review skill to perform automated code review on all changes in the current branch.

The optional argument is the base branch to diff against. Use the optional `--agents` flag to run only specific agents. Examples:

- `/review-branch` — review all changes since diverging from `main`
- `/review-branch develop` — review all changes since diverging from `develop`
- `/review-branch --agents security` — run only the security agent
- `/review-branch develop --agents security,types` — run security and types agents

Dispatch specialized agents in parallel to analyze the aggregate diff, then print findings to the terminal grouped by severity. Built-in agents: `general`, `types`, `simplify`, `security`, `async-perf`. Custom agents use the `custom:<name>` prefix (e.g., `--agents security,custom:no-console-log`).

Follow the orchestration steps in `${CLAUDE_PLUGIN_ROOT}/skills/branch-review/SKILL.md`.
