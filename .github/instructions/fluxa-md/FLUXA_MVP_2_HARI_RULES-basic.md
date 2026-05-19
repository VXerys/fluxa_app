# Aturan Basic MVP — Fluxa App

Dokumen ini berisi batasan, prioritas, dan arah implementasi **Basic MVP** untuk `fluxa_app`.

Scope ini dibuat lebih kecil dari MVP 2 hari sebelumnya karena arahan mentor adalah:

> Basic saja. Fokus ke data pencatatan pribadi: pemasukan, pengeluaran, dan kategori.

Dokumen ini menjadi pegangan agar implementasi tidak melebar ke fitur yang belum perlu.

---

## 1. Prinsip Utama Basic MVP

Basic MVP ini **bukan aplikasi keuangan lengkap**.

Basic MVP ini adalah aplikasi pencatatan keuangan pribadi yang paling sederhana, dengan fokus utama:

```text
- Catat pemasukan
- Catat pengeluaran
- Pilih kategori
- Lihat daftar transaksi
- Lihat ringkasan uang masuk, uang keluar, dan saldo/selisih
```

Tujuan utama:

> User bisa mencatat aktivitas uang pribadi secara basic dan melihat ringkasannya.

Yang harus dijaga:

```text
- Jangan membuat fitur terlalu banyak
- Jangan membuat tracking kompleks
- Jangan membuat dompet multi akun dulu
- Jangan membuat chart dulu jika belum perlu
- Jangan membuat AI, export, backup, atau premium dulu
- Jangan membuat menu yang belum bisa dipakai
```

---

## 2. Target Akhir Basic MVP

Basic MVP dianggap berhasil jika user bisa:

```text
- membuka aplikasi
- melihat ringkasan total pemasukan
- melihat ringkasan total pengeluaran
- melihat saldo / selisih
- menambah pemasukan
- menambah pengeluaran
- memilih kategori pemasukan
- memilih kategori pengeluaran
- melihat daftar transaksi
```

Flow utama yang wajib berjalan:

```text
Buka app
→ lihat Home
→ tap tambah transaksi
→ pilih pemasukan / pengeluaran
→ input nominal
→ pilih kategori
→ input catatan
→ simpan
→ transaksi muncul di list
→ ringkasan berubah
```

---

## 3. Scope yang Disepakati

Scope utama Basic MVP:

```text
1. Home Summary
2. Tambah Pemasukan
3. Tambah Pengeluaran
4. Kategori Default
5. List Transaksi
6. Profile / Setting Basic
```

Scope ini sudah cukup untuk pencatatan pribadi basic.

---

## 4. Struktur Navigasi Basic MVP

Gunakan navigasi yang sederhana.

### Opsi Utama yang Direkomendasikan

```text
Tab:
1. Home
2. Transaksi
3. Profile / Setting

FAB:
+ Tambah Transaksi
```

### Opsi Jika Tracking Tetap Ingin Dipisah

```text
Tab:
1. Home
2. Transaksi
3. Tracking
4. Profile

FAB:
+ Tambah Transaksi
```

Namun untuk versi paling basic, tracking tidak perlu menjadi tab penuh. Ringkasan tracking cukup ditampilkan di Home.

---

## 5. Scope Home Basic

Home cukup menampilkan ringkasan utama.

### Section Home

```text
Header
- Nama aplikasi atau greeting sederhana

Summary
- Total pemasukan
- Total pengeluaran
- Saldo / selisih

Transaksi Terakhir
- 3 sampai 5 transaksi terakhir
```

### Yang Wajib Ada

```text
- Total pemasukan
- Total pengeluaran
- Saldo / selisih
- Transaksi terakhir
- Tombol tambah transaksi
```

### Yang Tidak Dibuat Dulu

```text
- Period filter Hari/Minggu/Bulan/Tahun
- Dompet Saya
- Menu shortcut banyak
- Anggaran
- Tagihan
- Target tabungan
- Chart
- Premium banner
- Level user
- Profile badge kompleks
```

---

## 6. Scope Transaksi Basic

Transaksi adalah fitur utama.

### Tipe Transaksi

```text
1. Pemasukan
2. Pengeluaran
```

Transfer tidak dibuat dulu.

### Field Transaksi

Field wajib:

```text
- Tipe transaksi
- Nominal
- Kategori
- Catatan / judul
- Tanggal
```

Field opsional:

```text
- Jam transaksi
```

### Field yang Tidak Dibuat Dulu

```text
- Dompet multi akun
- Foto struk
- Tags
- Lampiran
- Lokasi
- Transfer fee
- Currency selain IDR
- Recurring
```

### Flow Tambah Transaksi

```text
Tap tambah transaksi
→ pilih tipe: pemasukan / pengeluaran
→ input nominal
→ pilih kategori
→ input catatan
→ pilih tanggal
→ simpan
→ kembali ke list atau Home
→ summary ter-update
```

### Validasi Minimal

```text
- Nominal wajib diisi
- Nominal harus lebih dari 0
- Kategori wajib dipilih
- Tanggal default hari ini
- Catatan boleh kosong
```

