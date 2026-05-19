Lib — Struktur feature-first untuk Basic MVP (2 hari)

Tujuan:
- Struktur folder feature-first + clean architecture, disederhanakan untuk Basic MVP 2 hari.
- Sediakan kerangka folder dan petunjuk singkat untuk memulai coding cepat.

Isi singkat:
- core/: kode reusable, utils, constants, DI, routes
- features/: setiap fitur terpisah (transaction, home, profile, navigation)
- assets/: icon, theme, fonts
- test/: tempat unit/widget tests

Aturan singkat (penting):
- File dan folder pakai snake_case.
- Domain tetap murni: entities hanya properties + constructor.
- Models harus extend entities dan menyediakan fromJson/toJson/toEntity.
- Repository contract: return `Future<Either<Failure,T>>` (pakai `dartz`).
- Binding order: DataSource -> Repository -> UseCase -> Controller (GetX `Bindings`).

Langkah selanjutnya (TODO):
- Isi `lib/core/constants/app_constants.dart` (supabase, quota, appName).
- Buat `InitialBinding` di `lib/core/di/`.
- Implement `transaction` domain/entity/usecase terlebih dahulu.

Referensi: docs/struktur.md, docs/struktur_core.md, docs/struktur_feature.md
