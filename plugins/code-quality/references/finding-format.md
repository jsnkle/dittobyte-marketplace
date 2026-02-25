# Finding Format

Structured output format that all code-quality agents must follow. The orchestrator parses this format to deduplicate, categorize, and present findings.

## JSON Schema

Each agent returns a JSON array of findings. Every finding must include all fields:

```json
[
  {
    "file": "src/auth/service.ts",
    "line": 42,
    "severity": "critical",
    "category": "security",
    "message": "User input interpolated into SQL query.",
    "why": "Allows SQL injection — use parameterized queries instead."
  }
]
```

### Fields

| Field | Type | Description |
|-------|------|-------------|
| `file` | string | Relative file path as it appears in the source |
| `line` | number | Line number in the file |
| `severity` | string | One of: `critical`, `suggestion`, `nit` |
| `category` | string | Agent's domain tag (see below) |
| `message` | string | Brief actionable statement — what to change |
| `why` | string | One sentence justification — why it matters |

### Category Tags

Each agent uses its own category tag:

| Agent | Category tag |
|-------|-------------|
| `general-reviewer` | `general` |
| `type-design-analyzer` | `types` |
| `code-simplifier` | `simplify` |
| `security-analyzer` | `security` |
| `async-perf-analyzer` | `async-perf` |

Custom agents use their `<name>` (the filename without `.md`) as the category tag. For example, an agent at `.claude/code-quality-agents/no-console-log.md` uses category `no-console-log`.

## Agent Return Contract

- Return valid JSON only — no markdown wrapping, no explanation text
- Return an empty array `[]` if no findings
- Never return findings outside your domain (see `${CLAUDE_PLUGIN_ROOT}/references/review-guidelines.md`)
- Only return findings for lines present in the provided code or diff
- Use the line number from the **new** version of the file when reviewing diffs