---

## 7. Kategori Default Basic

Kategori tidak perlu CRUD dulu. Gunakan kategori bawaan/default.

### Kategori Pengeluaran

```text
- Makan & Minum
- Transportasi
- Belanja
- Tagihan
- Kesehatan
- Hiburan
- Pendidikan
- Lainnya
```

### Kategori Pemasukan

```text
- Gaji
- Freelance
- Bonus
- Hadiah
- Jualan
- Lainnya
```

### Catatan

Untuk Basic MVP:

```text
- User cukup memilih kategori
- Tambah kategori custom ditunda
- Edit kategori ditunda
- Hapus kategori ditunda
- Icon dan warna kategori bisa dibuat sederhana
```

Jika ingin tetap menyiapkan UI kategori, cukup tampilkan daftar kategori default.

---

## 8. Scope List Transaksi

List transaksi harus jelas dan mudah dibaca.

### Informasi yang Ditampilkan

```text
- Judul / catatan transaksi
- Kategori
- Tanggal
- Nominal
- Indikator pemasukan atau pengeluaran
```

### Format Nominal

```text
Pemasukan:
+Rp50.000

Pengeluaran:
-Rp25.000
```

### Filter Basic

Untuk MVP basic, filter tidak wajib.

Jika sempat, cukup tambahkan:

```text
- Semua
- Pemasukan
- Pengeluaran
```

### Yang Ditunda

```text
- Filter tanggal kompleks
- Search transaksi
- Sort custom
- Export
- Grouping per bulan kompleks
```

---

## 9. Scope Ringkasan / Tracking Basic

Tracking dibuat sangat sederhana.

### Ringkasan yang Dibutuhkan

```text
- Total pemasukan
- Total pengeluaran
- Saldo / selisih
```

Formula:

```text
saldo / selisih = total pemasukan - total pengeluaran
```

### Tambahan Jika Sempat

```text
- Total pengeluaran per kategori dalam bentuk list sederhana
```

Contoh:

```text
Makan & Minum     Rp150.000
Transportasi      Rp50.000
Belanja           Rp75.000
```

### Yang Tidak Dibuat Dulu

```text
- Bar chart
- Pie chart
- Line chart
- Custom date range
- Statistik tahunan
- Perbandingan bulan sebelumnya
- Insight otomatis
```

---

## 10. Scope Profile / Setting Basic

Profile tidak perlu kompleks.

### Isi Profile Basic

```text
- Nama user lokal atau placeholder
- Tentang aplikasi
- Reset data
```

Jika sudah ada auth:

```text
- Nama user
- Email
- Logout
```

### Yang Tidak Dibuat Dulu

```text
- Edit avatar
- Upgrade premium
- Backup & pemulihan
- Export data
- Import data
- Tema
- Icon pack
- Subscription
```

---

## 11. Dompet untuk Basic MVP

Untuk scope basic, **dompet multi akun tidak dibuat dulu**.

Gunakan konsep sederhana:

```text
Semua transaksi dihitung langsung ke saldo/selisih.
```

Atau jika tetap butuh wallet secara data:

```text
Default wallet: Cash
```

### Tidak Perlu Dulu

```text
- Tambah dompet
- Edit dompet
- Banyak wallet
- Cash / Bank / E-Wallet
- Saldo awal per dompet
- Transfer antar dompet
```

Alasan:

```text
Dompet multi akun membuat scope lebih besar karena perlu update saldo per wallet, validasi wallet, dan UI manajemen wallet.
```

Untuk Rp250.000 dan waktu 2 hari, fitur dompet detail lebih baik ditunda.

---

## 12. Tombol Tambah

Gunakan satu tombol tambah transaksi.

### Opsi Paling Simpel

```text
FAB +
→ buka Add Transaction Page
→ user pilih tipe pemasukan / pengeluaran di dalam form
```

### Opsi Bottom Sheet

```text
FAB +
├── Tambah Pemasukan
└── Tambah Pengeluaran
```

Untuk basic MVP, rekomendasi paling cepat:

```text
FAB +
→ Add Transaction Page
```

Karena satu form lebih mudah dijaga dan tidak perlu banyak flow.

---

## 13. Prioritas Implementasi

Urutan implementasi yang disarankan:

```text
1. Model/entity transaksi
2. Data lokal sederhana untuk transaksi
3. Kategori default
4. Add Transaction Page
5. List transaksi
6. Home summary
7. Profile basic
8. UI polish
```

Jangan mulai dari chart, dompet, atau profile kompleks sebelum flow transaksi selesai.

---

## 14. Checklist Hari 1

Fokus hari pertama:

```text
[ ] Setup struktur tab / navigation basic
[ ] Buat data kategori default
[ ] Buat form tambah transaksi
[ ] Implement tambah pemasukan
[ ] Implement tambah pengeluaran
[ ] Simpan transaksi
[ ] Tampilkan list transaksi
```

Target akhir hari 1:

```text
User bisa tambah pemasukan dan pengeluaran, lalu melihatnya di list transaksi.
```

---

## 15. Checklist Hari 2

Fokus hari kedua:

