# monorepo-architecture

A Claude Code plugin that enforces clean architecture boundaries in TypeScript monorepos using vertical-slice feature structure.

## What It Does

- **Real-time enforcement** — Hooks block writes that violate architectural boundaries before they happen
- **Scaffolding** — Generate the full vertical-slice file structure for a new feature in one command
- **Placement guidance** — Ask "where does this go?" and get the correct file path and layer
- **Auditing** — Run a comprehensive architecture review that checks 6 categories of violations

## Commands

### `/arch-review`

Run a full architecture audit of the codebase. Checks domain purity, persistence containment, schema placement, horizontal leaks, controller isolation, and import direction. Read-only — no files are modified.

### `/scaffold <feature-name>`

Scaffold a new vertical-slice feature across all layers. Creates 10 files: domain model, API module (schema, DTO, repository, service, controller), and frontend feature (API client, view models, schema, components directory).

```
/scaffold order
/scaffold payment
```

### `/where <description>`

Get placement guidance for where a file or concept belongs. Outputs the recommended path, layer, and boundary rules.

```
/where a Zod schema for validating user registration input
/where a type representing order status
/where a Drizzle table for storing invoices
```

## Real-Time Hooks

The plugin includes a `PreToolUse` hook that runs on every `Write` and `Edit` operation. It performs fast, deterministic checks:

1. **Domain purity** — Domain files can't import from `zod`, `drizzle-orm`, `react`, `express`, `hono`, `fastify`, `@tanstack`, `pg`, `mysql`, `better-sqlite`
2. **Persistence containment** — `pgTable(`, `mysqlTable(`, `sqliteTable(` calls must only appear in the Drizzle schema directory
3. **Import direction** — Frontend can't import from API; domain can't import from apps
4. **Controller isolation** — Controllers can't import directly from `db/schema` or `repository`

When a violation is detected, the write is blocked and the violation message is fed back to Claude so it can self-correct.

## Configuration

Create `.claude/monorepo-architecture.local.md` in your project to override default paths:

```yaml
---
domain_path: packages/domain
drizzle_schema_path: apps/api/src/db/schema
api_modules_path: apps/api/src/modules
web_features_path: apps/web/src/features
---
```

All fields are optional. Defaults follow standard monorepo conventions.

## Architecture Philosophy

This plugin encodes five core principles:

1. **Keep the domain pure** — Business meaning stays free from frameworks, validation, persistence, and transport
2. **Boundaries own validation** — Zod schemas live at trust boundaries, not in domain
3. **Persistence is infrastructure** — Drizzle schemas are storage details, contained to the DB layer
4. **Vertical slices are self-contained** — Feature slices own their internal shapes, no horizontal leaking
5. **Clarity over cleverness** — Place things where their meaning is most obvious

## Plugin Structure

```
.claude-plugin/plugin.json          Plugin manifest
commands/
  arch-review.md                    /arch-review command
  scaffold.md                       /scaffold command
  where.md                          /where command
agents/
  architecture-reviewer.md          Deep audit agent
skills/
  scaffold-feature/
    SKILL.md                        Feature scaffolding skill
    references/file-templates.md    File templates
  file-placement/
    SKILL.md                        Placement decision tree
hooks/
  hooks.json                        Hook configuration
  scripts/validate-architecture.sh  Real-time enforcement
references/
  architecture.md                   Core rules reference
```
