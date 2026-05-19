---
description: "Use when: running a pre-merge risk check for regressions across architecture, freemium, and offline flows."
name: "Pre Merge Feature Risk Check"
argument-hint: "[nama feature] [daftar file berubah]"
agent: "Quality and Regression Sentinel"
---

Lakukan risk check pre-merge untuk perubahan berikut.

Input:
- Feature: [nama feature]
- Changed files: [paste daftar file]
- Optional diff snippets: [paste bagian penting]

Cek wajib:
1. Layer boundary tetap aman sesuai clean architecture.
2. Mapping Failure konsisten dari repository.
3. Perilaku Free versus Pro tidak regress.
4. Jalur online versus offline tetap aman.
5. GetX binding dan route tetap valid.

Format output wajib:
1. Temuan diurutkan dari severity tertinggi
2. Daftar test yang wajib dijalankan
3. Residual risks yang masih tersisa
