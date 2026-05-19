---
name: generate-domain-contracts
description: "Use when: creating or refactoring domain entities, repository contracts, and usecases without leaking framework or data-layer dependencies."
---

# Generate Domain Contracts

## Purpose
Produce pure Domain definitions as stable contracts before implementation starts.

## Primary Agent
- Domain Layer Expert

## Required Inputs
- entity_name
- business actions
- expected return types

## Workflow
1. Define entity classes with properties and constructors only.
2. Define abstract repository methods returning Future<Either<Failure, T>>.
3. Define usecases with explicit params classes and single-responsibility behavior.
4. Validate import purity and remove any framework or data dependencies.

## Validation
- No fromJson or toJson in entities.
- No GetX, Flutter, or Supabase imports in Domain.

## References
- docs/struktur_feature.md
- .github/instructions/fluxa-sop/domain-entities-repositories-usecases.instructions.md
