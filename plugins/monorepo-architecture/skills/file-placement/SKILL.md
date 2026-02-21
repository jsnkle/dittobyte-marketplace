---
name: file-placement
description: >
  Answers "where does this go?" for any new type, schema, file, or concept
  in the monorepo. Uses the architectural placement decision tree.
  Trigger phrases: "where does this go", "where should I put",
  "what layer does this belong to", "where to place".
---

# File Placement Guide

Given a description of what the user wants to add, determines the correct file path and architectural layer using the rules from `${CLAUDE_PLUGIN_ROOT}/references/architecture.md`.

## Configuration

Read path configuration from `.claude/monorepo-architecture.local.md` if it exists. Parse YAML frontmatter for these settings (use defaults if the file doesn't exist or a setting is missing):

| Setting | Default |
|---------|---------|
| `domain_path` | `packages/domain` |
| `drizzle_schema_path` | `apps/api/src/db/schema` |
| `api_modules_path` | `apps/api/src/modules` |
| `web_features_path` | `apps/web/src/features` |

## Decision Tree

Work through these questions in order. Stop at the first "yes":

### 1. Does it represent business meaning?

Examples: a User entity, an OrderStatus enum, a PricingRule type.

**Answer:** `{domain_path}/<concept>.ts`

This is a domain model. It must be pure — no imports from Zod, Drizzle, React, Express, or any framework.

### 2. Is it untrusted input or output?

**If it's an API boundary** (request validation, response shaping):

**Answer:** `{api_modules_path}/<feature>/schema.ts` (Zod schema) and `{api_modules_path}/<feature>/dto.ts` (inferred types)

**If it's a UI form** (client-side input validation):

**Answer:** `{web_features_path}/<feature>/schema.ts`

### 3. Does it define a database table or relation?

Examples: a Drizzle `pgTable`, a migration, a DB index definition.

**Answer:** `{drizzle_schema_path}/<table>.ts`

This is persistence infrastructure. Never import this outside the API layer.

### 4. Is it UI-specific representation?

Examples: a view model that flattens nested API data, a component prop type, display-formatted data.

**Answer:** `{web_features_path}/<feature>/types.ts`

These are view models. They stay inside their feature slice.

### 5. Is it only used once?

**Answer:** Keep it local — define it in the file where it's used. Promote to a shared location only when reuse demands it.

## Quick Reference Table

| Concept | Location |
|---------|----------|
| Domain models (pure types) | `{domain_path}/` |
| Drizzle table schemas | `{drizzle_schema_path}/` |
| API Zod schemas | `{api_modules_path}/<feature>/schema.ts` |
| API DTOs | `{api_modules_path}/<feature>/dto.ts` |
| Repositories | `{api_modules_path}/<feature>/repository.ts` |
| Services | `{api_modules_path}/<feature>/service.ts` |
| Controllers | `{api_modules_path}/<feature>/controller.ts` |
| Frontend Zod schemas | `{web_features_path}/<feature>/schema.ts` |
| View models | `{web_features_path}/<feature>/types.ts` |
| Frontend API calls | `{web_features_path}/<feature>/api.ts` |
| UI components | `{web_features_path}/<feature>/components/` |

## Output

Respond with:
1. The recommended file path
2. Which layer it belongs to and why
3. Any boundary rules to keep in mind (e.g., "this file must not import from Zod")
