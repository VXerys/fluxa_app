core — Kode yang bisa dipakai ulang di seluruh app

Tanggung jawab:
- Konstanta desain + app settings
- Singletons dan initial bindings
- Error types (exceptions/failures)
- Network clients (Supabase)
- Global routes dan storage wrappers
- Base UseCase, util helpers, shared widgets

Konvensi singkat:
- Entities / Models / Repositories feature-specific berada di `lib/features/<feature>/...`.
- Core hanya berisi helper, base class, dan shared UI.

File penting (harus dibuat):
- `core/constants/app_constants.dart`
- `core/constants/default_categories.dart`
- `core/di/initial_binding.dart`
- `core/errors/exceptions.dart`
- `core/errors/failures.dart`
- `core/network/supabase_client.dart`
- `core/routes/app_routes.dart` & `core/routes/app_pages.dart`
- `core/storage/storage_service.dart`
- `core/usecases/usecase.dart`
- `core/utils/logger.dart`

Catatan: ikuti dokumen `docs/TECHNICAL_GUIDELINES.md` jika ada aturan tambahan.