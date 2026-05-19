---
description: "Use when: integrating receipt OCR, voice transcription intent parsing, or swapping AI provider implementations behind stable contracts."
---
# AI OCR Voice Interface Contract

## Purpose
Use this SOP to keep AI-assisted features modular, swappable, and safe for user correction.

## Primary Agents
- AI Intake Specialist
- Supabase Data and Repository Specialist
- GetX State and Navigation Specialist

## Mandatory Rules
1. OCR and parser integrations must be wrapped by abstract datasource contracts.
2. Keep output schema stable across providers (amount, type, category, wallet, note, currency, confidence).
3. Null or low-confidence fields must route to editable prefill UX.
4. Provider swaps must not break domain contracts or controller behavior.

## Contract Checklist
- Input and output DTO schema is documented and tested.
- Failure modes map to typed failures and clear user fallback.
- Quota and entitlement checks run before expensive AI calls.
- Parsing never bypasses user confirmation before save.

## Source of Truth
- .github/instructions/fluxa-md/FEATURES-FLUXA.md
- .github/instructions/fluxa-md/TECHNICAL_GUIDELINES-FLUXA.md
