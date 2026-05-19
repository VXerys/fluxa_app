---
description: "Use when: verifying model and entity contract compliance in fluxa_app clean architecture."
name: "Verify Model Entity Contract"
argument-hint: "[nama model] [nama entity]"
agent: "Supabase Data and Repository Specialist"
---

Validasi kontrak model dan entity berikut sesuai standar fluxa_app.

Input:
- Entity code: [paste kode]
- Model code: [paste kode]

Aturan wajib:
1. Entity hanya berisi properti dan constructor.
2. Model harus extend Entity.
3. Model harus memiliki fromJson, toJson, dan toEntity.
4. Tidak ada kebocoran concern data ke domain murni.

Format output wajib:
1. Status PASS atau FAIL per rule
2. Kode yang diperbaiki jika ada FAIL
