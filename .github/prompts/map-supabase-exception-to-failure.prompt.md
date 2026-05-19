---
description: "Use when: converting Supabase or datasource exceptions into Failure mapping at repository layer."
name: "Map Supabase Exception to Failure"
argument-hint: "[nama repository] [nama method]"
agent: "Supabase Data and Repository Specialist"
---

Refactor repository method berikut agar exception mentah dari datasource tidak bocor ke layer atas.

Input:
- Repository: [nama repository]
- Method: [nama method]
- Kode saat ini: [paste kode di sini]

Aturan wajib:
1. Datasource melempar typed exceptions, bukan Either.
2. Repository menangkap exception lalu mengembalikan Future<Either<Failure, T>>.
3. Tidak ada throw exception mentah dari repository.
4. Mapping minimal harus mempertimbangkan ServerFailure, NetworkFailure, CacheFailure, AuthFailure.

Format output wajib:
1. Kode method hasil refactor
2. Tabel singkat mapping exception -> failure
