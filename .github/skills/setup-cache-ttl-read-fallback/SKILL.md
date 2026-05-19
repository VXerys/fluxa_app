---
name: setup-cache-ttl-read-fallback
description: "Use when: implementing sqflite read cache with TTL checks, stale invalidation, and cache-to-remote fallback strategy."
---

# Setup Cache TTL Read Fallback

## Purpose
Speed up reads with safe cache usage while preserving correctness under stale data.

## Primary Agent
- Offline Sync and Local Cache Engineer

## Required Inputs
- dataset key
- ttl values
- invalidation events

## Workflow
1. Define cache schema and TTL metadata per dataset.
2. Implement read flow with fresh-cache check before remote call.
3. Apply fallback chain cache fresh -> remote -> controlled stale cache fallback.
4. Add invalidation triggers tied to write, sync, and user-scope changes.

## Validation
- User-scoped data isolation is preserved.
- Stale cache usage is explicit and observable.

## References
- .github/instructions/fluxa-sop/local-cache-ttl-invalidation-read-strategy.instructions.md
- .github/instructions/fluxa-md/DATABASE-FLUXA.md
