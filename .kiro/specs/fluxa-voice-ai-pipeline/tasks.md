# Tasks — Fluxa Voice AI Pipeline

Task list ini dibuat agar bisa langsung dipakai sebagai arahan implementasi bertahap di Kiro. Jalankan berurutan agar tidak boros kredit dan tidak lompat ke backend/training terlalu cepat.

## Phase 0 — Guardrails

- [ ] Baca `docs/struktur.md`, `docs/struktur_feature.md`, dan `.github/instructions/fluxa-md/TECHNICAL_GUIDELINES-FLUXA.md` sebelum generate kode.
- [ ] Jangan ubah arsitektur global project.
- [ ] Jangan implement fine-tuning Whisper.
- [ ] Jangan langsung menyimpan output AI sebagai transaksi final.
- [ ] Jangan hardcode API base URL.

## Phase 1 — Spec Alignment

- [ ] Update technical guideline lama agar `speech_to_text` tidak lagi disebut metode utama.
- [ ] Tambahkan catatan bahwa metode utama skripsi adalah `record audio -> backend Whisper small -> classifier parser -> JSON`.
- [ ] Tetapkan device speech recognition sebagai optional debug/prototype mode saja.

Expected files:

```text
.github/instructions/fluxa-md/TECHNICAL_GUIDELINES-FLUXA.md
```

Acceptance criteria:

- Dokumentasi tidak konflik dengan spec baru.
- Developer/AI agent berikutnya tidak diarahkan memakai `speech_to_text` sebagai primary STT.

## Phase 2 — Add Core Configuration

- [ ] Tambahkan dependency Flutter yang dibutuhkan:
  - [ ] `dio`
  - [ ] `record`
  - [ ] optional `permission_handler`
- [ ] Tambahkan env key:
  - [ ] `FLUXA_AI_API_BASE_URL`
- [ ] Expose base URL via `AppConstants` atau config class existing.
- [ ] Jika belum ada HTTP client global, buat `DioClient` sederhana dengan base URL dan timeout.

Expected files:

```text
pubspec.yaml
.env
lib/core/constants/app_constants.dart
lib/core/network/dio_client.dart
```

Acceptance criteria:

- `flutter pub get` sukses.
- API base URL tidak hardcoded di datasource.
- Timeout upload minimal 30 detik.

## Phase 3 — Create Domain Layer

- [ ] Buat folder `lib/features/voice_transaction/domain/`.
- [ ] Buat entities:
  - [ ] `voice_transcript_entity.dart`
  - [ ] `voice_transaction_entity.dart`
  - [ ] `voice_classification_entity.dart`
  - [ ] `voice_transaction_result_entity.dart`
- [ ] Buat repository contract:
  - [ ] `voice_transaction_repository.dart`
- [ ] Buat usecases:
  - [ ] `start_voice_recording_usecase.dart`
  - [ ] `stop_voice_recording_usecase.dart`
  - [ ] `cancel_voice_recording_usecase.dart`
  - [ ] `parse_voice_transaction_usecase.dart`

Acceptance criteria:

- Domain layer tidak import Flutter/GetX/Dio/Supabase.
- Semua repository method return `Future<Either<Failure, Type>>`.
- Semua usecase mengikuti `UseCase<Type, Params>`.

## Phase 4 — Create Data Models

- [ ] Buat folder `lib/features/voice_transaction/data/models/`.
- [ ] Buat model yang extends entity:
  - [ ] `voice_transcript_model.dart`
  - [ ] `voice_transaction_model.dart`
  - [ ] `voice_classification_model.dart`
  - [ ] `voice_transaction_result_model.dart`
- [ ] Tambahkan `fromJson`, `toJson`, dan `toEntity`.
- [ ] Pastikan parsing defensive terhadap null/missing fields.

Acceptance criteria:

- Model bisa parse success response dari backend contract.
- `amount` diparse sebagai `int?`.
- `currency` fallback ke `IDR`.
- `warnings` fallback ke empty list.

## Phase 5 — Create DataSources

