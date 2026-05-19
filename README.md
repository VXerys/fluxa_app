# Fluxa App

Fluxa adalah aplikasi pencatatan keuangan pribadi berbasis Flutter dengan pendekatan mobile-first, clean architecture, dan model freemium.

README ini berfokus pada pengenalan produk, ringkasan fitur, dan gambaran teknis singkat aplikasi.

## Tentang Aplikasi

Fluxa dirancang untuk membantu pengguna mencatat pemasukan, pengeluaran, dan arus kas harian dengan cepat, rapi, dan tetap nyaman dipakai walau koneksi internet tidak stabil.

Nilai utama Fluxa:

- Offline-first + cloud sync: transaksi tetap bisa dicatat saat offline, lalu disinkronkan ketika online.
- AI-assisted: input transaksi dipercepat lewat scan struk dan voice record, namun pencatatan manual tetap jadi jalur utama.
- Freemium yang jelas: fitur inti tersedia gratis, fitur lanjutan dibuka lewat paket PRO.

## Ringkasan Fitur

Fitur inti (MVP) yang dirancang di Fluxa:

1. AI Receipt Scanner
- Foto struk, ekstrak teks (OCR), lalu prefill form transaksi.
- Free: kuota scan bulanan terbatas.
- PRO: kuota tidak terbatas.

2. Voice Quick Record
- Ucapan natural pengguna diubah menjadi draft transaksi terstruktur.
- Free: kuota voice bulanan terbatas.
- PRO: kuota tidak terbatas.

3. Transaksi & Dompet
- CRUD transaksi (income/expense/transfer).
- Pengelolaan dompet: cash, bank, e-wallet, dan lainnya.

4. Statistik Periode
- Analitik mingguan, bulanan, tahunan, dan rentang kustom.
- Ringkasan tren pemasukan/pengeluaran dan net flow.

5. Recurring Transaction
- Otomasi transaksi berulang dengan jadwal fleksibel.

6. Budgeting & Savings Goal
- Target anggaran per kategori.
- Target tabungan dengan progres.

7. Smart Notes
- Catatan tambahan pada transaksi agar konteks keuangan lebih jelas.

8. Multi-currency & Exchange Rate
- Dukungan pemilihan mata uang dan konversi berbasis kurs.

9. Export Data
- Ekspor data ke CSV, Excel, dan PDF.

10. Theme, Icon Pack, dan Personalisasi
- Kustomisasi tampilan aplikasi.
- Sebagian tema/ikon dan personalisasi lanjutan termasuk fitur PRO.

## Model Freemium Singkat

- Free tier: fitur dasar keuangan + kuota AI terbatas + opsi personalisasi tertentu.
- PRO tier: AI quota unlimited, akses tema/ikon premium, dan personalisasi lanjutan.

## Teknologi Utama

- Flutter
- GetX (state management, dependency injection, routing)
- Supabase (auth, database, storage)
- sqflite (offline queue dan local read cache)
- get_storage (penyimpanan key-value lokal)
- dartz (Either<Failure, T> untuk error handling)

## Arsitektur Singkat

Fluxa menggunakan Feature-First + Clean Architecture.

Alur dependency:

Presentation -> Domain <- Data

Aturan penting:

- Domain harus tetap murni (tanpa ketergantungan ke Flutter/UI/Data source).
- Repository mengembalikan Future<Either<Failure, T>>.
- Controller memanggil UseCase, bukan datasource/repository secara langsung.

## Struktur Folder (Ringkas)

```text
lib/
	core/
		constants/
		di/
		errors/
		network/
		routes/
		storage/
		usecases/
		utils/
	features/
		auth/
		home/
		transaction/
		statistics/
		wallet/
		receipt_scanner/
		voice_record/
		budget/
		recurring/
		savings_goal/
		currency/
		export/
		smart_notes/
		premium/
		theme/
		profile/
		navigation/
```

## Cara Menjalankan Project

Prasyarat:

- Flutter stable channel terpasang
- Android Studio / VS Code + SDK sesuai target platform

Langkah cepat:

```bash
flutter pub get
flutter run
```

Untuk build release:

```bash
flutter build apk
```

## Konfigurasi Dasar

Sebelum menjalankan integrasi backend secara penuh, sesuaikan konfigurasi Supabase di konstanta aplikasi (mis. URL dan anon key) sesuai environment Anda.

## Dokumentasi Lanjutan

Dokumen sumber utama proyek:

- docs/struktur.md
- docs/struktur_core.md
- docs/struktur_feature.md

Dokumen produk/teknis Fluxa:

- .github/instructions/fluxa-md/README-FLUXA.md
- .github/instructions/fluxa-md/FEATURES-FLUXA.md
- .github/instructions/fluxa-md/DATABASE-FLUXA.md
- .github/instructions/fluxa-md/TECHNICAL_GUIDELINES-FLUXA.md

## Status

Fluxa sedang berada pada tahap pengembangan bertahap menuju MVP production-ready.

Fokus saat ini:

- Penyempurnaan fondasi clean architecture per fitur.
- Stabilisasi offline queue + sinkronisasi Supabase.
- Finalisasi pengalaman freemium vs PRO agar konsisten dari business rule ke UI.
