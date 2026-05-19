# DATABASE.md — Skema Database fluxa_app

> Kembali ke: [README.md](../README.md) | [FEATURES.md](FEATURES.md) | [TECHNICAL_GUIDELINES.md](TECHNICAL_GUIDELINES.md)

---

## Dua Lapisan Database

`fluxa_app` menggunakan **dua database yang bekerja bersama**:

| Layer | Teknologi | Fungsi |
|-------|-----------|--------|
| **Remote (Cloud)** | Supabase (PostgreSQL) | Source of truth. Data permanen, sinkronisasi antar perangkat |
| **Local** | `sqflite` | Cache untuk read cepat, offline queue untuk write saat tidak ada koneksi |

---

## Bagian 1: Supabase (PostgreSQL) — Remote Database

### 1.1 Tabel: `profiles`

Ekstensi dari tabel `auth.users` bawaan Supabase. Dibuat otomatis via trigger saat user register.

```sql
CREATE TABLE public.profiles (
  id            UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  username      TEXT UNIQUE,
  display_name  TEXT,
  avatar_url    TEXT,
  is_pro        BOOLEAN NOT NULL DEFAULT FALSE,
  pro_expires_at TIMESTAMPTZ,              -- NULL = tidak pernah berlangganan / sudah expired
  scan_quota_used    INTEGER DEFAULT 0,    -- Reset tiap awal bulan
  voice_quota_used   INTEGER DEFAULT 0,   -- Reset tiap awal bulan
  quota_reset_date   DATE DEFAULT CURRENT_DATE,
  default_currency   TEXT DEFAULT 'IDR',
  created_at    TIMESTAMPTZ DEFAULT NOW(),
  updated_at    TIMESTAMPTZ DEFAULT NOW()
);

-- Trigger: Buat profil otomatis saat user baru register
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, display_name)
  VALUES (NEW.id, NEW.raw_user_meta_data->>'full_name');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
```

**Kolom penting:**
- `is_pro` + `pro_expires_at`: Digunakan sebagai gating di `PremiumService`. Cek di client: `profile.isPro && profile.proExpiresAt?.isAfter(DateTime.now()) == true`
- `scan_quota_used` & `voice_quota_used`: Di-increment oleh backend (Supabase Edge Function) setelah setiap scan/voice yang berhasil, bukan oleh client, untuk mencegah manipulasi.
- `quota_reset_date`: Saat app dibuka, jika `quota_reset_date < CURRENT_DATE`, Edge Function reset kedua counter ke 0.

### 1.2 Tabel: `wallets`

Dompet pengguna (Cash, Bank, E-Wallet, dll).

```sql
CREATE TABLE public.wallets (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name            TEXT NOT NULL,                   -- "Cash", "BCA", "GoPay"
  type            TEXT NOT NULL                    -- 'cash', 'bank', 'ewallet', 'credit', 'savings', 'investment'
                    CHECK (type IN ('cash', 'bank', 'ewallet', 'credit', 'savings', 'investment')),
  balance         NUMERIC(15, 2) NOT NULL DEFAULT 0,
  currency        TEXT NOT NULL DEFAULT 'IDR',
  icon            TEXT,                            -- ID icon dari icon pack
  color           TEXT,                            -- Hex color kartu dompet
  is_archived     BOOLEAN DEFAULT FALSE,
  include_in_total BOOLEAN DEFAULT TRUE,           -- Apakah masuk ke Total Saldo di home
  sort_order      INTEGER DEFAULT 0,
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  updated_at      TIMESTAMPTZ DEFAULT NOW()
);

-- RLS
ALTER TABLE public.wallets ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can only access their own wallets"
  ON public.wallets
  FOR ALL USING (auth.uid() = user_id);
```

### 1.3 Tabel: `categories`

Kategori transaksi. Sistem menyediakan kategori default, user bisa tambah custom.

