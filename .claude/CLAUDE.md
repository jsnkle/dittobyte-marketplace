# DittoByte Marketplace — Development

This repository is the `dittobyte-marketplace` Claude Code plugin marketplace. When working on this codebase, you are editing the marketplace and its plugins — not using them.

## Marketplace Structure

| Component | Location |
|-----------|----------|
| Marketplace catalog | `.claude-plugin/marketplace.json` |
| Plugins | `plugins/<plugin-name>/` |

## Plugin: monorepo-architecture

Located at `plugins/monorepo-architecture/`.

| Component | Location |
|-----------|----------|
| Plugin manifest | `plugins/monorepo-architecture/.claude-plugin/plugin.json` |
| Slash commands | `plugins/monorepo-architecture/commands/` |
| Agents | `plugins/monorepo-architecture/agents/` |
| Skills | `plugins/monorepo-architecture/skills/` |
| Hooks | `plugins/monorepo-architecture/hooks/` |
| Shared reference docs | `plugins/monorepo-architecture/references/` |

## Development Guidelines

- When adding a new plugin, create it under `plugins/<name>/` with its own `.claude-plugin/plugin.json`, then add an entry to `.claude-plugin/marketplace.json`.
- The `references/architecture.md` file within a plugin is its source of truth. Skills and agents reference it via `${CLAUDE_PLUGIN_ROOT}/references/architecture.md`.
- All paths in plugins are configurable via `.claude/monorepo-architecture.local.md` YAML frontmatter. Always use default values as fallback.
- Hook scripts must remain fast and deterministic — no LLM calls, no network access.
- Skills should use progressive disclosure: keep SKILL.md concise and load detailed reference content on demand.
- The architecture-reviewer agent is read-only — it must never modify files.
