---
name: setup-getx-controller-binding-routing
description: "Use when: setting up GetX controller, binding dependency injection order, and route registration for a feature page."
---

# Setup GetX Controller Binding Routing

## Purpose
Create predictable Presentation wiring with constructor injection and controlled reactive state.

## Primary Agent
- GetX State and Navigation Specialist

## Required Inputs
- feature route name
- controller responsibilities
- required usecases

## Workflow
1. Create controller with constructor-injected usecases and private Rx state plus public getters.
2. Add controller methods that call usecases and fold Either for success and failure handling.
3. Build feature binding with strict order DataSource -> Repository -> UseCase -> Controller.
4. Register route and ensure page uses GetView<Controller> with minimal Obx scope.

## Validation
- Page does not call datasource or repository directly.
- Controller does not resolve dependencies internally with ad-hoc lookups.

## References
- docs/struktur.md
- .github/instructions/fluxa-sop/getx-controller-binding-routing.instructions.md
