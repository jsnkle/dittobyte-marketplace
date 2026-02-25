---
name: create-agent
description: >
  Scaffolds a custom review agent file in .claude/code-quality-agents/ with the
  correct structure, frontmatter, and format instructions. Validates the name,
  checks for collisions, and prints next-steps.
  Trigger phrases: "create agent", "scaffold agent", "new review agent",
  "add custom agent".
---

# Create Custom Agent

Scaffolds a new custom review agent for the code-quality plugin.

## Usage

Requires one argument: the agent name (e.g., `no-console-log`).

## Orchestration Steps

### Step 1 — Validate name

The name must be lowercase-hyphenated: only `a-z`, `0-9`, and `-`, starting with a letter.

If the name doesn't match, print an error and stop:

```
Invalid agent name: "<name>"
Names must be lowercase-hyphenated (e.g., no-console-log, react-hooks).
```

Check for collision with built-in agent config keys (`general`, `types`, `simplify`, `security`, `async-perf`). If it matches, print an error and stop:

```
"<name>" conflicts with a built-in agent. Choose a different name.
```

### Step 2 — Check for existing file

Check if `.claude/code-quality-agents/<name>.md` already exists.

If it does, ask the user whether to overwrite it using AskUserQuestion. If they decline, stop.

### Step 3 — Create the agent file

First, ask the user what the agent should review (its domain/focus area) using AskUserQuestion. Use their answer to fill in the `description`, `Your Domain` heading, and bullet points in the template below.

Ensure the `.claude/code-quality-agents/` directory exists.

Write `.claude/code-quality-agents/<name>.md` with this template:

```markdown
---
name: <name>
description: <from user's answer above>
color: yellow
---

# <Name> Reviewer

You are a code review agent focused on **<domain from description>**.

Read the review guidelines at `${CLAUDE_PLUGIN_ROOT}/references/review-guidelines.md` before starting.

## Your Domain

<1-3 bullet points describing what this agent flags>

## NOT Your Domain

Leave anything outside your domain to the other agents.

## Input

You receive:

1. The code to review (a diff or complete file contents)
2. The list of files under review
3. Additional context if provided (PR metadata, commit message, commit log)

## Instructions

1. Analyze only the changed lines in the diff (or the full file if reviewing file contents)
2. For each finding, determine severity per the guidelines:
   - `critical` — will cause a bug or crash
   - `suggestion` — meaningfully improves correctness or clarity
   - `nit` — minor preference, take-it-or-leave-it
3. Use category tag: `<name>`
4. Be concise — one actionable statement, one sentence justification

## Output

Return a JSON array of findings following the format in `${CLAUDE_PLUGIN_ROOT}/references/finding-format.md`.

Return `[]` if no findings.
```

### Step 4 — Print next-steps

After creating the file, print:

```
Created .claude/code-quality-agents/<name>.md

To use this agent, either:

1. Add it to .claude/code-quality.local.md:
   ---
   agents:
     - general
     - security
     - custom:<name>
   ---

2. Or pass it via the --agents flag:
   /review-code --agents general,custom:<name>
```
