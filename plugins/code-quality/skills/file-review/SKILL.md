---
name: file-review
description: >
  Orchestrates automated code review on entire files (not diffs) by dispatching
  specialized agents in parallel, collecting findings, and printing results
  to the terminal grouped by severity. Useful for auditing existing code.
  Trigger phrases: "review file", "review files", "audit file", "review directory".
---

# File Review

Runs automated code review on complete file contents by dispatching specialized agents in parallel, then printing findings to the terminal grouped by severity.

## Usage

- **Single file** (e.g., `src/auth/service.ts`): reviews the entire file
- **Directory** (e.g., `src/utils/`): reviews all source files in the directory

## Configuration

Read configuration from `.claude/code-quality.local.md` if it exists. Parse YAML frontmatter for these settings (use defaults if the file doesn't exist or a setting is missing):

| Setting | Default | Description |
|---------|---------|-------------|
| `agents` | all five | Subset of agents to run: `general`, `types`, `simplify`, `security`, `async-perf` |
| `exclude_patterns` | `[]` | Glob patterns to exclude from review (e.g., `**/*.test.ts`, `**/generated/**`) |

If the user passed `--agents <list>` in the command arguments, use that comma-separated list instead of the config file's `agents` setting. Valid built-in values: `general`, `types`, `simplify`, `security`, `async-perf`. Custom agents use the `custom:<name>` prefix (e.g., `custom:no-console-log`). See `${CLAUDE_PLUGIN_ROOT}/references/agent-dispatch.md` for resolution rules and validation.

## Orchestration Steps

### Step 1 — Read file content

Determine whether the argument is a file or a directory:

- **Single file**: read its contents with the Read tool.
- **Directory**: glob for source files matching `*.ts`, `*.tsx`, `*.js`, `*.jsx` within the directory. Filter out any files that match `exclude_patterns`. Read each file and concatenate with file-path headers:

```
=== src/utils/foo.ts ===
<file contents>

=== src/utils/bar.ts ===
<file contents>
```

If no files match (or the file/directory doesn't exist), print `No files to review.` and stop.

### Step 2 — Apply exclusions

If `exclude_patterns` is configured, filter out any matching files before sending to agents. For a single file, check if it matches any exclusion pattern — if so, print `File excluded by configuration.` and stop.

### Step 3 — Dispatch agents in parallel

Resolve each configured agent to its file using `${CLAUDE_PLUGIN_ROOT}/references/agent-dispatch.md`.

Launch all resolved agents concurrently using the Task tool. Each agent receives:

- The complete file content(s) with this framing: "Here is the complete source of `<file>`. Review it for issues."
- The list of files being reviewed
- Instructions to follow `${CLAUDE_PLUGIN_ROOT}/references/review-guidelines.md`
- Output format from `${CLAUDE_PLUGIN_ROOT}/references/finding-format.md`

### Step 4 — Collect and deduplicate

1. Parse JSON findings from each agent
2. Deduplicate: if multiple agents flag the same file + line, keep the one with higher severity
3. Group findings by severity: `critical`, `suggestion`, `nit`

### Step 5 — Print findings to terminal

Print findings grouped by severity using this format:

```
# File Review

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
