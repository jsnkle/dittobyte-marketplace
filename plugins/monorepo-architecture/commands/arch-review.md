---
name: arch-review
description: Run a full architecture audit of the codebase
allowed-tools:
  - Read
  - Glob
  - Grep
---

Run the architecture-reviewer agent to perform a comprehensive audit of the codebase.

Check all architectural boundaries: domain purity, persistence containment, Zod schema placement, horizontal leak detection, controller isolation, and import direction.

Output a detailed report of any violations found.
