---
name: review-pr
description: Run automated code review on a pull request
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash
  - Task
---

Run the pr-review skill to perform automated code review on the specified pull request.

The argument is a PR number. Example: `/review-pr 42`

Dispatch five specialized agents (general, types, simplify, security, async-perf) in parallel to analyze the PR diff, then post findings as a GitHub review with inline comments and a summary.

Follow the orchestration steps in `${CLAUDE_PLUGIN_ROOT}/skills/pr-review/SKILL.md`.
