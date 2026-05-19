---
description: "Use when: implementing offline write queue, sync retry logic, reconnect processing, or conflict resolution between local and remote states."
---
# Offline First Sync Queue Conflict Resolution

## Purpose
Use this SOP to guarantee no data loss and predictable sync in unstable network conditions.

## Primary Agents
- Offline Sync and Local Cache Engineer
- Supabase Data and Repository Specialist
- Finance Intelligence Specialist
- Quality and Regression Sentinel

## Mandatory Rules
1. Keep offline write queue separate from read cache in sqflite.
2. Define clear queue status transitions with retry metadata.
3. Apply idempotent sync operations to avoid duplicate remote writes.
4. Resolve local-vs-remote conflicts with deterministic rules.

## Sync Checklist
- Queue processing triggers are defined (startup, reconnect, manual).
- Failed queue items are retained with reason and retry schedule.
- Success path marks item synced and cleans queue safely.
- Sync failures never silently drop user actions.

## Source of Truth
- .github/instructions/fluxa-md/DATABASE-FLUXA.md
- .github/instructions/fluxa-md/TECHNICAL_GUIDELINES-FLUXA.md
