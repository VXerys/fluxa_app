# fluxa_app Workspace Instructions

Use these rules for all coding tasks in this workspace.

## Source of Truth
- docs/struktur.md
- docs/struktur_core.md
- docs/struktur_feature.md
- .github/instructions/fluxa-md/README-FLUXA.md
- .github/instructions/fluxa-md/FEATURES-FLUXA.md
- .github/instructions/fluxa-md/DATABASE-FLUXA.md
- .github/instructions/fluxa-md/TECHNICAL_GUIDELINES-FLUXA.md

## Architecture Rules
- Follow dependency direction: Presentation -> Domain <- Data.
- Domain must stay pure and framework-independent.
- Do not import Data or Presentation into Domain.
- Keep feature-first folder structure and snake_case file naming.

## Layer Contracts
- Entities: properties and constructors only. No fromJson/toJson.
- Models: must extend entities and include fromJson, toJson, and toEntity.
- Repositories: return Future<Either<Failure, T>> and map exceptions to failures.
- Controllers: use constructor-injected usecases. Do not call datasource/repository directly.

## GetX and DI Rules
- Feature binding registration order: DataSource -> Repository -> UseCase -> Controller.
- Use private Rx state plus public getters.
- Keep Obx scope minimal to avoid unnecessary rebuilds.
- Keep global dependencies only in InitialBinding when truly app-wide.

## Data and Sync Rules
- Supabase is source of truth for remote data.
- sqflite is for offline queue and read cache.
- Preserve queue status transitions and retry semantics.
- Respect cache TTL/retention and user-scoped data isolation.

## Freemium and Feature Gating
- Enforce free/pro access checks before premium actions.
- Keep quota behavior aligned with documented product rules.
- Maintain consistent UI lock state with actual entitlement state.

## Implementation Style
- Prefer minimal, safe diffs and preserve existing behavior unless requested.
- Add tests or at least identify testing impact for risky changes.
- Surface assumptions and residual risks clearly when handing back results.

## Skill Invocation Defaults
- For new feature bootstrap work, prefer `scaffold-clean-feature` as the primary workflow skill.
- For data mapping and repository wiring, prefer `generate-data-model-repository-mapping`.
- For GetX presentation wiring, prefer `setup-getx-controller-binding-routing`.
- For offline-first sync behavior, prefer `build-offline-sync-queue` and `setup-cache-ttl-read-fallback`.
- For premium/free lock behavior, prefer `add-freemium-lock-state-ui`.
- For cross-layer refactor safety, run `enforce-layer-boundary-audit` before implementation and `feature-quality-gate` before finalizing.
