---
name: enforce-layer-boundary-audit
description: "Use when: auditing clean architecture boundaries, import direction, and cross-layer violations before or after major changes."
---

# Enforce Layer Boundary Audit

## Purpose
Prevent architecture drift and enforce stable dependency direction.

## Primary Agent
- Architecture Governor

## Required Inputs
- changed files scope
- target feature modules

## Workflow
1. Scan changed files for forbidden imports and dependency direction violations.
2. Flag Domain files that import Data, Presentation, Flutter, or framework-specific code.
3. Verify controllers call usecases only and pages avoid direct data-layer access.
4. Produce remediation actions grouped by severity and layer.

## Validation
- Direction remains Presentation -> Domain <- Data.
- Composition root rules are respected.

## References
- docs/struktur.md
- .github/instructions/fluxa-sop/clean-architecture-layer-boundaries.instructions.md
