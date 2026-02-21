---
name: where
description: Get placement guidance for where a file or concept belongs
argument-hint: <description>
allowed-tools:
  - Read
  - Glob
  - Grep
---

The user wants to know where to place: `$ARGUMENTS`

Use the file-placement skill and the rules from `${CLAUDE_PLUGIN_ROOT}/references/architecture.md` to determine the correct file path and architectural layer.

Read `.claude/monorepo-architecture.local.md` for any path overrides (use defaults if it doesn't exist).

Respond with:
1. The recommended file path
2. Which layer it belongs to and why
3. Any boundary rules to keep in mind

Do NOT create any files — this is guidance only.
