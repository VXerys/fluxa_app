---
description: "Use when: implementing premium access checks, free tier quotas, upgrade prompts, and entitlement synchronization across features."
---
# Freemium Gating And Quota Enforcement

## Purpose
Use this SOP to ensure product access control is fair, secure, and consistent across UI and backend.

## Primary Agents
- Premium Theme and Personalization Specialist
- AI Intake Specialist
- Finance Intelligence Specialist
- Export and Report Specialist
- Quality and Regression Sentinel

## Mandatory Rules
1. Access checks must use entitlement state (is_pro and pro_expires_at).
2. Free tier quotas and reset cadence must match product specification exactly.
3. Quota usage increments must be server-authoritative, not client-trusted.
4. Locked UX state must match actual entitlement and available quota.

## Gating Checklist
- Guard checks happen before premium actions execute.
- Quota exhaustion flows show clear upgrade and recovery options.
- Entitlement refresh strategy prevents stale lock state.
- Free and pro outputs remain deterministic in reports and exports.

## Source of Truth
- .github/instructions/fluxa-md/FEATURES-FLUXA.md
- .github/instructions/fluxa-md/DATABASE-FLUXA.md
- .github/instructions/fluxa-md/TECHNICAL_GUIDELINES-FLUXA.md
