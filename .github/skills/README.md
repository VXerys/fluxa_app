# fluxa_app Reusable Skills

This folder contains reusable workflow skills for repetitive engineering tasks in fluxa_app.

## Skill List
1. scaffold-clean-feature
2. generate-domain-contracts
3. generate-data-model-repository-mapping
4. setup-getx-controller-binding-routing
5. build-offline-sync-queue
6. add-freemium-lock-state-ui
7. setup-cache-ttl-read-fallback
8. enforce-layer-boundary-audit
9. scaffold-ai-contract-swappable-provider
10. feature-quality-gate

## Recommended Usage Pattern
1. Run `enforce-layer-boundary-audit` at kickoff for non-trivial changes.
2. Use one implementation skill as the primary execution driver.
3. Add supporting skill only when scope clearly requires it.
4. Finish with `feature-quality-gate` before merge.

## Suggested Execution Order
1. enforce-layer-boundary-audit
2. scaffold-clean-feature
3. generate-domain-contracts
4. generate-data-model-repository-mapping
5. setup-getx-controller-binding-routing
6. build-offline-sync-queue
7. setup-cache-ttl-read-fallback
8. scaffold-ai-contract-swappable-provider
9. add-freemium-lock-state-ui
10. feature-quality-gate

## Invocation Templates (Copy and Adapt)

### scaffold-clean-feature
Use prompt:
"Use skill scaffold-clean-feature for feature <feature_name>. Route <route_path>. MVP usecases: <list>. Build full Domain -> Data -> Presentation with GetX binding and route wiring."

### generate-domain-contracts
Use prompt:
"Use skill generate-domain-contracts for <feature_name>. Define entity <entity_name>, repository contracts, and usecases for actions: <actions>. Keep domain pure."

### generate-data-model-repository-mapping
Use prompt:
"Use skill generate-data-model-repository-mapping for <feature_name>. Input schema: <schema_or_payload>. Generate model extends entity, fromJson/toJson/toEntity, datasource exceptions, and repository failure mapping."

### setup-getx-controller-binding-routing
Use prompt:
"Use skill setup-getx-controller-binding-routing for <feature_name>. Controller responsibilities: <list>. Required usecases: <list>. Wire binding order and register route <route_path>."

### build-offline-sync-queue
Use prompt:
"Use skill build-offline-sync-queue for <feature_name>. Queue tables: <tables>. Sync triggers: startup/reconnect/manual. Conflict rule: <rule>. Implement retry lifecycle and status transitions."

### add-freemium-lock-state-ui
Use prompt:
"Use skill add-freemium-lock-state-ui for <feature_name>. Guard premium action <action_name> with entitlement and quota checks, locked UI state, and upgrade prompt."

### setup-cache-ttl-read-fallback
Use prompt:
"Use skill setup-cache-ttl-read-fallback for dataset <dataset_name>. TTL: <duration>. Invalidation events: <events>. Implement cache fresh -> remote -> stale fallback chain."

### enforce-layer-boundary-audit
Use prompt:
"Use skill enforce-layer-boundary-audit on changed scope <files_or_feature>. Report violations by layer and give remediation steps."

### scaffold-ai-contract-swappable-provider
Use prompt:
"Use skill scaffold-ai-contract-swappable-provider for capability <ocr|voice|exchange-rate>. Define abstract contract, first provider implementation, and DI swap points."

### feature-quality-gate
Use prompt:
"Use skill feature-quality-gate for <feature_name>. Validate layer boundaries, exception mapping, free/pro behavior, offline/online behavior, and provide residual risk summary."

## Orchestrator Handoff Map
| Work Type | Primary Skill | Primary Agent |
|---|---|---|
| New feature end-to-end | scaffold-clean-feature | Fluxa Workflow Orchestrator |
| Domain contracts only | generate-domain-contracts | Domain Layer Expert |
| Data model + repository mapping | generate-data-model-repository-mapping | Supabase Data and Repository Specialist |
| GetX controller + binding + route | setup-getx-controller-binding-routing | GetX State and Navigation Specialist |
| Offline write queue and sync | build-offline-sync-queue | Offline Sync and Local Cache Engineer |
| Freemium UI gating | add-freemium-lock-state-ui | Premium Theme and Personalization Specialist |
| Cache TTL strategy | setup-cache-ttl-read-fallback | Offline Sync and Local Cache Engineer |
| Architecture audit | enforce-layer-boundary-audit | Architecture Governor |
| AI provider contract and swap | scaffold-ai-contract-swappable-provider | AI Intake Specialist |
| Pre-merge gate | feature-quality-gate | Quality and Regression Sentinel |

## Source of Truth
- docs/struktur.md
- docs/struktur_core.md
- docs/struktur_feature.md
- .github/instructions/fluxa-md/FEATURES-FLUXA.md
- .github/instructions/fluxa-md/DATABASE-FLUXA.md
- .github/instructions/fluxa-md/TECHNICAL_GUIDELINES-FLUXA.md
- .github/instructions/fluxa-sop/*.instructions.md