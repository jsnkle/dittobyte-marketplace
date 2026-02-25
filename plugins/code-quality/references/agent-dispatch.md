# Agent Dispatch

Resolution rules for mapping agent config keys to agent files. Used by all review skills during Step 3 (Dispatch).

## Built-in Agents

| Config key | Agent file |
|------------|-----------|
| `general` | `${CLAUDE_PLUGIN_ROOT}/agents/general-reviewer.md` |
| `types` | `${CLAUDE_PLUGIN_ROOT}/agents/type-design-analyzer.md` |
| `simplify` | `${CLAUDE_PLUGIN_ROOT}/agents/code-simplifier.md` |
| `security` | `${CLAUDE_PLUGIN_ROOT}/agents/security-analyzer.md` |
| `async-perf` | `${CLAUDE_PLUGIN_ROOT}/agents/async-perf-analyzer.md` |

## Custom Agents

Config keys with the `custom:` prefix resolve to project-local agent files:

```
custom:<name>  →  .claude/code-quality-agents/<name>.md
```

For example, `custom:no-console-log` resolves to `.claude/code-quality-agents/no-console-log.md`.

Custom agents receive the same inputs as built-in agents (diff/file contents, file list, review guidelines, output format). They must follow the same finding format.

## Validation

Before dispatching, validate every configured agent key:

1. If the key matches a built-in name (`general`, `types`, `simplify`, `security`, `async-perf`), resolve it from the table above.
2. If the key starts with `custom:`, extract `<name>` and check that `.claude/code-quality-agents/<name>.md` exists. If the file is missing, print an error and stop:
   ```
   Custom agent not found: .claude/code-quality-agents/<name>.md
   Available custom agents: <list>
   ```
   To build the "Available" list, glob `.claude/code-quality-agents/*.md` and list filenames without the `.md` extension. If no custom agents exist, omit the "Available" line.
3. If the key matches neither a built-in name nor the `custom:` prefix, print an error and stop:
   ```
   Unknown agent: "<key>"
   Valid agents: general, types, simplify, security, async-perf, custom:<name>
   ```
