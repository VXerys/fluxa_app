---
description: "Use when: preparing merges/releases, reviewing regression risk, defining test coverage, or validating exception-to-failure handling."
---
# Quality Error Handling Testing Release Gates

## Purpose
Use this SOP as final quality gate for high-risk or cross-layer changes.

## Primary Agents
- Quality and Regression Sentinel
- Fluxa Workflow Orchestrator
- Architecture Governor

## Mandatory Rules
1. Map all datasource exceptions to domain-safe Failure types in repositories.
2. Define minimum tests per layer for changed scope before merge.
3. Run regression checks for offline sync, freemium, AI parse, and currency when touched.
4. Document residual risks explicitly when full test coverage is not possible.

## Gate Checklist
- Failure path UX is tested, not only success path.
- Sync queue behavior is validated with reconnect scenarios.
- Premium lock-state and quota edge cases are verified.
- Release note includes behavior changes and risk notes.

## Source of Truth
- docs/struktur_core.md
- docs/struktur_feature.md
- .github/instructions/fluxa-md/TECHNICAL_GUIDELINES-FLUXA.md
- .github/instructions/fluxa-md/FEATURES-FLUXA.md
