---
description: "Use when: designing sqflite read cache strategy, TTL rules, invalidation triggers, and fast offline read behavior."
---
# Local Cache TTL Invalidation Read Strategy

## Purpose
Use this SOP to keep local reads fast while preserving consistency with Supabase.

## Primary Agents
- Offline Sync and Local Cache Engineer
- Finance Intelligence Specialist
- Supabase Data and Repository Specialist

## Mandatory Rules
1. Cache tables are for reads only; write operations go to queue pipeline.
2. Define TTL and invalidation rules per cached dataset.
3. Scope cache strictly per user identity to prevent data leakage.
4. Implement explicit fallback order for read flows.

## Cache Checklist
- Stale cache detection is deterministic.
- Invalidation events are tied to sync and mutation events.
- Cache misses return safe defaults, not unstable states.
- Heavy read paths avoid repeated remote calls when valid cache exists.

## Source of Truth
- .github/instructions/fluxa-md/DATABASE-FLUXA.md
- .github/instructions/fluxa-md/FEATURES-FLUXA.md
