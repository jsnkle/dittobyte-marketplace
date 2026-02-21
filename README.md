# DittoByte Marketplace

A Claude Code plugin marketplace with curated plugins for TypeScript development.

## Installation

Add the marketplace, then install the plugins you want:

```bash
/plugin marketplace add jsnkle/dittobyte-marketplace
/plugin install monorepo-architecture@dittobyte-marketplace
```

## Available Plugins

### monorepo-architecture

Enforces clean architecture boundaries in TypeScript monorepos using vertical-slice feature structure.

- **Real-time enforcement** — Hooks block writes that violate architectural boundaries before they happen
- **Scaffolding** — Generate the full vertical-slice file structure for a new feature in one command
- **Placement guidance** — Ask "where does this go?" and get the correct file path and layer
- **Auditing** — Run a comprehensive architecture review that checks 6 categories of violations

**Commands:**

| Command | Description |
|---------|-------------|
| `/arch-review` | Run a full architecture audit (read-only) |
| `/scaffold <name>` | Scaffold a new vertical-slice feature across all layers |
| `/where <description>` | Get placement guidance for where a file or concept belongs |

**Hooks:**

A `PreToolUse` hook runs on every `Write` and `Edit` to enforce:
1. Domain purity — no framework/infrastructure imports in domain files
2. Persistence containment — Drizzle table definitions stay in the schema directory
3. Import direction — frontend can't import from API; domain can't import from apps
4. Controller isolation — controllers go through the service layer

**Configuration:**

Create `.claude/monorepo-architecture.local.md` in your project to override default paths:

```yaml
---
domain_path: packages/domain
drizzle_schema_path: apps/api/src/db/schema
api_modules_path: apps/api/src/modules
web_features_path: apps/web/src/features
---
```

For more details, see the [plugin README](./plugins/monorepo-architecture/README.md).

## Marketplace Structure

```
.claude-plugin/
  marketplace.json                Marketplace catalog
plugins/
  monorepo-architecture/          monorepo-architecture plugin
    .claude-plugin/plugin.json
    commands/
    agents/
    skills/
    hooks/
    references/
```

## License

MIT
