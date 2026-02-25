---
name: branch-review
description: >
  Orchestrates automated code review on all changes in the current branch since
  it diverged from a base branch by dispatching specialized agents in parallel
  against the aggregate diff, collecting findings, and printing results to the
  terminal grouped by severity.
  Trigger phrases: "review branch", "review my branch", "branch review".
---

# Branch Review

Runs automated code review on all changes in the current branch since it diverged from a base branch by dispatching specialized agents in parallel, then printing findings to the terminal grouped by severity.

## Usage

- **No arguments**: diffs against `main`
- **With base argument** (e.g., `develop`): diffs against the specified base branch

## Configuration

Read configuration from `.claude/code-quality.local.md` if it exists. Parse YAML frontmatter for these settings (use defaults if the file doesn't exist or a setting is missing):

| Setting | Default | Description |
|---------|---------|-------------|
| `agents` | all five | Subset of agents to run: `general`, `types`, `simplify`, `security`, `async-perf` |
| `exclude_patterns` | `[]` | Glob patterns to exclude from review (e.g., `**/*.test.ts`, `**/generated/**`) |

If the user passed `--agents <list>` in the command arguments, use that comma-separated list instead of the config file's `agents` setting. Valid values: `general`, `types`, `simplify`, `security`, `async-perf`. If an unrecognized agent name is provided, print an error listing valid options and stop.

## Orchestration Steps

### Step 1 — Get the branch diff and commit log

Find the merge base and get the aggregate diff:

```bash
git merge-base <base> HEAD
```

```bash
git diff <merge-base> HEAD
```

Get the commit log for context:

```bash
git log --oneline <merge-base>..HEAD
```

Where `<base>` defaults to `main` if no argument is provided.

Store the diff and commit log. If the diff is empty, print `No changes to review.` and stop.

### Step 2 — Apply exclusions

If `exclude_patterns` is configured, filter the diff to remove matching files before sending to agents.

### Step 3 — Dispatch agents in parallel

Launch all configured agents concurrently using the Task tool. Each agent receives:

- The aggregate diff (filtered)
- The list of changed files
- The commit log as additional context
- Instructions to follow `${CLAUDE_PLUGIN_ROOT}/references/review-guidelines.md`
- Output format from `${CLAUDE_PLUGIN_ROOT}/references/finding-format.md`

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
# Branch Review — <current branch> vs <base>

Commits: <commit count> | Files reviewed: <count> | Findings: <critical_count> critical, <suggestion_count> suggestions, <nit_count> nits

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
