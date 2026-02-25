---
name: commit-review
description: >
  Orchestrates automated code review on a specific commit by dispatching
  specialized agents in parallel against the commit's diff, collecting findings,
  and printing results to the terminal grouped by severity.
  Trigger phrases: "review commit", "review a commit", "check commit".
---

# Commit Review

Runs automated code review on a specific commit by dispatching specialized agents in parallel, then printing findings to the terminal grouped by severity.

## Usage

Requires one argument: a commit ref (e.g., `abc1234`, `HEAD~3`).

## Configuration

Read configuration from `.claude/code-quality.local.md` if it exists. Parse YAML frontmatter for these settings (use defaults if the file doesn't exist or a setting is missing):

| Setting | Default | Description |
|---------|---------|-------------|
| `agents` | all five | Subset of agents to run: `general`, `types`, `simplify`, `security`, `async-perf` |
| `exclude_patterns` | `[]` | Glob patterns to exclude from review (e.g., `**/*.test.ts`, `**/generated/**`) |

If the user passed `--agents <list>` in the command arguments, use that comma-separated list instead of the config file's `agents` setting. Valid built-in values: `general`, `types`, `simplify`, `security`, `async-perf`. Custom agents use the `custom:<name>` prefix (e.g., `custom:no-console-log`). See `${CLAUDE_PLUGIN_ROOT}/references/agent-dispatch.md` for resolution rules and validation.

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

Resolve each configured agent to its file using `${CLAUDE_PLUGIN_ROOT}/references/agent-dispatch.md`.

Launch all resolved agents concurrently using the Task tool. Each agent receives:

- The commit diff (filtered)
- The list of changed files
- The commit message as additional context
- Instructions to follow `${CLAUDE_PLUGIN_ROOT}/references/review-guidelines.md`
- Output format from `${CLAUDE_PLUGIN_ROOT}/references/finding-format.md`

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
