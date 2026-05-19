core/storage — Local key-value wrapper

Purpose:
- Wrapping `GetStorage` for read/write/clear and helper methods.

Files to add later:
- `storage_service.dart` with `init()`, `read<T>`, `write`, `clear`.

Notes:
- Use this service for flags like `has_seen_onboarding` and small config data.