```sql
CREATE TABLE public.categories (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID REFERENCES auth.users(id) ON DELETE CASCADE,
                  -- NULL = kategori sistem (global, tidak bisa dihapus user)
  name            TEXT NOT NULL,
  type            TEXT NOT NULL CHECK (type IN ('income', 'expense', 'transfer')),
  icon            TEXT,
  color           TEXT,
  is_system       BOOLEAN DEFAULT FALSE,   -- TRUE = kategori bawaan sistem
  parent_id       UUID REFERENCES public.categories(id),  -- Sub-kategori opsional
  sort_order      INTEGER DEFAULT 0,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- RLS: User bisa baca kategori sistem + kategori milik sendiri
CREATE POLICY "Read own and system categories"
  ON public.categories FOR SELECT
  USING (user_id = auth.uid() OR is_system = TRUE);

CREATE POLICY "Manage own categories"
  ON public.categories FOR ALL
  USING (user_id = auth.uid() AND is_system = FALSE);
```

**Contoh data kategori sistem (seeded):**

| name | type | icon |
|------|------|------|
| Makan & Minum | expense | 🍽️ |
| Transportasi | expense | 🚗 |
| Belanja | expense | 🛍️ |
| Tagihan & Utilitas | expense | 💡 |
| Hiburan | expense | 🎬 |
| Kesehatan | expense | 💊 |
| Gaji | income | 💰 |
| Freelance | income | 💻 |
| Transfer | transfer | ↔️ |

### 1.4 Tabel: `transactions`

Tabel utama. Menyimpan semua transaksi keuangan.

```sql
CREATE TABLE public.transactions (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id           UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  wallet_id         UUID NOT NULL REFERENCES public.wallets(id),
  category_id       UUID REFERENCES public.categories(id),
  type              TEXT NOT NULL CHECK (type IN ('income', 'expense', 'transfer')),

  -- Untuk transaksi biasa:
  amount            NUMERIC(15, 2) NOT NULL,
  currency          TEXT NOT NULL DEFAULT 'IDR',

  -- Untuk transaksi multi-currency:
  original_amount   NUMERIC(15, 2),           -- Nominal asli (misal: 10 USD)
  original_currency TEXT,                      -- Mata uang asli ('USD')
  exchange_rate     NUMERIC(12, 6),            -- Kurs saat transaksi (10 USD × 15.500 = 155.000)

  -- Untuk transfer antar dompet:
  to_wallet_id      UUID REFERENCES public.wallets(id),
  transfer_fee      NUMERIC(15, 2) DEFAULT 0,

  note              TEXT,                      -- Smart Notes
  tags              TEXT[],                    -- Array tag/label
  date              DATE NOT NULL,             -- Tanggal transaksi (bukan created_at)
  time              TIME,                      -- Waktu transaksi (opsional)

  -- Recurring
  recurring_id      UUID REFERENCES public.recurring_transactions(id),
  is_recurring      BOOLEAN DEFAULT FALSE,

  -- Receipt Scanner
  receipt_image_url TEXT,                      -- URL gambar struk (Supabase Storage)

  -- Metadata
  is_deleted        BOOLEAN DEFAULT FALSE,     -- Soft delete
  created_at        TIMESTAMPTZ DEFAULT NOW(),
  updated_at        TIMESTAMPTZ DEFAULT NOW()
);

-- Index untuk performa query umum
CREATE INDEX idx_transactions_user_date ON public.transactions (user_id, date DESC);
CREATE INDEX idx_transactions_wallet ON public.transactions (wallet_id);
CREATE INDEX idx_transactions_category ON public.transactions (category_id);

-- RLS
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users manage their own transactions"
  ON public.transactions FOR ALL
  USING (auth.uid() = user_id);
```

### 1.5 Tabel: `recurring_transactions`

Template transaksi berulang.

