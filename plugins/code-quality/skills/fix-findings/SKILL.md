---
name: fix-findings
description: >
  Plans and applies fixes for code review findings from conversation context.
  Two-phase: enters plan mode for user review, then implements approved fixes.
  Trigger phrases: "fix findings", "fix issues", "apply fixes", "fix review".
---

# Fix Findings

Reads review findings from the current conversation, enters plan mode to present a fix plan, and applies approved fixes.

## Orchestration Steps

### Step 1 — Identify findings in conversation

Scan the conversation for review output produced by any code-quality review command. Look for the standard terminal format:

```
## Critical Issues
- <file>:<line> — [<category>] <message>
  Why: <justification>

## Suggestions
- <file>:<line> — [<category>] <message>
  Why: <justification>

## Nits
- <file>:<line> — [<category>] <message>
  Why: <justification>
```

Parse each finding into: file, line, severity (from the section heading), category, message, and justification.

If no review output is found in the conversation, print:

```
No review findings in this conversation. Run a review command first (e.g., /review-code).
```

Then stop.

### Step 2 — Assess fixability

For each finding, read the relevant file and surrounding lines. Classify as:

- **fixable** — a concrete, unambiguous code change can be determined from the finding message alone (e.g., "add null check", "use parameterized query", "remove unused import", "add return type annotation")
- **skip** — requires design decisions, broad refactoring, or subjective judgment (e.g., "consider redesigning this API", "extract to a shared module", "split this function")

### Step 3 — Enter plan mode and present fix plan

Call `EnterPlanMode`. In the plan, write:

**Fixes section** — each fixable finding with file, line, category, finding message, and the proposed change:

```
## Fixes

1. `src/auth/service.ts:42` — [security] Use parameterized query instead of string interpolation
   → Replace template literal with `db.query(sql, [params])` pattern

2. `src/utils/parse.ts:15` — [types] Add explicit return type annotation
   → Add `: ParseResult | null` return type
```

**Skipped section** — each non-fixable finding with the reason it can't be auto-fixed:

```
## Skipped (requires manual review)

- `src/api/routes.ts:88` — [general] Consider splitting this handler into smaller functions
  Reason: Requires architectural decision on function boundaries
```

Omit the Skipped section if all findings are fixable. Omit the Fixes section if none are fixable (in that case, note that all findings require manual review and no automated fixes are possible).

Call `ExitPlanMode` to present the plan for user approval.

### Step 4 — Apply fixes

After the user approves the plan:

1. Group fixes by file
2. Within each file, process fixes from **bottom to top** (highest line number first) to avoid line-number drift from earlier edits
3. For each fix: read the current file content, apply the edit using the Edit tool, and briefly note what changed

### Step 5 — Print summary

```
# Fix Summary

Applied: <count> fixes
Skipped: <count> (manual review needed)

Run a review command to verify the fixes.
```

If all findings were skipped, print:

```
# Fix Summary

All <count> findings require manual review — no automated fixes applied.
```
