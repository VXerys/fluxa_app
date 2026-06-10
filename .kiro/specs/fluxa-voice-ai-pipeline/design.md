# Design — Fluxa Voice AI Pipeline

## Repo Analysis Summary

Berdasarkan repo `VXerys/fluxa_app`:

1. Project adalah Flutter app dengan SDK Dart `^3.10.7`.
2. Dependency utama yang sudah tersedia: `get`, `get_storage`, `dartz`, `supabase_flutter`, `flutter_dotenv`, `sqflite`, `path_provider`, `intl`, `logger`, `uuid`, dan beberapa UI packages.
3. Belum ada dependency audio recorder dan HTTP multipart client. Fitur voice AI membutuhkan penambahan dependency.
4. Dokumentasi arsitektur sudah jelas memakai Feature-First Clean Architecture + GetX.
5. Existing auth feature menunjukkan pola yang harus diikuti: abstract datasource, impl datasource, model extends entity, repository impl menangkap exception dan mengembalikan `Either<Failure, Entity>`.
6. Guideline internal lama masih menyebut `speech_to_text` sebagai transcriber default. Untuk arah skripsi terbaru, ini harus diupdate/digeser menjadi optional debug/prototype mode, bukan metode utama.

## Proposed Architecture

```text
Flutter App
├── voice_transaction feature
│   ├── records audio file
│   ├── uploads multipart request
│   ├── receives voice transaction result
│   └── shows editable draft card
│
└── AI Backend API
    ├── faster-whisper small STT
    ├── text normalizer Sunda/Indonesia
    ├── transaction classifier from 5000 JSON dataset
    ├── rule-based amount parser
    └── transaction JSON builder
```

## Flutter Feature Structure

```text
lib/features/voice_transaction/
├── data/
│   ├── datasources/
│   │   ├── voice_audio_recorder_datasource.dart
│   │   ├── voice_audio_recorder_datasource_impl.dart
│   │   ├── voice_transaction_remote_datasource.dart
│   │   └── voice_transaction_remote_datasource_impl.dart
│   ├── models/
│   │   ├── voice_transcript_model.dart
│   │   ├── voice_transaction_model.dart
│   │   ├── voice_classification_model.dart
│   │   └── voice_transaction_result_model.dart
│   └── repositories/
│       └── voice_transaction_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── voice_transcript_entity.dart
│   │   ├── voice_transaction_entity.dart
│   │   ├── voice_classification_entity.dart
│   │   └── voice_transaction_result_entity.dart
│   ├── repositories/
│   │   └── voice_transaction_repository.dart
│   └── usecases/
│       ├── start_voice_recording_usecase.dart
│       ├── stop_voice_recording_usecase.dart
│       ├── cancel_voice_recording_usecase.dart
│       └── parse_voice_transaction_usecase.dart
└── presentation/
    ├── bindings/
    │   └── voice_transaction_binding.dart
    ├── controllers/
    │   └── voice_transaction_controller.dart
    ├── pages/
    │   └── voice_transaction_page.dart
    └── widgets/
        ├── voice_record_button_widget.dart
        ├── voice_processing_state_widget.dart
        ├── voice_transaction_draft_card_widget.dart
        └── voice_transcript_preview_widget.dart
```

## Domain Entities

### VoiceTranscriptEntity

```dart
class VoiceTranscriptEntity {
  final String raw;
  final String normalized;
  final String? languageHint;
  final double confidence;

  const VoiceTranscriptEntity({
    required this.raw,
    required this.normalized,
    this.languageHint,
    required this.confidence,
  });
}
```

### VoiceTransactionEntity

```dart
class VoiceTransactionEntity {
  final String? type; // expense | income | transfer
  final int? amount;
  final String? category;
  final String? wallet;
  final String? description;
  final String currency;

  const VoiceTransactionEntity({
    this.type,
    this.amount,
    this.category,
    this.wallet,
    this.description,
    this.currency = 'IDR',
  });
}
```

### VoiceClassificationEntity

```dart
class VoiceClassificationEntity {
  final double typeConfidence;
  final double categoryConfidence;
  final double walletConfidence;
  final double overallConfidence;

  const VoiceClassificationEntity({
    required this.typeConfidence,
    required this.categoryConfidence,
    required this.walletConfidence,
    required this.overallConfidence,
  });
}
```

### VoiceTransactionResultEntity

```dart
class VoiceTransactionResultEntity {
  final VoiceTranscriptEntity transcript;
  final VoiceTransactionEntity transaction;
  final VoiceClassificationEntity classification;
  final List<String> warnings;

  const VoiceTransactionResultEntity({
    required this.transcript,
    required this.transaction,
    required this.classification,
    this.warnings = const [],
  });
}
```

## Repository Contract

```dart
abstract class VoiceTransactionRepository {
  Future<Either<Failure, void>> startRecording();
  Future<Either<Failure, String>> stopRecording();
  Future<Either<Failure, void>> cancelRecording();
  Future<Either<Failure, VoiceTransactionResultEntity>> parseVoiceTransaction({
    required String audioFilePath,
  });
}
```

## DataSource Contracts

### VoiceAudioRecorderDatasource

```dart
abstract class VoiceAudioRecorderDatasource {
  Future<void> startRecording();
  Future<String> stopRecording();
  Future<void> cancelRecording();
  Future<bool> hasPermission();
  bool get isRecording;
}
```

### VoiceTransactionRemoteDatasource

