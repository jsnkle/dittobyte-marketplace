---
name: pr-review
description: >
  Orchestrates automated PR code review by dispatching specialized agents
  in parallel, collecting findings, and posting a GitHub review with inline
  comments and a summary. Trigger phrases: "review PR", "code review",
  "review pull request".
---

# PR Review

Runs automated code review on a GitHub pull request by dispatching specialized agents in parallel, then posting findings as a GitHub review.

## Usage

Requires one argument: the PR number (e.g., `42`).

## Configuration

Read configuration from `.claude/code-quality.local.md` if it exists. Parse YAML frontmatter for these settings (use defaults if the file doesn't exist or a setting is missing):

| Setting | Default | Description |
|---------|---------|-------------|
| `agents` | all five | Subset of agents to run: `general`, `types`, `simplify`, `security`, `async-perf` |
| `exclude_patterns` | `[]` | Glob patterns to exclude from review (e.g., `**/*.test.ts`, `**/generated/**`) |
| `review_event` | `COMMENT` | GitHub review event type: `COMMENT` or `REQUEST_CHANGES` |

If the user passed `--agents <list>` in the command arguments, use that comma-separated list instead of the config file's `agents` setting. Valid built-in values: `general`, `types`, `simplify`, `security`, `async-perf`. Custom agents use the `custom:<name>` prefix (e.g., `custom:no-console-log`). See `${CLAUDE_PLUGIN_ROOT}/references/agent-dispatch.md` for resolution rules and validation.

## Orchestration Steps

### Step 1 — Fetch PR data

```bash
gh pr view <number> --json title,body,baseRefName,headRefName,files,additions,deletions,number
gh pr diff <number>
```

Store the PR metadata and diff for agent dispatch.

### Step 2 — Apply exclusions

If `exclude_patterns` is configured, filter the diff to remove matching files before sending to agents.

### Step 3 — Dispatch agents in parallel

Resolve each configured agent to its file using `${CLAUDE_PLUGIN_ROOT}/references/agent-dispatch.md`.

Launch all resolved agents concurrently using the Task tool. Each agent receives:

- The PR diff (filtered)
- The list of changed files
- PR context (title, description, base branch, head branch)
- Instructions to follow `${CLAUDE_PLUGIN_ROOT}/references/review-guidelines.md`
- Output format from `${CLAUDE_PLUGIN_ROOT}/references/finding-format.md`

### Step 4 — Collect and deduplicate

1. Parse JSON findings from each agent
2. Deduplicate: if multiple agents flag the same file + line, keep the one with higher severity
3. Split findings by severity:
   - `critical` and `suggestion` → inline comments
   - `nit` → summary only

### Step 5 — Post review to GitHub

Refer to `${CLAUDE_PLUGIN_ROOT}/skills/pr-review/references/github-review-api.md` for the API format.

1. Get repo owner/name:
   ```bash
   gh repo view --json owner,name --jq '.owner.login + "/" + .name'
   ```

2. Build the review payload:
   - `event`: from config (`COMMENT` or `REQUEST_CHANGES`)
   - `body`: summary following the format in `${CLAUDE_PLUGIN_ROOT}/skills/pr-review/references/review-format.md`
   - `comments`: inline comments for criticals and suggestions only

3. Post:
   ```bash
   gh api repos/{owner}/{repo}/pulls/{number}/reviews --method POST --input -
   ```

4. If posting fails, fall back to printing findings to the terminal.

### Step 6 — Terminal summary

Print a local summary to the terminal regardless of whether the GitHub post succeeded:

```
Review posted to PR #<number>
<critical_count> critical | <suggestion_count> suggestions | <nit_count> nits
```
