# Architecture Rules Reference

This is the actionable reference for architectural rules. Skills, agents, and hooks use this as their source of truth.

---

## Core Principles

1. **Domain is pure** — No framework, validation, persistence, or transport imports in the domain layer.
2. **Boundaries own validation** — Zod schemas live at trust boundaries (API input/output, UI forms), not in domain.
3. **Persistence is infrastructure** — Drizzle schemas are storage details, contained to the DB layer.
4. **Vertical slices are self-contained** — Feature slices own their internal shapes and don't leak horizontally.
5. **Clarity over cleverness** — Place things where their meaning is most obvious. Promote scope only when reuse demands it.

---

## Placement Decision Tree

When adding a type, schema, or file, follow this decision tree:

1. **Does it represent business meaning?** → `packages/domain/`
2. **Is it untrusted input or output?**
   - API boundary → `apps/api/src/modules/<feature>/schema.ts`
   - UI form → `apps/web/src/features/<feature>/schema.ts`
3. **Does it define a database table or relation?** → `apps/api/src/db/schema/`
4. **Is it UI-specific representation?** → `apps/web/src/features/<feature>/types.ts`
5. **Is it only used once?** → Keep it local (function-scoped or file-scoped)

---

## Quick Reference — File Placement

| Concept | Location |
|---------|----------|
| Domain models (pure types) | `packages/domain/` |
| Drizzle table schemas | `apps/api/src/db/schema/` |
| API Zod schemas | `apps/api/src/modules/<feature>/schema.ts` |
| API DTOs | `apps/api/src/modules/<feature>/dto.ts` |
| Repositories | `apps/api/src/modules/<feature>/repository.ts` |
| Services | `apps/api/src/modules/<feature>/service.ts` |
| Controllers | `apps/api/src/modules/<feature>/controller.ts` |
| Frontend Zod schemas | `apps/web/src/features/<feature>/schema.ts` |
| View models | `apps/web/src/features/<feature>/types.ts` |
| Frontend API calls | `apps/web/src/features/<feature>/api.ts` |
| UI components | `apps/web/src/features/<feature>/components/` |

---

## Data Flow

### Inbound API Request

```
Raw HTTP → API Zod Schema → DTO → Domain Model → Service → Repository → Drizzle → DB
```

### Outbound API Response

```
DB → Drizzle → Domain Model → DTO → API Zod Schema (shaping) → JSON
```

### Frontend Flow

```
User Input → UI Zod Schema → Request DTO → API → Response DTO → View Model → React Components
```

---

## Boundary Rules (Enforced by Hooks)

### Domain Purity

Files in the domain path must **never** import from:
- `zod`
- `drizzle-orm`, `drizzle-kit`
- `react`, `react-dom`, `next`
- `express`, `hono`, `fastify`
- `@tanstack/*`
- Database drivers: `pg`, `mysql`, `mysql2`, `better-sqlite3`, `better-sqlite`

### Persistence Containment

Drizzle table definitions (`pgTable(`, `mysqlTable(`, `sqliteTable(`) must only appear in files under the Drizzle schema path.

### Import Direction

- `packages/domain/` must not import from `apps/`
- `apps/web/` must not import from `apps/api/` or `@api/`
- Feature slices must not import from sibling feature slices

### Controller Isolation

Controller files (`controller.ts`) must not import directly from `db/schema` or `repository`. They go through the service layer.

---

## Configurable Paths

These paths can be overridden via `.claude/monorepo-architecture.local.md` YAML frontmatter:

| Setting | Default |
|---------|---------|
| `domain_path` | `packages/domain` |
| `drizzle_schema_path` | `apps/api/src/db/schema` |
| `api_modules_path` | `apps/api/src/modules` |
| `web_features_path` | `apps/web/src/features` |
