---
description: "Use when: implementing or reviewing MVP feature behavior against product acceptance criteria across free and pro tiers."
---
# MVP Feature Acceptance Matrix

## Purpose
Use this SOP to prevent drift between technical implementation and agreed product behavior.

## Primary Agents
- Fluxa Workflow Orchestrator
- AI Intake Specialist
- Premium Theme and Personalization Specialist
- Finance Intelligence Specialist
- Export and Report Specialist
- Quality and Regression Sentinel

## Mandatory Rules
1. Every feature must define acceptance criteria for free and pro behavior.
2. Edge cases are mandatory: offline mode, quota exhausted, empty data, parser confidence low.
3. Feature done criteria include architecture compliance and user-visible behavior checks.
4. Any scope deviation must be explicitly documented before merge.

## Acceptance Checklist
- Receipt Scanner flow includes quota, OCR parse, editable prefill.
- Voice Quick Record flow includes permission, parse contract, confirmation.
- Statistics, recurring, currency, and export outputs match documented rules.
- Premium themes/icons/menu ordering behavior matches entitlement.

## Source of Truth
- .github/instructions/fluxa-md/FEATURES-FLUXA.md
- .github/instructions/fluxa-md/DATABASE-FLUXA.md
- .github/instructions/fluxa-md/README-FLUXA.md
