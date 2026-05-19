---
description: "Use when: creating or refactoring entities, repository contracts, and usecases in the domain layer."
---
# Domain Entities Repositories UseCases

## Purpose
Use this SOP to keep Domain pure, stable, and testable.

## Primary Agents
- Domain Layer Expert
- Architecture Governor
- Quality and Regression Sentinel

## Mandatory Rules
1. Entities contain only properties and constructors; no fromJson or toJson.
2. Repository contracts return Future<Either<Failure, T>> for all operations.
3. UseCase is single-responsibility; params class is explicit and close to the UseCase.
4. Domain must not depend on external SDKs, Flutter UI, GetX, Supabase, or sqflite.

## Contract Checklist
- Entity types are used in Domain APIs.
- Repository methods expose business intent, not datasource details.
- UseCase does not call datasource directly.
- Failure is the only error abstraction leaving Domain.

## Source of Truth
- docs/struktur_feature.md
- docs/struktur_core.md
- .github/instructions/fluxa-md/TECHNICAL_GUIDELINES-FLUXA.md
