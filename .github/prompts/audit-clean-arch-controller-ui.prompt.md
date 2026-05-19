---
description: "Use when: auditing whether controller or UI code violates clean architecture boundaries in fluxa_app."
name: "Audit Clean Architecture Controller UI"
argument-hint: "[nama feature] [nama file controller/page]"
agent: "Architecture Governor"
---

Audit kode berikut terhadap standar fluxa_app.

Input:
- Feature: [nama feature]
- File: [nama file]
- Kode: [paste kode di sini]

Validasi wajib:
1. Controller hanya memanggil UseCase, bukan datasource atau repository.
2. Page/Widget tidak mengakses layer Data secara langsung.
3. Dependency direction tetap Presentation -> Domain <- Data.
4. Obx scope minimal, state pada controller menggunakan private Rx + public getter.

Format output wajib:
1. Verdict: PASS atau FAIL
2. Daftar pelanggaran per rule (jika ada)
3. Perbaikan minimal yang disarankan per pelanggaran
4. Risiko bila pelanggaran dibiarkan
