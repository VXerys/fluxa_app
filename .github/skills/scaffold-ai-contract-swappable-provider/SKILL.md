---
name: scaffold-ai-contract-swappable-provider
description: "Use when: creating abstract datasource contracts and swappable implementations for OCR, voice intent parsing, or exchange rate providers."
---

# Scaffold AI Contract Swappable Provider

## Purpose
Enable provider swaps without breaking repository or usecase contracts.

## Primary Agent
- AI Intake Specialist

## Required Inputs
- capability type (ocr, voice, exchange-rate)
- output schema contract
- initial provider choice

## Workflow
1. Define abstract datasource contract methods and stable output schema.
2. Implement first provider class that conforms to the contract and throws typed exceptions.
3. Wire repository to depend only on abstract contract.
4. Register implementation in binding to allow provider replacement with one DI change.

## Validation
- Upstream usecases and controllers are unchanged when provider is swapped.
- Output parsing contract remains stable.

## References
- .github/instructions/fluxa-sop/ai-ocr-voice-interface-contract.instructions.md
- .github/instructions/fluxa-sop/currency-exchange-rate-contract.instructions.md
