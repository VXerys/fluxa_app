---
description: "Use when: slicing Flutter UI pages/widgets, enforcing responsive layout, and aligning premium lock-state in the presentation layer."
---
# Flutter UI Slicing Responsive Freemium

## Purpose
Use this SOP to keep UI composition maintainable and product behavior consistent across free and pro users.

## Primary Agents
- GetX State and Navigation Specialist
- Premium Theme and Personalization Specialist
- Export and Report Specialist

## Mandatory Rules
1. Keep business logic in controller/usecase; widgets stay focused on rendering.
2. Use design tokens from core constants for colors, spacing, and text styles.
3. Build responsive layouts with clear breakpoints and safe constraints for small screens.
4. Premium lock-state in UI must match real entitlement and quota status.

## UX Checklist
- Empty/loading/error states are explicit and reusable.
- Interaction targets remain usable on compact screens.
- Locked premium actions show clear upgrade path.
- UI behavior remains deterministic when state changes.

## Source of Truth
- docs/struktur.md
- docs/struktur_core.md
- .github/instructions/fluxa-md/FEATURES-FLUXA.md
