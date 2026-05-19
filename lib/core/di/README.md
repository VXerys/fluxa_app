core/di — Dependency Injection setup

Purpose:
- Register app-level singletons and services (Storage, Supabase client).
- Provide `InitialBinding` invoked before `runApp`.

Guidelines:
- Feature-level bindings remain in each feature's `presentation/bindings/`.
- Binding order per feature: DataSource -> Repository -> UseCase -> Controller.

Files to add later:
- `initial_binding.dart`
- Helper DI utilities if needed (e.g., lazy registration wrappers).