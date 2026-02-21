#!/usr/bin/env bash
# validate-architecture.sh
#
# PreToolUse hook for Write|Edit tools.
# Reads JSON from stdin and checks for architectural violations.
# Exit 0 = allow, Exit 2 = block with message on stderr.

set -uo pipefail

# --- Read hook input from stdin ---
INPUT=$(cat)

TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty') || true
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty') || true

# Determine content to check based on tool
if [ "$TOOL_NAME" = "Write" ]; then
  CONTENT=$(echo "$INPUT" | jq -r '.tool_input.content // empty') || true
elif [ "$TOOL_NAME" = "Edit" ]; then
  CONTENT=$(echo "$INPUT" | jq -r '.tool_input.new_string // empty') || true
else
  exit 0
fi

# If no file path or content, nothing to check
if [ -z "$FILE_PATH" ] || [ -z "$CONTENT" ]; then
  exit 0
fi

# --- Load configuration ---
# Defaults
DOMAIN_PATH="packages/domain"
DRIZZLE_SCHEMA_PATH="apps/api/src/db/schema"
API_MODULES_PATH="apps/api/src/modules"
WEB_FEATURES_PATH="apps/web/src/features"

# Try reading from .claude/monorepo-architecture.local.md
CONFIG_FILE=".claude/monorepo-architecture.local.md"
if [ -f "$CONFIG_FILE" ]; then
  # Extract YAML frontmatter values
  val=$(sed -n 's/^domain_path: *//p' "$CONFIG_FILE" | head -1) || true
  [ -n "$val" ] && DOMAIN_PATH="$val"
  val=$(sed -n 's/^drizzle_schema_path: *//p' "$CONFIG_FILE" | head -1) || true
  [ -n "$val" ] && DRIZZLE_SCHEMA_PATH="$val"
  val=$(sed -n 's/^api_modules_path: *//p' "$CONFIG_FILE" | head -1) || true
  [ -n "$val" ] && API_MODULES_PATH="$val"
  val=$(sed -n 's/^web_features_path: *//p' "$CONFIG_FILE" | head -1) || true
  [ -n "$val" ] && WEB_FEATURES_PATH="$val"
fi

# Helper: check if file path matches a given directory prefix
path_matches() {
  echo "$FILE_PATH" | grep -qE "(^|/)$1/" 2>/dev/null
}

# Helper: check if content matches a pattern
content_matches() {
  echo "$CONTENT" | grep -qE "$1" 2>/dev/null
}

# Helper: extract first match from content
first_match() {
  echo "$CONTENT" | grep -oE "$1" 2>/dev/null | head -1
}

# --- Check 1: Domain Purity ---
# Files in domain_path must not import forbidden libraries
if path_matches "$DOMAIN_PATH"; then
  FORBIDDEN_IMPORTS='from ["'"'"'](zod|drizzle-orm|drizzle-kit|react|react-dom|next|express|hono|fastify|@tanstack|pg|mysql|mysql2|better-sqlite|better-sqlite3)["'"'"'/]'
  if content_matches "$FORBIDDEN_IMPORTS"; then
    MATCHED=$(first_match "$FORBIDDEN_IMPORTS")
    echo "BLOCKED: Domain purity violation in ${FILE_PATH}. Domain files must not import framework/infrastructure libraries. Found: ${MATCHED}" >&2
    exit 2
  fi

  FORBIDDEN_REQUIRE='require\(["'"'"'](zod|drizzle-orm|drizzle-kit|react|react-dom|next|express|hono|fastify|@tanstack|pg|mysql|mysql2|better-sqlite|better-sqlite3)["'"'"']'
  if content_matches "$FORBIDDEN_REQUIRE"; then
    MATCHED=$(first_match "$FORBIDDEN_REQUIRE")
    echo "BLOCKED: Domain purity violation in ${FILE_PATH}. Domain files must not require framework/infrastructure libraries. Found: ${MATCHED}" >&2
    exit 2
  fi
fi

# --- Check 2: Persistence Containment ---
# pgTable/mysqlTable/sqliteTable calls must only appear in drizzle_schema_path
TABLE_PATTERN='(pgTable|mysqlTable|sqliteTable)\('
if content_matches "$TABLE_PATTERN"; then
  if ! path_matches "$DRIZZLE_SCHEMA_PATH"; then
    MATCHED=$(first_match "$TABLE_PATTERN")
    echo "BLOCKED: Persistence containment violation in ${FILE_PATH}. Drizzle table definitions (${MATCHED}) must only appear in ${DRIZZLE_SCHEMA_PATH}/. Move this table definition to the correct location." >&2
    exit 2
  fi
fi

# --- Check 3: Import Direction — Web must not import from API ---
if path_matches "$WEB_FEATURES_PATH"; then
  API_IMPORT='from ["'"'"'](.*apps/api|@api/)'
  if content_matches "$API_IMPORT"; then
    echo "BLOCKED: Import direction violation in ${FILE_PATH}. Frontend files must not import from the API layer. Use API DTOs via fetch calls instead." >&2
    exit 2
  fi
fi

# --- Check 4: Import Direction — Domain must not import from apps ---
if path_matches "$DOMAIN_PATH"; then
  APP_IMPORT='from ["'"'"'](.*apps/|@api/|@web/)'
  if content_matches "$APP_IMPORT"; then
    echo "BLOCKED: Import direction violation in ${FILE_PATH}. Domain files must not import from application layers. The domain must remain pure and independent." >&2
    exit 2
  fi
fi

# --- Check 5: Controller Isolation ---
FILENAME=$(basename "$FILE_PATH")
if [ "$FILENAME" = "controller.ts" ] || [ "$FILENAME" = "controller.js" ]; then
  CONTROLLER_FORBIDDEN='from ["'"'"'](.*db/schema|.*repository)'
  if content_matches "$CONTROLLER_FORBIDDEN"; then
    MATCHED=$(first_match "$CONTROLLER_FORBIDDEN")
    echo "BLOCKED: Controller isolation violation in ${FILE_PATH}. Controllers must not import directly from db/schema or repository. Use the service layer instead. Found: ${MATCHED}" >&2
    exit 2
  fi
fi

# All checks passed
exit 0
