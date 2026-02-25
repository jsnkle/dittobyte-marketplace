# Review Output Format

Structured output format that all code-quality agents must follow. The orchestrator parses this format to deduplicate, categorize, and post findings.

## Finding Format

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
| `file` | string | Relative file path as it appears in the diff |
| `line` | number | Line number in the new version of the file (right side of the diff) |
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

## Inline Comment Format

When posted to GitHub, each inline comment is rendered as:

```
**[severity | category]** Brief actionable statement.

Why: One sentence justification.
```

Examples:

```
**[critical | security]** User input interpolated into SQL query.

Why: Allows SQL injection — use parameterized queries instead.
```

```
**[suggestion | types]** Consider narrowing return type from `string` to template literal.

Why: Callers get better autocomplete and catch typos at compile time.
```

## Summary Format

The overall review summary posted as the review body:

```markdown
## Code Review Summary

**PR:** #<number> — <title>
**Files reviewed:** <count> | **Findings:** <critical_count> critical, <suggestion_count> suggestions, <nit_count> nits

### Critical Issues
- **<file>:<line>** — <message> (<category>)

### Key Suggestions
- <message> (<category>)

### Nits
- **<file>:<line>** — <message> (<category>)

---
*Reviewed by code-quality plugin*
```

If a severity section has no findings, omit it entirely.

## Empty Review

If all agents return zero findings:

```markdown
## Code Review Summary

**PR:** #<number> — <title>
**Files reviewed:** <count> | **Findings:** 0

No issues found. Looks good!

---
*Reviewed by code-quality plugin*
```

## Agent Return Contract

- Return valid JSON only — no markdown wrapping, no explanation text
- Return an empty array `[]` if no findings
- Never return findings outside your domain (see review-guidelines.md)
- Never return findings for lines not in the PR diff
- Use the line number from the **new** version of the file (right side)
