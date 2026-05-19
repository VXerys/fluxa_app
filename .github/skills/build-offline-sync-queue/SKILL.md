---
name: build-offline-sync-queue
description: "Use when: implementing sqflite offline write queue, sync retry lifecycle, reconnect processing, and deterministic conflict handling with Supabase."
---

# Build Offline Sync Queue

## Purpose
Ensure offline user actions are persisted, retried safely, and never dropped.

## Primary Agent
- Offline Sync and Local Cache Engineer

## Required Inputs
- queue table names
- sync trigger policy
- conflict resolution rule

## Workflow
1. Define local queue schema with status, retry_count, last_error, and timestamps.
2. Route offline write actions into queue with pending state and idempotency metadata.
3. Implement sync worker for startup, reconnect, and manual retry triggers.
4. Apply deterministic conflict resolution and update status pending -> syncing -> synced or failed.
5. Persist retry schedule and failure reason without dropping queued actions.

## Validation
- Queue and read cache are separated.
- Failed items remain recoverable.

## References
- .github/instructions/fluxa-md/DATABASE-FLUXA.md
- .github/instructions/fluxa-sop/offline-first-sync-queue-conflict-resolution.instructions.md
