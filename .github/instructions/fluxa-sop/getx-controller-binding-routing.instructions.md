---
description: "Use when: creating bindings, controllers, routes, and page wiring using GetX in fluxa_app."
---
# GetX Controller Binding Routing

## Purpose
Use this SOP to keep presentation wiring predictable and low-regression.

## Primary Agents
- GetX State and Navigation Specialist
- Core Foundation and Bootstrap Engineer
- Architecture Governor

## Mandatory Rules
1. Feature binding order is fixed: DataSource -> Repository -> UseCase -> Controller.
2. Controllers use constructor injection; avoid internal service lookup in controller fields.
3. Keep private Rx state with public getters and minimal Obx scope.
4. Pages should use GetView<Controller> and route through GetX routing setup.

## Wiring Checklist
- Every page has the expected binding.
- Controller methods call UseCases and handle Either with fold.
- No direct datasource or repository calls inside pages.
- Global permanent dependencies stay only in InitialBinding when truly app-wide.

## Source of Truth
- docs/struktur.md
- docs/struktur_feature.md
- .github/instructions/fluxa-md/TECHNICAL_GUIDELINES-FLUXA.md
