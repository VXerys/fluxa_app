---
name: add-freemium-lock-state-ui
description: "Use when: adding free versus pro lock-state, quota guards, and upgrade prompts to widgets and feature actions."
---

# Add Freemium Lock State UI

## Purpose
Keep premium gating behavior consistent between controller logic and rendered UI state.

## Primary Agent
- Premium Theme and Personalization Specialist

## Required Inputs
- targeted feature action
- entitlement fields
- quota rules

## Workflow
1. Add entitlement and quota checks in controller before premium action execution.
2. Return guarded state for locked, available, and exhausted quota conditions.
3. Render lock-state UI with clear upgrade prompt and disabled action behavior.
4. Update quota only after successful server-authoritative operation and refresh entitlement.

## Validation
- Lock-state matches real entitlement and quota.
- Free and pro behavior remains deterministic.

## References
- .github/instructions/fluxa-md/FEATURES-FLUXA.md
- .github/instructions/fluxa-sop/freemium-gating-and-quota-enforcement.instructions.md
- .github/instructions/fluxa-sop/flutter-ui-slicing-responsive-freemium.instructions.md
