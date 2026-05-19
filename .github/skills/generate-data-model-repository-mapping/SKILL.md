---
name: generate-data-model-repository-mapping
description: "Use when: generating data models with fromJson and toJson, wiring toEntity conversion, and implementing repository exception-to-failure mapping."
---

# Generate Data Model Repository Mapping

## Purpose
Standardize JSON parsing and repository behavior for remote and local data flows.

## Primary Agent
- Supabase Data and Repository Specialist

## Required Inputs
- entity contract
- remote schema or payload sample
- local schema if applicable

## Workflow
1. Create model classes extending entities with fromJson, toJson, and toEntity.
2. Implement datasource methods with typed exceptions only.
3. Implement repository methods that catch exceptions and return Either<Failure, T>.
4. Verify conversion boundaries so model-to-entity mapping stays inside repository.

## Validation
- Datasource never returns Either.
- Repository never leaks raw exceptions.

## References
- docs/struktur_feature.md
- .github/instructions/fluxa-sop/data-model-datasource-repository-implementation.instructions.md