- [ ] Buat abstract audio recorder datasource.
- [ ] Buat implementation memakai package `record`.
- [ ] Buat abstract remote datasource.
- [ ] Buat implementation upload multipart memakai `Dio`.
- [ ] Map backend error menjadi `ServerException`/`NetworkException`/`PermissionException`.

Expected files:

```text
lib/features/voice_transaction/data/datasources/voice_audio_recorder_datasource.dart
lib/features/voice_transaction/data/datasources/voice_audio_recorder_datasource_impl.dart
lib/features/voice_transaction/data/datasources/voice_transaction_remote_datasource.dart
lib/features/voice_transaction/data/datasources/voice_transaction_remote_datasource_impl.dart
```

Acceptance criteria:

- `startRecording()` meminta/mengecek permission microphone.
- `stopRecording()` mengembalikan path file audio.
- `parseVoiceTransaction()` POST ke `/api/v1/voice/parse`.
- Tidak ada direct UI logic di datasource.

## Phase 6 — Create Repository Implementation

- [ ] Buat `voice_transaction_repository_impl.dart`.
- [ ] Inject audio recorder datasource dan remote datasource.
- [ ] Tangkap exception dan convert ke Failure.
- [ ] Jangan throw exception dari repository.

Acceptance criteria:

- Pattern sama seperti existing `AuthRepositoryImpl`.
- `PermissionException` dikonversi ke `PermissionFailure` jika class sudah ditambahkan.
- Unknown exception dikonversi ke `ServerFailure`.

## Phase 7 — Create Presentation Layer

- [ ] Buat binding:
  - [ ] register datasource
  - [ ] register repository
  - [ ] register usecases
  - [ ] register controller
- [ ] Buat controller dengan state enum:
  - [ ] idle
  - [ ] recording
  - [ ] uploading
  - [ ] processing
  - [ ] success
  - [ ] failure
- [ ] Buat page berbasis `GetView<VoiceTransactionController>`.
- [ ] Buat widgets:
  - [ ] record button
  - [ ] processing state
  - [ ] transcript preview
  - [ ] transaction draft card

Expected files:

```text
lib/features/voice_transaction/presentation/bindings/voice_transaction_binding.dart
lib/features/voice_transaction/presentation/controllers/voice_transaction_controller.dart
lib/features/voice_transaction/presentation/pages/voice_transaction_page.dart
lib/features/voice_transaction/presentation/widgets/voice_record_button_widget.dart
lib/features/voice_transaction/presentation/widgets/voice_processing_state_widget.dart
lib/features/voice_transaction/presentation/widgets/voice_transcript_preview_widget.dart
lib/features/voice_transaction/presentation/widgets/voice_transaction_draft_card_widget.dart
```

Acceptance criteria:

- Controller constructor injection, bukan `Get.find()` di dalam controller.
- Page tidak memanggil UseCase/Repository langsung.
- UI punya loading/error/success state.
- Draft belum otomatis save ke database.

## Phase 8 — Routing Integration

- [ ] Tambahkan route baru di `AppRoutes`.
- [ ] Register `GetPage` di `AppPages`.
- [ ] Tambahkan entry point dari halaman yang relevan, misalnya add transaction page/home FAB.

Expected route name:

```dart
Routes.voiceTransaction
```

Acceptance criteria:

- Navigasi ke page voice transaction berhasil.
- Binding terpasang ketika page dibuka.

## Phase 9 — Mock Backend Mode

- [ ] Tambahkan temporary mock datasource atau flag debug untuk mengembalikan response statis.
- [ ] Gunakan contoh input/output:

```json
{
  "transcript": {
    "raw": "mayar parkir motor lima ribu",
    "normalized": "bayar parkir motor lima ribu",
    "language_hint": "su-id",
    "confidence": 0.91
  },
  "transaction": {
    "type": "expense",
    "amount": 5000,
    "category": "Transportasi",
    "wallet": null,
    "description": "bayar parkir motor",
    "currency": "IDR"
  },
  "classification": {
    "type_confidence": 0.97,
    "category_confidence": 0.94,
    "wallet_confidence": 0.0,
    "overall_confidence": 0.91
  },
  "warnings": []
}
```

Acceptance criteria:

