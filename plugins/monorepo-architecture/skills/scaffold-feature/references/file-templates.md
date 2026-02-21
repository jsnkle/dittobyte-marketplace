# Scaffold Feature — File Templates

Use these templates when scaffolding a new feature. Replace `<name>` with the lowercase feature name and `<Name>` with PascalCase.

---

## 1. Domain Model — `{domain_path}/<name>.ts`

```typescript
/**
 * <Name> domain model.
 *
 * This is the canonical business representation.
 * Keep this file free of framework imports (no Zod, Drizzle, React, Express).
 */

export interface <Name> {
  id: string;
}
```

## 2. API Zod Schema — `{api_modules_path}/<name>/schema.ts`

```typescript
import { z } from "zod";

export const create<Name>Schema = z.object({
  // Define request validation here
});

export const <name>ResponseSchema = z.object({
  id: z.string(),
});
```

## 3. API DTO — `{api_modules_path}/<name>/dto.ts`

```typescript
import { z } from "zod";
import { create<Name>Schema, <name>ResponseSchema } from "./schema";

export type Create<Name>Dto = z.infer<typeof create<Name>Schema>;
export type <Name>ResponseDto = z.infer<typeof <name>ResponseSchema>;
```

## 4. Repository — `{api_modules_path}/<name>/repository.ts`

```typescript
/**
 * <Name> repository — data access layer.
 *
 * All Drizzle queries for <name> belong here.
 * Returns domain models, not raw DB rows.
 */
```

## 5. Service — `{api_modules_path}/<name>/service.ts`

```typescript
/**
 * <Name> service — domain logic coordination.
 *
 * Orchestrates between repository and domain rules.
 * Accepts and returns domain models or DTOs, never raw DB rows.
 */
```

## 6. Controller — `{api_modules_path}/<name>/controller.ts`

```typescript
/**
 * <Name> controller — HTTP adapter.
 *
 * Validates input via Zod schemas, delegates to the service,
 * and returns response DTOs. Never returns raw DB rows.
 */
```

## 7. Frontend API — `{web_features_path}/<name>/api.ts`

```typescript
/**
 * <Name> API client.
 *
 * Handles fetch calls to the <name> API endpoints.
 * Transforms response DTOs into view models.
 */
```

## 8. Frontend View Models — `{web_features_path}/<name>/types.ts`

```typescript
/**
 * <Name> view models — UI-specific types.
 *
 * These represent the shapes consumed by React components.
 * They do not leak outside this feature slice.
 */
```

## 9. Frontend Zod Schema — `{web_features_path}/<name>/schema.ts`

```typescript
import { z } from "zod";

/**
 * <Name> UI form schemas.
 *
 * Validate user input on the client side.
 * These are independent from the API schemas.
 */
```

## 10. Components Directory — `{web_features_path}/<name>/components/.gitkeep`

Create an empty `.gitkeep` file so the directory is tracked by git.