```dart
abstract class VoiceTransactionRemoteDatasource {
  Future<VoiceTransactionResultModel> parseVoiceTransaction({
    required String audioFilePath,
  });
}
```

## API Configuration

Tambahkan konfigurasi base URL:

```text
.env
FLUXA_AI_API_BASE_URL=https://your-fluxa-ai-api.example.com
```

Tambahkan constant:

```dart
class AppConstants {
  static String get fluxaAiApiBaseUrl => dotenv.env['FLUXA_AI_API_BASE_URL'] ?? '';
}
```

Jika project belum punya Dio client global, buat salah satu:

```text
lib/core/network/dio_client.dart
```

atau inject Dio langsung di binding feature agar scope tetap kecil.

## Dependency Additions

Tambahkan saat implementasi:

```yaml
dependencies:
  dio: ^5.x.x
  record: ^5.x.x
  permission_handler: ^11.x.x # optional jika record permission handling belum cukup
```

Catatan: version exact dicek saat implementasi agar kompatibel dengan SDK project.

## Flutter Controller State

Gunakan enum agar state tidak bercampur boolean terlalu banyak.

```dart
enum VoiceTransactionStatus {
  idle,
  recording,
  uploading,
  processing,
  success,
  failure,
}
```

Controller menyimpan private Rx:

```dart
final Rx<VoiceTransactionStatus> _status = VoiceTransactionStatus.idle.obs;
VoiceTransactionStatus get status => _status.value;

final Rx<VoiceTransactionResultEntity?> _result = Rx(null);
VoiceTransactionResultEntity? get result => _result.value;

final RxString _errorMessage = ''.obs;
String get errorMessage => _errorMessage.value;
```

## UI Design Direction

Minimal MVP UI:

1. Header: `Catat transaksi dengan suara`.
2. Helper text: contoh input `mayar parkir motor lima rebu`.
3. Large mic button dengan state:
   - idle: tap to record
   - recording: animated pulse + stop
   - uploading/processing: disabled + progress indicator
4. Draft card setelah sukses:
   - Type chip
   - Amount prominent
   - Category
   - Wallet
   - Description
   - Confidence indicator kecil
   - Edit button
   - Save button
5. Error state:
   - retry button
   - message singkat

## Backend Design Contract

Backend disarankan dibuat dengan FastAPI:

```text
ai_backend/
├── app/
│   ├── main.py
│   ├── api/
│   │   └── voice_routes.py
│   ├── services/
│   │   ├── stt_service.py
│   │   ├── text_normalizer_service.py
│   │   ├── transaction_classifier_service.py
│   │   ├── amount_parser_service.py
│   │   └── transaction_builder_service.py
│   ├── schemas/
│   │   └── voice_transaction_schema.py
│   └── models/
│       └── classifier/
├── requirements.txt
└── README.md
```

Backend stack:

```text
fastapi
uvicorn
python-multipart
faster-whisper
transformers
torch
pydantic
```

## Training Design

Dataset 5000 JSON dipakai sebagai:

```text
text -> type label
text -> category label
text -> wallet label optional
text -> expected_amount for parser evaluation
```

Recommended notebook outputs:

```text
models/
├── type_classifier/
├── category_classifier/
└── wallet_classifier/ optional

reports/
├── type_metrics.json
├── category_metrics.json
├── amount_parser_metrics.json
└── end_to_end_metrics.json
```

## Files That Need Updates Later

### Required Flutter updates

1. `pubspec.yaml`
   - add `dio`
   - add `record`
   - optional `permission_handler`

2. `.env`
   - add `FLUXA_AI_API_BASE_URL`

3. `lib/core/constants/app_constants.dart`
   - expose AI API base URL

4. `lib/core/network/`
   - add `dio_client.dart` if not available

5. `lib/core/routes/app_routes.dart`
   - add voice transaction route

6. `lib/core/routes/app_pages.dart`
   - register `VoiceTransactionPage` with `VoiceTransactionBinding`

7. `lib/core/errors/exceptions.dart`
   - add `PermissionException` if not yet available

8. `lib/core/errors/failures.dart`
   - add `PermissionFailure` and optional `ValidationFailure` if not yet available

9. `lib/features/voice_transaction/`
   - create full feature structure

### Documentation updates

1. `.github/instructions/fluxa-md/TECHNICAL_GUIDELINES-FLUXA.md`
   - replace old assumption that `speech_to_text` is default method
   - document backend Whisper as primary method
   - keep device speech as optional prototype/debug mode only

2. `docs/struktur.md` and `docs/struktur_feature.md`
   - no architecture changes required; only reference new feature if desired

## Implementation Risk

1. Whisper small inference may be too heavy on Heroku CPU dyno.
   - Mitigation: use short audio duration, try model `base` fallback, enable int8 quantization, or deploy AI API to GPU/cloud service.

2. Backend latency may feel slow.
   - Mitigation: show clear processing state and keep max duration short.

3. Classifier deployment can be heavy.
   - Mitigation: start with rule-based parser + mock classifier response; integrate model after training pipeline is stable.

4. Dataset may not include audio.
   - Mitigation: thesis framing should state Whisper is pretrained STT and dataset 5000 trains text-to-transaction parser.

## Recommended Implementation Order

1. Flutter UI + mock result.
2. Flutter record audio local file.
3. Remote datasource multipart upload.
4. Backend FastAPI mock endpoint.
5. Backend faster-whisper small integration.
6. Rule-based amount parser integration.
7. Classifier model integration.
8. End-to-end evaluation.