```sql
CREATE TABLE public.recurring_transactions (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id           UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  wallet_id         UUID NOT NULL REFERENCES public.wallets(id),
  category_id       UUID REFERENCES public.categories(id),
  type              TEXT NOT NULL CHECK (type IN ('income', 'expense')),
  amount            NUMERIC(15, 2) NOT NULL,
  currency          TEXT NOT NULL DEFAULT 'IDR',
  note              TEXT,

  recurrence_type   TEXT NOT NULL CHECK (recurrence_type IN ('daily', 'weekly', 'monthly', 'yearly', 'custom')),
  recurrence_value  INTEGER,   -- Untuk 'custom': setiap N hari. Untuk 'weekly': 1-7 (hari ke)
  day_of_month      INTEGER,   -- Untuk 'monthly': 1-31
  start_date        DATE NOT NULL,
  end_date          DATE,      -- NULL = tidak ada batas akhir
  next_due_date     DATE NOT NULL,

  is_active         BOOLEAN DEFAULT TRUE,
  created_at        TIMESTAMPTZ DEFAULT NOW(),
  updated_at        TIMESTAMPTZ DEFAULT NOW()
);

-- RLS
ALTER TABLE public.recurring_transactions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users manage their own recurring"
  ON public.recurring_transactions FOR ALL
  USING (auth.uid() = user_id);
```

### 1.6 Tabel: `budgets`

Anggaran per kategori per periode.

```sql
CREATE TABLE public.budgets (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  category_id     UUID NOT NULL REFERENCES public.categories(id),
  amount          NUMERIC(15, 2) NOT NULL,
  period          TEXT NOT NULL CHECK (period IN ('weekly', 'monthly', 'yearly')),
  start_date      DATE NOT NULL,
  end_date        DATE,
  is_active       BOOLEAN DEFAULT TRUE,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.budgets ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users manage their own budgets"
  ON public.budgets FOR ALL USING (auth.uid() = user_id);
```

### 1.7 Tabel: `savings_goals`

Target tabungan.

```sql
CREATE TABLE public.savings_goals (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  wallet_id       UUID REFERENCES public.wallets(id),
  name            TEXT NOT NULL,
  target_amount   NUMERIC(15, 2) NOT NULL,
  current_amount  NUMERIC(15, 2) DEFAULT 0,
  target_date     DATE,
  icon            TEXT,
  color           TEXT,
  is_completed    BOOLEAN DEFAULT FALSE,
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  updated_at      TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.savings_goals ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users manage their own goals"
  ON public.savings_goals FOR ALL USING (auth.uid() = user_id);
```

### 1.8 Tabel: `user_preferences`

Preferensi kustomisasi per user (tema aktif, icon pack, urutan menu, dll).

```sql
CREATE TABLE public.user_preferences (
  user_id           UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  active_theme_id   TEXT DEFAULT 'classic',
  active_icon_pack  TEXT DEFAULT 'default',
  card_style        TEXT DEFAULT 'gradient',        -- 'gradient', 'flat', 'glassmorphism'
  menu_order        TEXT[],                          -- Array ID menu sesuai urutan kustom
  balance_format    TEXT DEFAULT 'rp_dot',          -- 'rp_dot', 'rp_comma', 'code_space'
  show_balance      BOOLEAN DEFAULT TRUE,
  bar_appearance    TEXT DEFAULT 'rounded',
  language          TEXT DEFAULT 'id',
  updated_at        TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.user_preferences ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users manage their own preferences"
  ON public.user_preferences FOR ALL USING (auth.uid() = user_id);
```

### 1.9 Supabase Storage Buckets

```
Bucket: receipt-images
  Path: {user_id}/{transaction_id}.jpg
  Access: Private (hanya user yang bersangkutan)
  Max size: 5 MB per file

Bucket: avatars
  Path: {user_id}/avatar.jpg
  Access: Public
```

---

## Bagian 2: `sqflite` — Local Database

### 2.1 Filosofi Penggunaan

`sqflite` digunakan untuk **dua tujuan yang berbeda** dan tidak boleh dicampurkan:

| Tujuan | Tabel | Kapan Dipakai |
|--------|-------|---------------|
| **Offline Queue** | `offline_queue` | Menyimpan operasi write (INSERT/UPDATE/DELETE) yang gagal karena tidak ada koneksi, agar bisa di-sync saat online |
| **Read Cache** | `transactions_cache`, `exchange_rates_cache` | Menyimpan data yang sudah di-fetch dari Supabase agar bisa dibaca cepat tanpa internet |

### 2.2 `LocalDatabaseService` — Inisialisasi

