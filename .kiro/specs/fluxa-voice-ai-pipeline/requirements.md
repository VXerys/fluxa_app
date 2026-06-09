# Requirements — Fluxa Voice AI Pipeline

## Context

Fluxa membutuhkan fitur pencatatan transaksi berbasis suara untuk bahasa sehari-hari Indonesia/Sunda. Dataset 5000 JSON digunakan untuk training/evaluasi transaction parser, sedangkan Whisper small dipakai sebagai pretrained speech-to-text model.

Repo saat ini sudah memakai Flutter Clean Architecture + GetX + dartz + Supabase. `pubspec.yaml` sudah berisi `get`, `dartz`, `supabase_flutter`, `flutter_dotenv`, `sqflite`, `path_provider`, `intl`, `logger`, dan `uuid`, tetapi belum ada dependency untuk audio recording atau HTTP multipart upload. Karena itu fitur voice AI harus ditambahkan sebagai feature baru dan tetap mengikuti struktur `data -> domain -> presentation`.

## Goals

1. User dapat merekam suara transaksi dari Flutter.
2. Audio dikirim ke backend AI API, bukan diproses berat di device.
3. Backend mengubah audio menjadi transcript memakai faster-whisper small.
4. Backend melakukan normalisasi teks Indonesia/Sunda.
5. Backend melakukan klasifikasi transaksi memakai model NLP hasil training dari 5000 dataset JSON.
6. Backend mengekstrak nominal uang memakai rule-based amount parser.
7. Flutter menerima structured response dan menampilkan draft transaksi.
8. User dapat mengedit/mengonfirmasi draft sebelum transaksi disimpan.
9. Implementasi tetap swap-able: backend Whisper dapat diganti tanpa mengubah domain/presentation Flutter.

## Non-Goals

1. Tidak melakukan fine-tuning Whisper small pada fase ini.
2. Tidak menjalankan Whisper small langsung di Flutter pada fase awal.
3. Tidak langsung menyimpan hasil AI tanpa konfirmasi user.
4. Tidak membuat model seq2seq yang langsung generate JSON sebagai metode utama.
5. Tidak menyimpan API key/model secret di Flutter.
6. Tidak menjadikan `speech_to_text` device sebagai metode utama skripsi, karena output tidak berasal dari Whisper.

## Functional Requirements

### FR-1 — Voice recording

Flutter harus menyediakan mekanisme rekam suara untuk input transaksi.

Acceptance criteria:

- User bisa mulai/stop recording.
- State recording terlihat jelas: idle, recording, uploading, processing, success, failure.
- Audio disimpan sebagai temporary file lokal sebelum upload.
- Durasi maksimal default: 10 detik untuk MVP agar inference tidak berat.
- Ketika permission microphone ditolak, user mendapat error message yang jelas.

### FR-2 — Voice transaction upload

Flutter harus mengirim audio ke AI backend melalui multipart request.

Acceptance criteria:

- Request memakai `multipart/form-data`.
- Field file bernama `file`.
- Header dapat membawa auth token jika nanti API perlu proteksi.
- Timeout harus explicit, minimal 30 detik untuk proses STT.
- Response error dari backend dipetakan menjadi `Failure`, bukan dilempar sampai presentation.

### FR-3 — Backend voice parse endpoint

Backend harus menyediakan endpoint untuk memproses audio menjadi transaction draft.

Endpoint contract:

```text
POST /api/v1/voice/parse
Content-Type: multipart/form-data
file: audio file
```

Success response:

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

- Response selalu JSON valid.
- Field yang tidak terdeteksi bernilai `null`, bukan string kosong.
- `currency` default `IDR`.
- Backend memberi `warnings` jika amount/category/type kurang yakin.

### FR-4 — Transaction draft

Flutter harus menampilkan hasil AI sebagai draft transaksi.

Acceptance criteria:

- Draft menampilkan transcript mentah/normalisasi minimal di mode debug atau expandable detail.
- Field utama dapat direview: type, amount, category, wallet, description.
- User bisa mengedit field sebelum save.
- Save menggunakan flow transaksi existing bila sudah tersedia.
- Jika fitur transaction belum lengkap, draft tidak dipaksakan tersimpan dan cukup berhenti di preview.

### FR-5 — Dataset training usage

Dataset 5000 JSON dipakai untuk training/evaluasi classifier, bukan STT.

Acceptance criteria:

- Dataset dapat diubah menjadi training split untuk `type`, `category`, dan optional `wallet` classifier.
- Amount dievaluasi dari rule-based parser.
- Evaluation report minimal mencakup accuracy/F1 untuk type/category dan exact-match untuk amount.
- Ada baseline rule-based parser sebelum model classifier diintegrasikan.

## Technical Requirements

### TR-1 — Flutter architecture

Feature baru harus mengikuti Clean Architecture yang sudah ada:

```text
lib/features/voice_transaction/
├── data/
├── domain/
└── presentation/
```

Acceptance criteria:

- Domain layer tidak import Flutter/GetX/Dio/Supabase.
- Repository contract mengembalikan `Future<Either<Failure, Type>>`.
- DataSource boleh throw exception.
- Repository implementation menangkap exception dan mengonversi ke Failure.
- Controller hanya memanggil UseCase, bukan DataSource langsung.

### TR-2 — Dependency additions

Flutter membutuhkan dependency tambahan:

- Audio recording package: kandidat `record`.
- HTTP multipart client: kandidat `dio`.
- Permission handling: kandidat `permission_handler` jika package recording tidak cukup.

Acceptance criteria:

- Dependency ditambahkan hanya ketika implementasi dimulai.
- API base URL disimpan di `.env`/constants, bukan hardcoded di datasource.

### TR-3 — Backend separation

AI backend direkomendasikan sebagai service terpisah dari Flutter repo jika scope backend besar.

Acceptance criteria:

- Untuk Kiro di repo Flutter, cukup buat Flutter client contract dan docs backend contract.
- Backend FastAPI boleh dibuat di folder `ai_backend/` jika memang ingin monorepo, tetapi jangan dicampur dengan `lib/` Flutter.
- Secret/model path tidak boleh masuk repository publik.

## Quality Requirements

1. Feature harus testable dengan mock response tanpa backend aktif.
2. UI harus punya empty/error/loading state.
3. Error message harus user-friendly.
4. Semua model JSON parsing harus defensive terhadap field null.
5. Tidak boleh ada hardcoded localhost untuk release build.
6. Minimal ada unit test untuk response model parsing dan amount parser jika parser lokal ditambahkan.

## Research/Skripsi Requirements

Metode yang dijelaskan di laporan:

```text
1. Whisper small sebagai pretrained speech-to-text.
2. Fine-tuned IndoBERT/XLM-R classifier untuk type/category/wallet.
3. Rule-based amount parser untuk nominal uang.
4. End-to-end transaction JSON builder.
```

Evaluasi yang disarankan:

- WER untuk STT jika tersedia ground-truth audio transcript.
- Accuracy, precision, recall, F1-score untuk type classifier.
- Accuracy dan macro/weighted F1-score untuk category classifier.
- Exact-match amount accuracy.
- Field-level transaction JSON accuracy.
