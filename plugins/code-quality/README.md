# code-quality

Automated PR code review for TypeScript projects. Five specialized agents run in parallel on your PR diff and post findings as a GitHub review with inline comments.

## Agents

| Agent | Domain | Color |
|-------|--------|-------|
| general-reviewer | Logic correctness, naming, readability, error handling, edge cases | blue |
| type-design-analyzer | Type safety, generics, narrowing, exhaustiveness, interface design | cyan |
| code-simplifier | Unnecessary complexity, dead code, redundant logic, simpler alternatives | green |
| security-analyzer | Injection, auth gaps, secrets, path traversal, SSRF, ReDoS | red |
| async-perf-analyzer | Missing await, sequential-when-parallel, N+1 queries, memory leaks | magenta |

## Usage

```
/review-pr <number>
```

Requires the GitHub CLI (`gh`) to be authenticated.

## What Gets Posted

- **Critical** and **suggestion** findings are posted as inline comments on the specific lines
- **Nit** findings are collected in the summary comment only
- The review is posted as `COMMENT` by default (does not block merge)

## Configuration

Create `.claude/code-quality.local.md` in your project root:

```yaml
---
agents:
  - general
  - types
  - simplify
  - security
  - async-perf
exclude_patterns:
  - "**/*.test.ts"
  - "**/*.spec.ts"
  - "**/generated/**"
review_event: COMMENT
---
```

All settings are optional. Defaults are used when the file doesn't exist or a setting is missing.

## Philosophy

High signal-to-noise ratio. Kind but direct — a quick suggestion with a one-sentence justification, never a lecture.
