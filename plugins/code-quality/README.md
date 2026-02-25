# code-quality

Automated code review for TypeScript projects. Five specialized agents run in parallel on a diff and return findings grouped by severity. Works on GitHub PRs and local uncommitted changes.

## Agents

| Agent | Domain | Color |
|-------|--------|-------|
| general-reviewer | Logic correctness, naming, readability, error handling, edge cases | blue |
| type-design-analyzer | Type safety, generics, narrowing, exhaustiveness, interface design | cyan |
| code-simplifier | Unnecessary complexity, dead code, redundant logic, simpler alternatives | green |
| security-analyzer | Injection, auth gaps, secrets, path traversal, SSRF, ReDoS | red |
| async-perf-analyzer | Missing await, sequential-when-parallel, N+1 queries, memory leaks | magenta |

## Usage

### Review a pull request

```
/review-pr <number>
```

Posts findings as a GitHub review with inline comments. Requires the GitHub CLI (`gh`) to be authenticated.

### Review local changes

```
/review-code
/review-code <ref>
```

Prints findings to the terminal grouped by severity. No GitHub interaction.

- No arguments: reviews all uncommitted changes (staged + unstaged)
- With a ref (e.g., `main`): reviews diff against that ref

### Review entire files

```
/review-file <path>
```

Reviews complete file contents (not diffs). Useful for auditing existing code.

- Single file: `/review-file src/auth/service.ts`
- Directory: `/review-file src/utils/` — reviews all source files in the directory

### Review a specific commit

```
/review-commit <ref>
```

Reviews the changes introduced by a single commit.

- By SHA: `/review-commit abc1234`
- Relative: `/review-commit HEAD~3`

### Review a branch

```
/review-branch
/review-branch <base>
```

Reviews all changes on the current branch since it diverged from a base.

- No arguments: diffs against `main`
- With a base branch: `/review-branch develop`

## Flags

### `--agents`

Run only specific agents instead of all five. Pass a comma-separated list of agent names.

```
/review-pr 42 --agents security,types
/review-file src/auth/ --agents security
/review-code main --agents security,types
/review-commit abc1234 --agents simplify
/review-branch --agents security,async-perf
```

Valid agent names: `general`, `types`, `simplify`, `security`, `async-perf`.

The `--agents` flag overrides the `agents` setting in `.claude/code-quality.local.md` for that invocation. This replaces the need for standalone `/security-audit` or `/type-check` commands.

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
