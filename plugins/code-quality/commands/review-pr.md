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

The argument is a PR number. Use the optional `--agents` flag to run only specific agents. Examples:

- `/review-pr 42` — review PR #42 with all agents
- `/review-pr 42 --agents security` — run only the security agent
- `/review-pr 42 --agents security,types` — run security and types agents

Dispatch specialized agents in parallel to analyze the PR diff, then post findings as a GitHub review with inline comments and a summary. Built-in agents: `general`, `types`, `simplify`, `security`, `async-perf`. Custom agents use the `custom:<name>` prefix (e.g., `--agents security,custom:no-console-log`).

Follow the orchestration steps in `${CLAUDE_PLUGIN_ROOT}/skills/pr-review/SKILL.md`.
