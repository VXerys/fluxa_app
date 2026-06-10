# Fluxa Voice AI Pipeline Spec

Spec ini mendefinisikan arah implementasi fitur voice transaction untuk kebutuhan skripsi Fluxa.

Keputusan metode utama:

```text
Flutter record audio
↓
Backend FastAPI
↓
faster-whisper small untuk speech-to-text
↓
Text normalizer Sunda/Indonesia
↓
Fine-tuned IndoBERT/XLM-R classifier dari 5000 JSON dataset
↓
Rule-based amount parser
↓
Transaction JSON
↓
Flutter draft transaction card
```

## Dokumen

- `requirements.md` — requirement, acceptance criteria, scope, dan non-goals.
- `design.md` — desain arsitektur Flutter, backend AI API, kontrak response, struktur folder, dan perubahan repo.
- `tasks.md` — task implementasi bertahap agar cocok digunakan di Kiro.

## Prinsip utama

1. Whisper small tidak di-fine-tune pada fase ini. Whisper dipakai sebagai pretrained STT.
2. Dataset 5000 JSON dipakai untuk melatih model NLP transaction classifier, bukan untuk melatih Whisper.
3. Flutter tidak menjalankan model berat. Flutter hanya record audio, upload file, menerima JSON, dan menampilkan draft transaksi.
4. Nominal uang memakai rule-based parser agar stabil untuk ekspresi seperti `lima rebu`, `35rb`, `dua juta`, dan variasi Sunda/Indonesia.
5. Output AI tidak langsung disimpan sebagai transaksi final. Output harus menjadi draft yang bisa dikoreksi user.