- UI bisa divalidasi tanpa backend FastAPI aktif.
- Mock mode mudah dimatikan ketika backend siap.

## Phase 10 — Backend Contract Stub

Jika backend dibuat di repo yang sama:

- [ ] Buat folder `ai_backend/`.
- [ ] Buat FastAPI app minimal.
- [ ] Buat endpoint `/api/v1/voice/parse`.
- [ ] Untuk tahap awal, return mock response dengan delay kecil.
- [ ] Tambahkan README cara run backend.

Expected files:

```text
ai_backend/app/main.py
ai_backend/app/api/voice_routes.py
ai_backend/app/schemas/voice_transaction_schema.py
ai_backend/requirements.txt
ai_backend/README.md
```

Acceptance criteria:

- Endpoint bisa dites via curl/Postman.
- Flutter remote datasource bisa hit backend lokal dengan env base URL.

## Phase 11 — Whisper Integration

- [ ] Install `faster-whisper` di backend.
- [ ] Buat `stt_service.py`.
- [ ] Load model `small` dengan opsi yang aman untuk CPU.
- [ ] Terima audio pendek dan hasilkan transcript.
- [ ] Tambahkan max duration validation.

Acceptance criteria:

- Audio 3–10 detik bisa diproses.
- Jika server terlalu berat, fallback ke model `base` boleh disediakan sebagai config.
- Transcript masuk ke response contract.

## Phase 12 — Parser Integration

- [ ] Buat text normalizer Sunda/Indonesia.
- [ ] Buat rule-based amount parser.
- [ ] Buat classifier service placeholder.
- [ ] Integrasikan model fine-tuned setelah training tersedia.
- [ ] Build final transaction JSON.

Acceptance criteria:

- `lima rebu` -> `5000`.
- `35rb` -> `35000`.
- `dua juta` -> `2000000`.
- Type/category/wallet bisa berasal dari model atau mock classifier sampai model siap.

## Phase 13 — Training Notebook / Research Pipeline

- [ ] Siapkan dataset loader JSONL/CSV.
- [ ] Split train/val/test.
- [ ] Train type classifier.
- [ ] Train category classifier.
- [ ] Optional train wallet classifier.
- [ ] Evaluate amount parser.
- [ ] Export metrics.
- [ ] Export model artifacts.

Recommended reports:

```text
reports/type_metrics.json
reports/category_metrics.json
reports/amount_parser_metrics.json
reports/end_to_end_metrics.json
```

Acceptance criteria:

- Ada baseline rule-based result.
- Ada model result.
- Ada metrics yang bisa dipakai di Bab Evaluasi skripsi.

## Phase 14 — Testing

- [ ] Unit test model parsing.
- [ ] Unit test amount parser jika parser ada di Dart/backend.
- [ ] Controller test dengan fake usecase.
- [ ] Manual test microphone permission.
- [ ] Manual test backend error state.
- [ ] Manual test success draft state.

Acceptance criteria:

- `flutter analyze` pass.
- `flutter test` pass minimal untuk unit yang dibuat.
- Tidak ada runtime crash saat permission denied.

## Phase 15 — Final Integration

- [ ] Hubungkan draft ke fitur transaction existing jika sudah tersedia.
- [ ] Tambahkan edit form sebelum save.
- [ ] Save transaksi hanya setelah user confirm.
- [ ] Log confidence/warnings untuk evaluasi jika dibutuhkan.

Acceptance criteria:

- User bisa dari voice input sampai draft.
- User bisa koreksi field.
- User bisa menyimpan transaksi valid.
- Hasil AI tetap bisa dibatalkan.

## Recommended Kiro Execution Prompt

Gunakan prompt ini saat mulai implementasi agar Kiro tidak melebar:

```text
Implement Phase 3 until Phase 4 only from `.kiro/specs/fluxa-voice-ai-pipeline`. Do not implement UI, routing, backend, or dependencies yet. Follow existing Clean Architecture + GetX + dartz conventions in docs. Create only domain entities, repository contract, usecases, and data models for voice_transaction. Keep code compile-safe and avoid changing unrelated files.
```

Setelah itu lanjut phase per phase, jangan sekaligus semua.
