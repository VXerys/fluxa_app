---
name: feature-quality-gate
description: "Use when: running pre-merge quality checks for regression risk, exception-to-failure mapping integrity, and release readiness."
---

# Feature Quality Gate

## Purpose
Apply a consistent final gate before merge to reduce regressions.

## Primary Agent
- Quality and Regression Sentinel

## Required Inputs
- changed feature scope
- expected behavior matrix
- critical user flows

## Workflow
1. Verify layer boundaries, binding order, and repository error-mapping consistency.
2. Validate free versus pro behavior and online versus offline scenarios.
3. Confirm UI states for loading, empty, error, and recovery action paths.
4. Summarize defects, risks, and required follow-up tests before merge.

## Validation
- No unresolved critical regression in guarded paths.
- Release notes include residual risk and test impact.

## References
- .github/instructions/fluxa-sop/quality-error-handling-testing-release-gates.instructions.md
- .github/instructions/fluxa-sop/mvp-feature-acceptance-matrix.instructions.md
