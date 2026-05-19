---
description: "Use when: enforcing clean architecture boundaries, planning cross-layer changes, or reviewing import direction in fluxa_app."
---
# Clean Architecture Layer Boundaries

## Purpose
Use this SOP to keep dependency direction and layer boundaries consistent in every feature.

## Primary Agents
- Architecture Governor
- Domain Layer Expert
- Supabase Data and Repository Specialist
- GetX State and Navigation Specialist
- Offline Sync and Local Cache Engineer

## Mandatory Rules
1. Dependency direction is fixed: Presentation -> Domain <- Data.
2. Domain must stay framework independent and must not import Data or Presentation.
3. Core layer must not import Features, except InitialBinding as app-wide composition root.
4. Feature-first structure and snake_case filenames are mandatory.

## Layer Safety Checklist
- Verify no forbidden imports in Domain files.
- Verify controllers call UseCases, not repositories or datasources.
- Verify repository contracts are in Domain and implementations are in Data.
- Verify changes do not introduce cross-feature tight coupling.

## Source of Truth
- docs/struktur.md
- docs/struktur_core.md
- docs/struktur_feature.md
- .github/instructions/fluxa-md/TECHNICAL_GUIDELINES-FLUXA.md
