# GitHub Review API Reference

Reference for posting PR reviews via the GitHub CLI. Used by the pr-review skill orchestrator.

## Fetching PR Data

```bash
# Get PR metadata
gh pr view <number> --json title,body,baseRefName,headRefName,files,additions,deletions,number

# Get the full diff
gh pr diff <number>
```

## Posting a Review

Use `gh api` to post a review with inline comments:

```bash
gh api repos/{owner}/{repo}/pulls/{number}/reviews --method POST --input -
```

### Payload Structure

```json
{
  "event": "COMMENT",
  "body": "## Code Review Summary\n\n...",
  "comments": [
    {
      "path": "src/auth/service.ts",
      "line": 42,
      "side": "RIGHT",
      "body": "**[critical | security]** User input interpolated into SQL query.\n\nWhy: Allows SQL injection — use parameterized queries instead."
    }
  ]
}
```

### Fields

| Field | Description |
|-------|-------------|
| `event` | `COMMENT` (default) or `REQUEST_CHANGES` — configurable via `.claude/code-quality.local.md` |
| `body` | The overall review summary in markdown |
| `comments` | Array of inline comments to post on specific lines |
| `comments[].path` | File path relative to repo root |
| `comments[].line` | Line number in the new version of the file |
| `comments[].side` | Always `"RIGHT"` (we comment on the new code, not the old) |
| `comments[].body` | The formatted comment text |

### Getting Owner and Repo

Extract from the current git remote:

```bash
gh repo view --json owner,name --jq '.owner.login + "/" + .name'
```

### Review Event Types

| Event | Effect |
|-------|--------|
| `COMMENT` | Posts review without blocking merge. Default — informational only. |
| `REQUEST_CHANGES` | Posts review and blocks merge until resolved. Use when configured. |

## Comment Limits

- GitHub allows a maximum of approximately 50-60 inline comments per review
- If findings exceed this limit, post the most severe ones as inline comments and list the rest in the summary body
- Critical findings always get inline comments over suggestions

## Error Handling

- If `gh` is not authenticated, instruct the user to run `gh auth login`
- If the PR number is invalid, report the error and stop
- If posting fails, output the findings to the terminal as a fallback
