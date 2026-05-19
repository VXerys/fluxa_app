---
description: "Use when: implementing multi-currency flows, exchange-rate retrieval, conversion persistence, and rate cache fallback logic."
---
# Currency Exchange Rate Contract

## Purpose
Use this SOP to keep cross-currency calculations accurate, auditable, and resilient.

## Primary Agents
- Finance Intelligence Specialist
- Supabase Data and Repository Specialist
- Offline Sync and Local Cache Engineer

## Mandatory Rules
1. Exchange rate integration must use abstract datasource contracts.
2. Persist original_amount, original_currency, and exchange_rate with converted values.
3. Cache rate data with explicit freshness policy and fallback behavior.
4. Conversion logic must be deterministic for statistics and exports.

## Currency Checklist
- Missing rates trigger safe fallback and user-visible messaging.
- Cached rates include timestamp and source metadata.
- Historical transactions preserve historical conversion context.
- Recalculation rules are explicit for reporting.

## Source of Truth
- .github/instructions/fluxa-md/FEATURES-FLUXA.md
- .github/instructions/fluxa-md/DATABASE-FLUXA.md
- .github/instructions/fluxa-md/TECHNICAL_GUIDELINES-FLUXA.md
