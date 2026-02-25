---
name: commit-review
description: >
  Orchestrates automated code review on a specific commit by dispatching five
  specialized agents in parallel against the commit's diff, collecting findings,
  and printing results to the terminal grouped by severity.
  Trigger phrases: "review commit", "review a commit", "check commit".
---

# Commit Review

Runs automated code review on a specific commit by dispatching five specialized agents in parallel, then printing findings to the terminal grouped by severity.

## Usage

Requires one argument: a commit ref (e.g., `abc1234`, `HEAD~3`).

## Configuration

Read configuration from `.claude/code-quality.local.md` if it exists. Parse YAML frontmatter for these settings (use defaults if the file doesn't exist or a setting is missing):

| Setting | Default | Description |
|---------|---------|-------------|
| `agents` | all five | Subset of agents to run: `general`, `types`, `simplify`, `security`, `async-perf` |
| `exclude_patterns` | `[]` | Glob patterns to exclude from review (e.g., `**/*.test.ts`, `**/generated/**`) |

## Orchestration Steps

### Step 1 — Get the commit diff and message

```bash
git diff <sha>^..<sha>
```

```bash
git log -1 --format=%B <sha>
```

Store the diff and commit message. If the commit ref is invalid or the diff is empty, print `No changes to review.` and stop.

### Step 2 — Apply exclusions

If `exclude_patterns` is configured, filter the diff to remove matching files before sending to agents.

### Step 3 — Dispatch agents in parallel

Launch all configured agents concurrently using the Task tool. Each agent receives:

- The commit diff (filtered)
- The list of changed files
- The commit message as additional context
- Instructions to follow `${CLAUDE_PLUGIN_ROOT}/references/review-guidelines.md`
- Output format from `${CLAUDE_PLUGIN_ROOT}/skills/pr-review/references/review-format.md`

Agent mapping:

| Config key | Agent file |
|------------|-----------|
| `general` | `${CLAUDE_PLUGIN_ROOT}/agents/general-reviewer.md` |
| `types` | `${CLAUDE_PLUGIN_ROOT}/agents/type-design-analyzer.md` |
| `simplify` | `${CLAUDE_PLUGIN_ROOT}/agents/code-simplifier.md` |
| `security` | `${CLAUDE_PLUGIN_ROOT}/agents/security-analyzer.md` |
| `async-perf` | `${CLAUDE_PLUGIN_ROOT}/agents/async-perf-analyzer.md` |

### Step 4 — Collect and deduplicate

1. Parse JSON findings from each agent
2. Deduplicate: if multiple agents flag the same file + line, keep the one with higher severity
3. Group findings by severity: `critical`, `suggestion`, `nit`

### Step 5 — Print findings to terminal

Print findings grouped by severity using this format:

```
# Commit Review — <short sha>

Commit: <commit message first line>
Files reviewed: <count> | Findings: <critical_count> critical, <suggestion_count> suggestions, <nit_count> nits

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

Omit any severity section that has zero findings.

When there are no findings at all, print: `No issues found. Looks good!`
