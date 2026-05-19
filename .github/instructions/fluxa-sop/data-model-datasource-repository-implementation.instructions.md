---
description: "Use when: implementing models, datasources, and repository implementations for remote or local data flows."
---
# Data Model DataSource Repository Implementation

## Purpose
Use this SOP to keep Data layer robust, reversible, and aligned with Domain contracts.

## Primary Agents
- Supabase Data and Repository Specialist
- Offline Sync and Local Cache Engineer
- Domain Layer Expert

## Mandatory Rules
1. Models must extend Entities and include fromJson, toJson, and toEntity.
2. Datasources throw typed exceptions; they do not return Either.
3. Repository implementations catch exceptions and map them to Failure types.
4. Model-to-Entity conversion must happen at repository boundary.

## Reliability Checklist
- Remote and local datasource responsibilities are separated.
- Exception taxonomy is explicit (Server, Network, Cache, Auth).
- Repository never leaks raw exceptions upward.
- Return types remain Future<Either<Failure, T>>.

## Source of Truth
- docs/struktur_feature.md
- docs/struktur_core.md
- .github/instructions/fluxa-md/TECHNICAL_GUIDELINES-FLUXA.md
