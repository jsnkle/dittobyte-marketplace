---
name: create-agent
description: Scaffold a custom review agent
allowed-tools:
  - Read
  - Write
  - Glob
  - AskUserQuestion
---

Scaffold a new custom review agent for the code-quality plugin.

The argument is the agent name. Examples:

- `/create-agent no-console-log` — create a custom agent that flags console.log usage
- `/create-agent react-hooks` — create a custom agent for React hooks best practices

The name must be lowercase-hyphenated (e.g., `no-console-log`, not `noConsoleLog`).

Follow the orchestration steps in `${CLAUDE_PLUGIN_ROOT}/skills/create-agent/SKILL.md`.
