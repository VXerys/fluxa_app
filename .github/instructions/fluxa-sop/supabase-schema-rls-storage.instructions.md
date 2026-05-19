---
description: "Use when: changing Supabase schema, writing RLS policies, handling storage buckets, or implementing user-scoped backend access."
---
# Supabase Schema RLS Storage

## Purpose
Use this SOP to keep cloud data secure, user-scoped, and aligned with product flows.

## Primary Agents
- Supabase Data and Repository Specialist
- Core Foundation and Bootstrap Engineer
- Finance Intelligence Specialist

## Mandatory Rules
1. Supabase is the remote source of truth for persistent synced data.
2. Enforce RLS on user data tables using auth.uid user scoping.
3. Keep storage paths and access policies explicit per user ownership.
4. Use indexes and soft-delete behavior that match query patterns.

## Security Checklist
- Table policy exists before feature release.
- Data access is denied by default across users.
- Bucket access matches privacy requirements.
- Schema changes preserve backward compatibility for active clients.

## Source of Truth
- .github/instructions/fluxa-md/DATABASE-FLUXA.md
- .github/instructions/fluxa-md/TECHNICAL_GUIDELINES-FLUXA.md
