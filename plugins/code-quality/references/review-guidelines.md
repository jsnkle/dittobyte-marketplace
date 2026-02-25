# Code Review Guidelines

Source of truth for all code-quality agents. Every finding must follow these rules.

## Philosophy

**High signal-to-noise ratio.** A review that flags everything is noise. Flag what matters.

- Kind but direct — a quick suggestion with a one-sentence justification, never a lecture
- Framework-agnostic — works with any TypeScript project (React, NestJS, Hono, standalone, monorepo)
- Diff-scoped — only review what changed in the PR, not the entire codebase
- Actionable — every finding must suggest a concrete fix or direction

## Severity Levels

| Level | Meaning | Where posted |
|-------|---------|--------------|
| `critical` | Will cause a bug, security vulnerability, data loss, or crash | Inline comment |
| `suggestion` | Would meaningfully improve correctness, clarity, or maintainability | Inline comment |
| `nit` | Style preference, minor improvement, take-it-or-leave-it | Summary only |

### Choosing severity

- If you're unsure between `critical` and `suggestion`, ask: "Would this cause a production incident?" If yes, it's critical.
- If you're unsure between `suggestion` and `nit`, ask: "Would a senior engineer flag this in review?" If yes, it's suggestion.
- When in doubt, go lower. False alarms erode trust.

## What NOT to Flag

- Formatting or style already handled by linters/formatters (Prettier, ESLint)
- Missing documentation unless a public API is genuinely unclear
- Test file implementation details (test structure, assertion style) unless there's a correctness issue
- Patterns that are consistent with the rest of the codebase, even if you'd prefer a different approach
- Changes outside the PR diff

## Non-Overlapping Domains

Each agent owns a specific domain. Do NOT flag issues outside your domain:

| Agent | Domain |
|-------|--------|
| `general-reviewer` | Logic correctness, naming, readability, error handling, edge cases, idiomatic patterns |
| `type-design-analyzer` | Type safety holes (`any`, `as`, `!`), generics, narrowing, exhaustiveness, interface design |
| `code-simplifier` | Unnecessary complexity, dead code, redundant logic, simpler alternatives, DRY within the diff |
| `security-analyzer` | Injection (SQL/XSS/command), auth gaps, secrets, path traversal, SSRF, unsafe deserialization, ReDoS |
| `async-perf-analyzer` | Missing `await`, sequential-when-parallel, N+1 queries, memory leaks, unnecessary re-renders, unbounded fetches |

If a finding spans two domains (e.g., a type assertion that also hides a security issue), the agent whose domain is more directly impacted owns it.

## Framework Awareness

Agents do not assume any specific framework. They recognize frameworks from imports and adapt:

- React: hooks rules, dependency arrays, memoization
- NestJS: decorator patterns, DI scoping, guard/interceptor ordering
- Hono/Express: middleware ordering, request validation, response handling
- Drizzle/Prisma: query patterns, relation loading, transaction scoping

This context informs findings but is never a prerequisite — pure TypeScript is the baseline.

## Tone

```
Good:  "Consider using `Map` here — O(1) lookups vs O(n) array search."
Bad:   "You should really be using a Map here. Array.find() is O(n) which will cause performance issues at scale and is generally considered an anti-pattern when you have a lookup key available."
```

One sentence. One justification. Move on.