```text
[ ] Buat Home summary
[ ] Hitung total pemasukan
[ ] Hitung total pengeluaran
[ ] Hitung saldo / selisih
[ ] Tampilkan transaksi terakhir di Home
[ ] Buat Profile / Setting basic
[ ] Tambahkan empty state
[ ] Tambahkan validasi form
[ ] Polish UI basic
```

Target akhir hari 2:

```text
Aplikasi basic sudah bisa dipakai untuk pencatatan uang pribadi.
```

---

## 16. Acceptance Criteria Basic MVP

Basic MVP selesai jika:

### Navigation

```text
[ ] Home bisa dibuka
[ ] Transaksi bisa dibuka
[ ] Profile / Setting bisa dibuka
[ ] Tombol tambah transaksi bisa dibuka
```

### Transaksi

```text
[ ] Bisa tambah pemasukan
[ ] Bisa tambah pengeluaran
[ ] Nominal tervalidasi
[ ] Kategori bisa dipilih
[ ] Catatan bisa diisi
[ ] Tanggal default hari ini
[ ] Data transaksi tersimpan
[ ] Data transaksi tampil di list
```

### Kategori

```text
[ ] Kategori pemasukan default tersedia
[ ] Kategori pengeluaran default tersedia
[ ] Kategori menyesuaikan tipe transaksi
```

### Home

```text
[ ] Total pemasukan tampil
[ ] Total pengeluaran tampil
[ ] Saldo / selisih tampil
[ ] Transaksi terakhir tampil
```

### Profile / Setting

```text
[ ] Profile basic tampil
[ ] Tentang aplikasi tampil
[ ] Reset data atau logout tersedia sesuai kondisi app
```

---

## 17. Fitur yang Wajib Ditunda

Fitur berikut tidak masuk Basic MVP:

```text
- Dompet multi akun
- Transfer antar dompet
- Tracking chart
- Budget / Anggaran
- Tagihan
- Target tabungan
- Catat cepat
- AI Receipt Scanner
- Voice Quick Record
- Export CSV / Excel / PDF
- Backup & restore
- Login/register jika belum tersedia
- Cloud sync kompleks
- Offline queue
- Premium
- Theme custom
- Icon pack
- Menu ordering
- Multi currency
- Exchange rate
- Recurring transaction
```

Jika fitur tersebut diminta, masukkan ke fase berikutnya.

---

## 18. Non-Goals Basic MVP

Hal berikut tidak menjadi target:

```text
- UI harus sama persis dengan aplikasi referensi
- Semua fitur finance lengkap harus tersedia
- Semua menu harus ada
- Semua chart harus ada
- Semua data harus cloud sync
- Semua pengaturan profile harus jalan
- Semua fitur premium harus ada
```

Target utama hanya:

```text
Pencatatan pemasukan dan pengeluaran pribadi berjalan stabil.
```

---

## 19. Batasan Nilai Pekerjaan

Karena scope pekerjaan bernilai sekitar **Rp250.000**, scope harus tetap basic.

Scope yang masih fair:

```text
- Add income
- Add expense
- Default categories
- Transaction list
- Home summary
- Basic profile/settings
- UI basic rapi
```

Scope yang sudah terlalu besar untuk nilai ini:

```text
- Multi wallet
- Chart tracking
- Export
- Backup
- Auth kompleks
- Cloud sync
- AI
- Premium
- Budget
- Recurring
```

Jika diminta tambahan fitur, posisikan sebagai pekerjaan fase lanjutan.

---

## 20. Rekomendasi Komunikasi ke Mentor

Pesan yang bisa digunakan:

```text
Siap Teh, berarti saya buat basic dulu. Fokusnya hanya data pencatatan pribadi:
1. Tambah pemasukan
2. Tambah pengeluaran
3. Kategori default pemasukan dan pengeluaran
4. List transaksi
5. Ringkasan total pemasukan, pengeluaran, dan saldo/selisih

Fitur seperti dompet multi akun, chart tracking, budget, tagihan, target tabungan, catat cepat, export, backup, dan AI saya pending dulu supaya sesuai scope basic dan bisa selesai rapi.
```

Versi singkat:

```text
Siap Teh, saya pangkas ke basic MVP dulu: pemasukan, pengeluaran, kategori default, list transaksi, dan ringkasan saldo. Fitur tambahan saya pending untuk fase berikutnya.
```

---

## 21. Ringkasan Final

Basic MVP Fluxa harus menjawab lima hal:

```text
1. Uang masuk berapa?
2. Uang keluar berapa?
3. Sisa/selisih berapa?
4. Transaksinya apa saja?
5. Kategorinya apa?
```

Jika lima hal itu sudah terjawab, Basic MVP sudah sesuai arahan mentor.

---

## 22. Keputusan Final Scope

Final scope:

```text
Basic MVP:
- Home summary
- Add income
- Add expense
- Default category
- Transaction list
- Simple profile/settings
```

Final postponed:

```text
- Wallet detail
- Tracking chart
- Catat cepat
- Budget
- Tagihan
- Target
- Export
- Backup
- AI
- Premium
```
