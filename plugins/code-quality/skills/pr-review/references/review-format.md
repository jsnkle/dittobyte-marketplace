# GitHub Review Format

Rendering rules for posting code-quality findings to GitHub as a pull request review. For the agent JSON output schema and return contract, see `${CLAUDE_PLUGIN_ROOT}/references/finding-format.md`.

## Inline Comment Format

Each inline comment is rendered as:

```markdown
**[severity | category]** Brief actionable statement.

Why: One sentence justification.

---
*Reviewed by jsnkle code-quality plugin*
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
*Reviewed by jsnkle code-quality plugin*
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
*Reviewed by jsnkle code-quality plugin*
```
