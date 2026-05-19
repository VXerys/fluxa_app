---
description: "Use when: fixing GetX binding order, missing dependency injection, or controller resolution errors."
name: "Fix GetX Binding Order"
argument-hint: "[nama feature]"
agent: "GetX State and Navigation Specialist"
---

Audit dan perbaiki binding order untuk feature berikut.

Input:
- Feature: [nama feature]
- Binding code: [paste kode di sini]
- Error log: [paste error di sini]

Aturan wajib:
1. Urutan registrasi harus DataSource -> Repository -> UseCase -> Controller.
2. Controller wajib constructor injection.
3. Hindari dependency lookup acak di field controller.

Format output wajib:
1. Kode binding final
2. Akar masalah dalam tiga poin singkat
