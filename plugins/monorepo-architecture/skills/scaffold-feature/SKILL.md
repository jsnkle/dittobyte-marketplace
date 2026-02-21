---
name: scaffold-feature
description: >
  Scaffolds the full vertical-slice file structure for a new feature across
  domain, API, and frontend layers. Trigger phrases: "scaffold a feature",
  "create feature files", "set up a new feature", "scaffold <name>".
---

# Scaffold Feature

Creates the full vertical-slice file structure for a new feature across all three architectural layers (domain, API, frontend), following the conventions defined in `${CLAUDE_PLUGIN_ROOT}/references/architecture.md`.

## Usage

Requires one argument: the feature name. It should be a lowercase, singular noun (e.g., `order`, `product`, `payment`).

## Configuration

Read path configuration from `.claude/monorepo-architecture.local.md` if it exists. Parse YAML frontmatter for these settings (use defaults if the file doesn't exist or a setting is missing):

| Setting | Default |
|---------|---------|
| `domain_path` | `packages/domain` |
| `drizzle_schema_path` | `apps/api/src/db/schema` |
| `api_modules_path` | `apps/api/src/modules` |
| `web_features_path` | `apps/web/src/features` |

## Instructions

When invoked with a feature name, create the following files. Use PascalCase for type/interface names derived from the feature name (e.g., `order` -> `Order`).

Refer to `${CLAUDE_PLUGIN_ROOT}/skills/scaffold-feature/references/file-templates.md` for the exact file templates to use for each file.

### Files to Create

1. **Domain Model** — `{domain_path}/<name>.ts`
2. **API Zod Schema** — `{api_modules_path}/<name>/schema.ts`
3. **API DTO** — `{api_modules_path}/<name>/dto.ts`
4. **Repository** — `{api_modules_path}/<name>/repository.ts`
5. **Service** — `{api_modules_path}/<name>/service.ts`
6. **Controller** — `{api_modules_path}/<name>/controller.ts`
7. **Frontend API** — `{web_features_path}/<name>/api.ts`
8. **Frontend View Models** — `{web_features_path}/<name>/types.ts`
9. **Frontend Zod Schema** — `{web_features_path}/<name>/schema.ts`
10. **Components Directory** — `{web_features_path}/<name>/components/.gitkeep`

## After Scaffolding

Once all files are created, output a summary listing every file path created and remind the user:

- Domain types in `{domain_path}/` must stay framework-free
- DTOs in `dto.ts` should always be derived from Zod schemas via `z.infer`
- Each layer transforms data at its boundaries — don't pass raw DB rows to controllers
- Frontend schemas are independent from API schemas (intentional duplication)
