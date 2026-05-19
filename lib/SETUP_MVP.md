Setup cepat untuk mulai coding (Basic MVP 2 hari)

1) Install & cek environment
```
flutter channel stable
flutter upgrade
flutter doctor
```

2) Install dependency
```
flutter pub get
```

3) Konfigurasi awal yang wajib dibuat sebelum coding fitur:
- `lib/core/constants/app_constants.dart` — isi `supabaseUrl`, `supabaseAnonKey`, `appName`, quota default.
- `lib/core/di/initial_binding.dart` — register App-level singleton (StorageService, Supabase client).
- `lib/core/routes/app_routes.dart` & `lib/core/routes/app_pages.dart` — definisikan route string dan GetPage mapping.

4) Data awal untuk MVP:
- Buat file default categories: `lib/core/constants/default_categories.dart`.

5) Jalankan app
```
flutter run
```

Jika butuh, saya bisa lanjut scaffold file dart (entities/usecases/controllers) untuk `transaction` dan `home`.