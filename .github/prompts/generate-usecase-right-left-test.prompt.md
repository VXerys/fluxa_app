---
description: "Use when: generating usecase unit tests that validate Right and Left flows with dartz."
name: "Generate UseCase Right Left Test"
argument-hint: "[nama usecase] [nama params]"
agent: "Quality and Regression Sentinel"
---

Buat unit test instan untuk usecase berikut dengan skenario Right dan Left.

Input:
- UseCase file: [nama file]
- Repository contract: [paste signature]
- Params sample: [contoh params]
- Failure sample: [jenis failure]

Aturan wajib:
1. Gunakan pola arrange, act, assert.
2. Uji minimal dua skenario: repository mengembalikan Right dan repository mengembalikan Left.
3. Verifikasi interaksi repository dipanggil satu kali dengan params yang benar.
4. Nama test harus deskriptif dan konsisten.

Format output wajib:
- Kembalikan hanya isi file test lengkap siap tempel.
