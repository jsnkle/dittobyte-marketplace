---
name: scaffold
description: Scaffold a new vertical-slice feature across all layers
argument-hint: <feature-name>
---

Use the scaffold-feature skill to create the full vertical-slice file structure for the feature named `$ARGUMENTS`.

The feature name should be a lowercase, singular noun (e.g., `order`, `product`, `payment`).

Create files across all three architectural layers: domain model, API module (schema, DTO, repository, service, controller), and frontend feature (API client, view models, schema, components directory).
