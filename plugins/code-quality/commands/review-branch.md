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

The optional argument is the base branch to diff against. Examples:

- `/review-branch` — review all changes since diverging from `main`
- `/review-branch develop` — review all changes since diverging from `develop`

Dispatch five specialized agents (general, types, simplify, security, async-perf) in parallel to analyze the aggregate diff, then print findings to the terminal grouped by severity.

Follow the orchestration steps in `${CLAUDE_PLUGIN_ROOT}/skills/branch-review/SKILL.md`.
