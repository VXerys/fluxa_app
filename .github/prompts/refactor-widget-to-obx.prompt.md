---
description: "Use when: converting non-reactive widget or page code into GetX Obx reactive flow."
name: "Refactor Widget to Obx Reactive"
argument-hint: "[nama widget/page] [nama controller]"
agent: "GetX State and Navigation Specialist"
---

Ubah widget berikut menjadi reactive berbasis GetX Obx tanpa mengubah behavior bisnis.

Input:
- Widget atau Page: [nama file]
- Controller: [nama controller]
- Kode saat ini: [paste kode di sini]

Aturan wajib:
1. State dipusatkan di controller, bukan di widget.
2. Gunakan private Rx pada controller dan public getters.
3. Obx hanya membungkus area yang berubah.
4. Pertahankan alur UI saat ini, hanya ubah agar reactive.

Format output wajib:
1. Kode controller yang diperlukan
2. Kode widget atau page hasil refactor
3. Daftar state yang dipindahkan
