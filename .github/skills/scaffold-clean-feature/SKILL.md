---
name: scaffold-clean-feature
description: "Use when: creating a new feature end-to-end with strict clean architecture (Domain, Data, Presentation), GetX binding, and route wiring in fluxa_app."
---

# Scaffold Clean Feature

## Purpose
Create a production-ready feature skeleton that follows Presentation -> Domain <- Data dependency direction.

## Primary Agent
- Fluxa Workflow Orchestrator

## Required Inputs
- feature_name
- route_path
- core usecases planned for MVP

## Workflow
1. Create feature folder structure for domain, data, and presentation with snake_case filenames.
2. Build Domain contracts first: entities, repository interface, and usecase classes with params.
3. Build Data layer: models, datasources, repository implementation with exception-to-failure mapping.
4. Build Presentation layer: controller, page, and binding with DI order DataSource -> Repository -> UseCase -> Controller.
5. Register route and validate first load path with loading, empty, and error state placeholders.

## Validation
- Domain has no Data or Presentation imports.
- Repository interface returns Future<Either<Failure, T>> for all operations.
- Controller calls usecases only.

## References
- docs/struktur.md
- docs/struktur_feature.md
- .github/instructions/fluxa-sop/clean-architecture-layer-boundaries.instructions.md