```dart
// lib/core/database/local_database_service.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDatabaseService {
  static Database? _database;
  static const int _version = 1;
  static const String _dbName = 'fluxa_local.db';

  static Future<void> init() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    _database = await openDatabase(
      path,
      version: _version,
      onCreate: _createTables,
      onUpgrade: _onUpgrade,
    );
  }

  static Database get database {
    if (_database == null) throw Exception('LocalDB not initialized');
    return _database!;
  }

  static Future<void> _createTables(Database db, int version) async {
    await db.execute(_createOfflineQueueTable);
    await db.execute(_createTransactionsCacheTable);
    await db.execute(_createExchangeRatesCacheTable);
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Migrasi bertahap jika skema berubah
    // if (oldVersion < 2) { await db.execute('ALTER TABLE ...'); }
  }
}
```

### 2.3 Tabel `offline_queue`

```dart
static const String _createOfflineQueueTable = '''
  CREATE TABLE IF NOT EXISTS offline_queue (
    id            TEXT PRIMARY KEY,
    action        TEXT NOT NULL,        -- 'INSERT', 'UPDATE', 'DELETE'
    entity_type   TEXT NOT NULL,        -- 'transaction', 'wallet', 'budget', dll
    payload       TEXT NOT NULL,        -- JSON string
    status        TEXT DEFAULT 'PENDING', -- 'PENDING', 'SYNCED', 'FAILED'
    created_at    INTEGER NOT NULL,     -- Unix timestamp milliseconds
    retry_count   INTEGER DEFAULT 0
  )
''';
```

**Cara kerja `offline_queue`:**

```dart
// Di TransactionLocalDataSource

Future<void> addToOfflineQueue({
  required String id,
  required String action,        // 'INSERT'
  required String entityType,    // 'transaction'
  required Map<String, dynamic> payload,
}) async {
  await LocalDatabaseService.database.insert(
    'offline_queue',
    {
      'id': id,
      'action': action,
      'entity_type': entityType,
      'payload': jsonEncode(payload),
      'status': 'PENDING',
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'retry_count': 0,
    },
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Future<List<Map<String, dynamic>>> getPendingQueue() async {
  final rows = await LocalDatabaseService.database.query(
    'offline_queue',
    where: "status = 'PENDING'",
    orderBy: 'created_at ASC',    // FIFO — yang pertama masuk, pertama di-sync
  );
  return rows.map((row) => {
    ...row,
    'payload': jsonDecode(row['payload'] as String),
  }).toList();
}

Future<void> markAsSynced(String id) async {
  await LocalDatabaseService.database.update(
    'offline_queue',
    {'status': 'SYNCED'},
    where: 'id = ?',
    whereArgs: [id],
  );
}
```

### 2.4 Tabel `transactions_cache`

```dart
static const String _createTransactionsCacheTable = '''
  CREATE TABLE IF NOT EXISTS transactions_cache (
    id              TEXT PRIMARY KEY,
    user_id         TEXT NOT NULL,
    wallet_id       TEXT,
    category_id     TEXT,
    type            TEXT NOT NULL,
    amount          REAL NOT NULL,
    currency        TEXT NOT NULL,
    note            TEXT,
    date            INTEGER NOT NULL,   -- Unix timestamp (date only)
    is_synced       INTEGER DEFAULT 1,  -- 0 = ada di offline queue, belum di Supabase
    raw_json        TEXT NOT NULL,      -- Full JSON untuk serialisasi kembali ke Entity
    cached_at       INTEGER NOT NULL    -- Kapan cache ini dibuat
  )
''';
```

**Aturan cache transaksi:**
- Cache maksimum 90 hari ke belakang. Entry lebih lama dari 90 hari dihapus dari cache (tapi tetap ada di Supabase).
- Saat online dan data di-fetch dari Supabase, selalu timpa cache yang ada.
- Cache digunakan untuk read saat offline (tampilkan data terakhir yang diketahui).

### 2.5 Tabel `exchange_rates_cache`

```dart
static const String _createExchangeRatesCacheTable = '''
  CREATE TABLE IF NOT EXISTS exchange_rates_cache (
    base_currency   TEXT NOT NULL,
    target_currency TEXT NOT NULL,
    rate            REAL NOT NULL,
    fetched_at      INTEGER NOT NULL,   -- Unix timestamp
    PRIMARY KEY (base_currency, target_currency)
  )
''';
```

**Strategi cache exchange rate:**

```dart
// Di ExchangeRateLocalDataSource

static const int _cacheTtlMs = 24 * 60 * 60 * 1000; // 24 jam

Future<double?> getCachedRate({
  required String base,
  required String target,
}) async {
  final now = DateTime.now().millisecondsSinceEpoch;
  final rows = await LocalDatabaseService.database.query(
    'exchange_rates_cache',
    where: "base_currency = ? AND target_currency = ? AND fetched_at > ?",
    whereArgs: [base, target, now - _cacheTtlMs],
  );

  if (rows.isEmpty) return null;   // Cache miss atau kadaluarsa
  return rows.first['rate'] as double;
}

Future<void> saveRate({
  required String base,
  required String target,
  required double rate,
}) async {
  await LocalDatabaseService.database.insert(
    'exchange_rates_cache',
    {
      'base_currency': base,
      'target_currency': target,
      'rate': rate,
      'fetched_at': DateTime.now().millisecondsSinceEpoch,
    },
    conflictAlgorithm: ConflictAlgorithm.replace,  // Timpa jika sudah ada
  );
}
```

### 2.6 Repository Pattern dengan Dua DataSource

```dart
// data/repositories/transaction_repository_impl.dart

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionRemoteDataSource remoteDataSource;  // Supabase
  final TransactionLocalDataSource localDataSource;    // sqflite
  final ConnectivityService connectivityService;       // Cek status koneksi

  TransactionRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.connectivityService,
  });

  @override
  Future<Either<Failure, TransactionEntity>> addTransaction({
    required AddTransactionParams params,
  }) async {
    try {
      final isOnline = await connectivityService.isConnected();

      if (isOnline) {
        // Online path: langsung ke Supabase + cache lokal
        final model = await remoteDataSource.insertTransaction(params);
        await localDataSource.cacheTransaction(model);
        return Right(model.toEntity());
      } else {
        // Offline path: masuk ke queue + cache lokal (dengan flag is_synced = 0)
        final tempId = const Uuid().v4();
        final tempModel = TransactionModel.fromParams(id: tempId, params: params);
        await localDataSource.addToOfflineQueue(
          id: tempId,
          action: 'INSERT',
          entityType: 'transaction',
          payload: tempModel.toJson(),
        );
        await localDataSource.cacheTransaction(tempModel, isSynced: false);
        return Right(tempModel.toEntity());
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> getTransactions({
    required GetTransactionsParams params,
  }) async {
    try {
      final isOnline = await connectivityService.isConnected();

      if (isOnline) {
        // Online: fetch dari Supabase, timpa cache
        final models = await remoteDataSource.getTransactions(params);
        await localDataSource.replaceCache(models);
        return Right(models.map((m) => m.toEntity()).toList());
      } else {
        // Offline: baca dari cache sqflite
        final cached = await localDataSource.getCachedTransactions(params);
        return Right(cached.map((m) => m.toEntity()).toList());
      }
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
```

---

## Ringkasan Relasi Antar Tabel (Supabase)

```
auth.users (Supabase built-in)
    │
    ├──< profiles (1:1)
    ├──< wallets (1:N)
    ├──< categories (1:N, custom categories)
    ├──< transactions (1:N)
    │       ├── wallet_id → wallets
    │       ├── category_id → categories
    │       ├── to_wallet_id → wallets (transfer)
    │       └── recurring_id → recurring_transactions
    ├──< recurring_transactions (1:N)
    ├──< budgets (1:N)
    │       └── category_id → categories
    ├──< savings_goals (1:N)
    └──< user_preferences (1:1)
```

---

*Kembali ke: [README.md](../README.md) | [FEATURES.md](FEATURES.md) | [TECHNICAL_GUIDELINES.md](TECHNICAL_GUIDELINES.md)*
