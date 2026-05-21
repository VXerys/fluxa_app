-- =========================================================
-- FLUXA: Seed Hierarchical System Categories
-- Purpose:
-- - Update categories from flat list into parent-child hierarchy
-- - Keep existing transactions safe
-- - Do NOT delete user custom categories
-- - Do NOT delete existing system categories that may already be referenced
-- =========================================================

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ---------------------------------------------------------
-- 1. Fix old unique index so parent/child with same name can coexist
-- ---------------------------------------------------------
-- Old index from previous migration:
-- categories_system_name_type_idx ON (name, type, is_system)
--
-- This is too restrictive for hierarchy because parent and child may share
-- same name/type. Replace it with parent-aware unique index.

DROP INDEX IF EXISTS public.categories_system_name_type_idx;

CREATE UNIQUE INDEX IF NOT EXISTS categories_system_unique_hierarchy_idx
ON public.categories (
  name,
  type,
  is_system,
  COALESCE(parent_id, '00000000-0000-0000-0000-000000000000'::uuid)
);

-- ---------------------------------------------------------
-- 2. Parent categories: EXPENSE
-- ---------------------------------------------------------

INSERT INTO public.categories (name, type, icon, color, is_system, parent_id, sort_order, created_at)
VALUES
  ('Makan & Minum', 'expense', 'food', '#F4A62A', TRUE, NULL, 10, NOW()),
  ('Transportasi', 'expense', 'transport', '#6F35C8', TRUE, NULL, 20, NOW()),
  ('Belanja', 'expense', 'shopping', '#38B6D8', TRUE, NULL, 30, NOW()),
  ('Rumah', 'expense', 'housing', '#5266B1', TRUE, NULL, 40, NOW()),
  ('Hiburan', 'expense', 'entertainment', '#C9D84A', TRUE, NULL, 50, NOW()),
  ('Kesehatan', 'expense', 'health', '#54BFE0', TRUE, NULL, 60, NOW()),
  ('Pendidikan', 'expense', 'education', '#8E5AE8', TRUE, NULL, 70, NOW()),
  ('Tagihan', 'expense', 'bill', '#E86E6E', TRUE, NULL, 80, NOW()),
  ('Lainnya', 'expense', 'other', '#8A8F98', TRUE, NULL, 90, NOW())
ON CONFLICT (name, type, is_system, COALESCE(parent_id, '00000000-0000-0000-0000-000000000000'::uuid))
DO UPDATE SET
  icon = EXCLUDED.icon,
  color = EXCLUDED.color,
  sort_order = EXCLUDED.sort_order;

-- Update older existing flat system categories so they become parent categories
UPDATE public.categories
SET
  icon = CASE name
    WHEN 'Makan & Minum' THEN 'food'
    WHEN 'Transportasi' THEN 'transport'
    WHEN 'Belanja' THEN 'shopping'
    WHEN 'Rumah' THEN 'housing'
    WHEN 'Hiburan' THEN 'entertainment'
    WHEN 'Kesehatan' THEN 'health'
    WHEN 'Pendidikan' THEN 'education'
    WHEN 'Tagihan' THEN 'bill'
    WHEN 'Lainnya' THEN 'other'
    ELSE icon
  END,
  color = CASE name
    WHEN 'Makan & Minum' THEN '#F4A62A'
    WHEN 'Transportasi' THEN '#6F35C8'
    WHEN 'Belanja' THEN '#38B6D8'
    WHEN 'Rumah' THEN '#5266B1'
    WHEN 'Hiburan' THEN '#C9D84A'
    WHEN 'Kesehatan' THEN '#54BFE0'
    WHEN 'Pendidikan' THEN '#8E5AE8'
    WHEN 'Tagihan' THEN '#E86E6E'
    WHEN 'Lainnya' THEN '#8A8F98'
    ELSE color
  END,
  sort_order = CASE name
    WHEN 'Makan & Minum' THEN 10
    WHEN 'Transportasi' THEN 20
    WHEN 'Belanja' THEN 30
    WHEN 'Rumah' THEN 40
    WHEN 'Hiburan' THEN 50
    WHEN 'Kesehatan' THEN 60
    WHEN 'Pendidikan' THEN 70
    WHEN 'Tagihan' THEN 80
    WHEN 'Lainnya' THEN 90
    ELSE sort_order
  END,
  parent_id = NULL
WHERE is_system = TRUE
  AND type = 'expense'
  AND name IN (
    'Makan & Minum',
    'Transportasi',
    'Belanja',
    'Rumah',
    'Hiburan',
    'Kesehatan',
    'Pendidikan',
    'Tagihan',
    'Lainnya'
  );

-- ---------------------------------------------------------
-- 3. Parent categories: INCOME
-- ---------------------------------------------------------

INSERT INTO public.categories (name, type, icon, color, is_system, parent_id, sort_order, created_at)
VALUES
  ('Gaji', 'income', 'salary', '#3FBF7F', TRUE, NULL, 10, NOW()),
  ('Freelance', 'income', 'freelance', '#3A8DFF', TRUE, NULL, 20, NOW()),
  ('Bisnis', 'income', 'business', '#F4A62A', TRUE, NULL, 30, NOW()),
  ('Investasi', 'income', 'investment', '#7D5FFF', TRUE, NULL, 40, NOW()),
  ('Hadiah', 'income', 'gift', '#E85EA8', TRUE, NULL, 50, NOW()),
  ('Pengembalian', 'income', 'refund', '#48B6A3', TRUE, NULL, 60, NOW()),
  ('Lainnya', 'income', 'other', '#8A8F98', TRUE, NULL, 70, NOW())
ON CONFLICT (name, type, is_system, COALESCE(parent_id, '00000000-0000-0000-0000-000000000000'::uuid))
DO UPDATE SET
  icon = EXCLUDED.icon,
  color = EXCLUDED.color,
  sort_order = EXCLUDED.sort_order;

-- Update old income categories
UPDATE public.categories
SET
  icon = CASE name
    WHEN 'Gaji' THEN 'salary'
    WHEN 'Freelance' THEN 'freelance'
    WHEN 'Bisnis' THEN 'business'
    WHEN 'Investasi' THEN 'investment'
    WHEN 'Hadiah' THEN 'gift'
    WHEN 'Pengembalian' THEN 'refund'
    WHEN 'Lainnya' THEN 'other'
    ELSE icon
  END,
  color = CASE name
    WHEN 'Gaji' THEN '#3FBF7F'
    WHEN 'Freelance' THEN '#3A8DFF'
    WHEN 'Bisnis' THEN '#F4A62A'
    WHEN 'Investasi' THEN '#7D5FFF'
    WHEN 'Hadiah' THEN '#E85EA8'
    WHEN 'Pengembalian' THEN '#48B6A3'
    WHEN 'Lainnya' THEN '#8A8F98'
    ELSE color
  END,
  sort_order = CASE name
    WHEN 'Gaji' THEN 10
    WHEN 'Freelance' THEN 20
    WHEN 'Bisnis' THEN 30
    WHEN 'Investasi' THEN 40
    WHEN 'Hadiah' THEN 50
    WHEN 'Pengembalian' THEN 60
    WHEN 'Lainnya' THEN 70
    ELSE sort_order
  END,
  parent_id = NULL
WHERE is_system = TRUE
  AND type = 'income'
  AND name IN (
    'Gaji',
    'Freelance',
    'Bisnis',
    'Investasi',
    'Hadiah',
    'Pengembalian',
    'Lainnya'
  );

-- ---------------------------------------------------------
-- 4. Helper function to insert subcategories safely
-- ---------------------------------------------------------

CREATE OR REPLACE FUNCTION public.seed_system_subcategory(
  _parent_name TEXT,
  _type TEXT,
  _name TEXT,
  _icon TEXT,
  _color TEXT,
  _sort_order INTEGER
)
RETURNS VOID AS $$
DECLARE
  _parent_id UUID;
BEGIN
  SELECT id
  INTO _parent_id
  FROM public.categories
  WHERE name = _parent_name
    AND type = _type
    AND is_system = TRUE
    AND parent_id IS NULL
  ORDER BY created_at ASC
  LIMIT 1;

  IF _parent_id IS NULL THEN
    RAISE NOTICE 'Parent category not found: %, type=%', _parent_name, _type;
    RETURN;
  END IF;

  INSERT INTO public.categories (
    name,
    type,
    icon,
    color,
    is_system,
    parent_id,
    sort_order,
    created_at
  )
  VALUES (
    _name,
    _type,
    _icon,
    _color,
    TRUE,
    _parent_id,
    _sort_order,
    NOW()
  )
  ON CONFLICT (
    name,
    type,
    is_system,
    COALESCE(parent_id, '00000000-0000-0000-0000-000000000000'::uuid)
  )
  DO UPDATE SET
    icon = EXCLUDED.icon,
    color = EXCLUDED.color,
    sort_order = EXCLUDED.sort_order,
    parent_id = EXCLUDED.parent_id;
END;
$$ LANGUAGE plpgsql;

-- ---------------------------------------------------------
-- 5. Expense subcategories
-- ---------------------------------------------------------

-- Makan & Minum
SELECT public.seed_system_subcategory('Makan & Minum', 'expense', 'Sarapan', 'breakfast', '#F4A62A', 11);
SELECT public.seed_system_subcategory('Makan & Minum', 'expense', 'Makan Siang', 'lunch', '#F4A62A', 12);
SELECT public.seed_system_subcategory('Makan & Minum', 'expense', 'Makan Malam', 'dinner', '#F4A62A', 13);
SELECT public.seed_system_subcategory('Makan & Minum', 'expense', 'Kopi', 'coffee', '#F4A62A', 14);
SELECT public.seed_system_subcategory('Makan & Minum', 'expense', 'Camilan', 'snack', '#F4A62A', 15);
SELECT public.seed_system_subcategory('Makan & Minum', 'expense', 'Restoran', 'restaurant', '#F4A62A', 16);
SELECT public.seed_system_subcategory('Makan & Minum', 'expense', 'Bahan Makanan', 'groceries', '#F4A62A', 17);

-- Transportasi
SELECT public.seed_system_subcategory('Transportasi', 'expense', 'Bus', 'bus', '#6F35C8', 21);
SELECT public.seed_system_subcategory('Transportasi', 'expense', 'Kereta', 'train', '#6F35C8', 22);
SELECT public.seed_system_subcategory('Transportasi', 'expense', 'Taksi', 'taxi', '#6F35C8', 23);
SELECT public.seed_system_subcategory('Transportasi', 'expense', 'Bensin', 'fuel', '#6F35C8', 24);
SELECT public.seed_system_subcategory('Transportasi', 'expense', 'Parkir', 'parking', '#6F35C8', 25);
SELECT public.seed_system_subcategory('Transportasi', 'expense', 'Ojek Online', 'online_ride', '#6F35C8', 26);
SELECT public.seed_system_subcategory('Transportasi', 'expense', 'Servis Kendaraan', 'vehicle_service', '#6F35C8', 27);

-- Belanja
SELECT public.seed_system_subcategory('Belanja', 'expense', 'Pakaian', 'clothes', '#38B6D8', 31);
SELECT public.seed_system_subcategory('Belanja', 'expense', 'Sepatu', 'shoes', '#38B6D8', 32);
SELECT public.seed_system_subcategory('Belanja', 'expense', 'Aksesori', 'accessories', '#38B6D8', 33);
SELECT public.seed_system_subcategory('Belanja', 'expense', 'Elektronik', 'electronics', '#38B6D8', 34);
SELECT public.seed_system_subcategory('Belanja', 'expense', 'Marketplace', 'marketplace', '#38B6D8', 35);
SELECT public.seed_system_subcategory('Belanja', 'expense', 'Perawatan Diri', 'personal_care', '#38B6D8', 36);

-- Rumah
SELECT public.seed_system_subcategory('Rumah', 'expense', 'Sewa', 'rent', '#5266B1', 41);
SELECT public.seed_system_subcategory('Rumah', 'expense', 'Listrik', 'electricity', '#5266B1', 42);
SELECT public.seed_system_subcategory('Rumah', 'expense', 'Air', 'water', '#5266B1', 43);
SELECT public.seed_system_subcategory('Rumah', 'expense', 'Internet', 'internet', '#5266B1', 44);
SELECT public.seed_system_subcategory('Rumah', 'expense', 'Furnitur', 'furniture', '#5266B1', 45);
SELECT public.seed_system_subcategory('Rumah', 'expense', 'Kebersihan', 'cleaning', '#5266B1', 46);
SELECT public.seed_system_subcategory('Rumah', 'expense', 'Perbaikan Rumah', 'home_repair', '#5266B1', 47);

-- Hiburan
SELECT public.seed_system_subcategory('Hiburan', 'expense', 'Film', 'movie', '#C9D84A', 51);
SELECT public.seed_system_subcategory('Hiburan', 'expense', 'Musik', 'music', '#C9D84A', 52);
SELECT public.seed_system_subcategory('Hiburan', 'expense', 'Game', 'game', '#C9D84A', 53);
SELECT public.seed_system_subcategory('Hiburan', 'expense', 'Konser', 'concert', '#C9D84A', 54);
SELECT public.seed_system_subcategory('Hiburan', 'expense', 'Streaming', 'streaming', '#C9D84A', 55);
SELECT public.seed_system_subcategory('Hiburan', 'expense', 'Liburan', 'vacation', '#C9D84A', 56);
SELECT public.seed_system_subcategory('Hiburan', 'expense', 'Hobi', 'hobby', '#C9D84A', 57);

-- Kesehatan
SELECT public.seed_system_subcategory('Kesehatan', 'expense', 'Dokter', 'doctor', '#54BFE0', 61);
SELECT public.seed_system_subcategory('Kesehatan', 'expense', 'Obat', 'medicine', '#54BFE0', 62);
SELECT public.seed_system_subcategory('Kesehatan', 'expense', 'Rumah Sakit', 'hospital', '#54BFE0', 63);
SELECT public.seed_system_subcategory('Kesehatan', 'expense', 'Asuransi', 'insurance', '#54BFE0', 64);
SELECT public.seed_system_subcategory('Kesehatan', 'expense', 'Gym', 'gym', '#54BFE0', 65);
SELECT public.seed_system_subcategory('Kesehatan', 'expense', 'Vitamin', 'vitamin', '#54BFE0', 66);

-- Pendidikan
SELECT public.seed_system_subcategory('Pendidikan', 'expense', 'Kursus', 'course', '#8E5AE8', 71);
SELECT public.seed_system_subcategory('Pendidikan', 'expense', 'Buku', 'book', '#8E5AE8', 72);
SELECT public.seed_system_subcategory('Pendidikan', 'expense', 'Uang Sekolah', 'tuition', '#8E5AE8', 73);
SELECT public.seed_system_subcategory('Pendidikan', 'expense', 'Seminar', 'seminar', '#8E5AE8', 74);
SELECT public.seed_system_subcategory('Pendidikan', 'expense', 'Sertifikasi', 'certification', '#8E5AE8', 75);
SELECT public.seed_system_subcategory('Pendidikan', 'expense', 'Alat Tulis', 'stationery', '#8E5AE8', 76);

-- Tagihan
SELECT public.seed_system_subcategory('Tagihan', 'expense', 'Pulsa', 'phone_credit', '#E86E6E', 81);
SELECT public.seed_system_subcategory('Tagihan', 'expense', 'Paket Data', 'mobile_data', '#E86E6E', 82);
SELECT public.seed_system_subcategory('Tagihan', 'expense', 'Langganan', 'subscription', '#E86E6E', 83);
SELECT public.seed_system_subcategory('Tagihan', 'expense', 'Kartu Kredit', 'credit_card', '#E86E6E', 84);
SELECT public.seed_system_subcategory('Tagihan', 'expense', 'Cicilan', 'loan', '#E86E6E', 85);
SELECT public.seed_system_subcategory('Tagihan', 'expense', 'Pajak', 'tax', '#E86E6E', 86);

-- Lainnya
SELECT public.seed_system_subcategory('Lainnya', 'expense', 'Hadiah Keluar', 'gift_out', '#8A8F98', 91);
SELECT public.seed_system_subcategory('Lainnya', 'expense', 'Donasi', 'donation', '#8A8F98', 92);
SELECT public.seed_system_subcategory('Lainnya', 'expense', 'Biaya Admin', 'admin_fee', '#8A8F98', 93);
SELECT public.seed_system_subcategory('Lainnya', 'expense', 'Tak Terduga', 'unexpected', '#8A8F98', 94);
SELECT public.seed_system_subcategory('Lainnya', 'expense', 'Pengeluaran Lainnya', 'other_expense', '#8A8F98', 95);

-- ---------------------------------------------------------
-- 6. Income subcategories
-- ---------------------------------------------------------

-- Gaji
SELECT public.seed_system_subcategory('Gaji', 'income', 'Gaji Bulanan', 'monthly_salary', '#3FBF7F', 11);
SELECT public.seed_system_subcategory('Gaji', 'income', 'Tunjangan', 'allowance', '#3FBF7F', 12);
SELECT public.seed_system_subcategory('Gaji', 'income', 'Lembur', 'overtime', '#3FBF7F', 13);
SELECT public.seed_system_subcategory('Gaji', 'income', 'Bonus Gaji', 'salary_bonus', '#3FBF7F', 14);

-- Freelance
SELECT public.seed_system_subcategory('Freelance', 'income', 'Project', 'project', '#3A8DFF', 21);
SELECT public.seed_system_subcategory('Freelance', 'income', 'Design', 'design', '#3A8DFF', 22);
SELECT public.seed_system_subcategory('Freelance', 'income', 'Development', 'development', '#3A8DFF', 23);
SELECT public.seed_system_subcategory('Freelance', 'income', 'Writing', 'writing', '#3A8DFF', 24);
SELECT public.seed_system_subcategory('Freelance', 'income', 'Konsultasi', 'consultation', '#3A8DFF', 25);

-- Bisnis
SELECT public.seed_system_subcategory('Bisnis', 'income', 'Penjualan Produk', 'product_sales', '#F4A62A', 31);
SELECT public.seed_system_subcategory('Bisnis', 'income', 'Penjualan Jasa', 'service_sales', '#F4A62A', 32);
SELECT public.seed_system_subcategory('Bisnis', 'income', 'Keuntungan', 'profit', '#F4A62A', 33);
SELECT public.seed_system_subcategory('Bisnis', 'income', 'Komisi', 'commission', '#F4A62A', 34);

-- Investasi
SELECT public.seed_system_subcategory('Investasi', 'income', 'Dividen', 'dividend', '#7D5FFF', 41);
SELECT public.seed_system_subcategory('Investasi', 'income', 'Bunga', 'interest', '#7D5FFF', 42);
SELECT public.seed_system_subcategory('Investasi', 'income', 'Capital Gain', 'capital_gain', '#7D5FFF', 43);
SELECT public.seed_system_subcategory('Investasi', 'income', 'Crypto', 'crypto', '#7D5FFF', 44);
SELECT public.seed_system_subcategory('Investasi', 'income', 'Saham', 'stock', '#7D5FFF', 45);

-- Hadiah
SELECT public.seed_system_subcategory('Hadiah', 'income', 'Keluarga', 'family', '#E85EA8', 51);
SELECT public.seed_system_subcategory('Hadiah', 'income', 'Teman', 'friend', '#E85EA8', 52);
SELECT public.seed_system_subcategory('Hadiah', 'income', 'Reward', 'reward', '#E85EA8', 53);
SELECT public.seed_system_subcategory('Hadiah', 'income', 'Hadiah Lomba', 'prize', '#E85EA8', 54);

-- Pengembalian
SELECT public.seed_system_subcategory('Pengembalian', 'income', 'Cashback', 'cashback', '#48B6A3', 61);
SELECT public.seed_system_subcategory('Pengembalian', 'income', 'Refund', 'refund', '#48B6A3', 62);
SELECT public.seed_system_subcategory('Pengembalian', 'income', 'Reimbursement', 'reimbursement', '#48B6A3', 63);
SELECT public.seed_system_subcategory('Pengembalian', 'income', 'Utang Dibayar', 'debt_paid', '#48B6A3', 64);

-- Lainnya
SELECT public.seed_system_subcategory('Lainnya', 'income', 'Pemasukan Lainnya', 'other_income', '#8A8F98', 71);

-- ---------------------------------------------------------
-- 7. Optional cleanup: remove helper function after seed
-- ---------------------------------------------------------

DROP FUNCTION IF EXISTS public.seed_system_subcategory(TEXT, TEXT, TEXT, TEXT, TEXT, INTEGER);

-- ---------------------------------------------------------
-- 8. Verification
-- ---------------------------------------------------------

DO $$
DECLARE
  parent_expense_count INT;
  child_expense_count INT;
  parent_income_count INT;
  child_income_count INT;
BEGIN
  SELECT COUNT(*) INTO parent_expense_count
  FROM public.categories
  WHERE is_system = TRUE
    AND type = 'expense'
    AND parent_id IS NULL;

  SELECT COUNT(*) INTO child_expense_count
  FROM public.categories
  WHERE is_system = TRUE
    AND type = 'expense'
    AND parent_id IS NOT NULL;

  SELECT COUNT(*) INTO parent_income_count
  FROM public.categories
  WHERE is_system = TRUE
    AND type = 'income'
    AND parent_id IS NULL;

  SELECT COUNT(*) INTO child_income_count
  FROM public.categories
  WHERE is_system = TRUE
    AND type = 'income'
    AND parent_id IS NOT NULL;

  RAISE NOTICE 'Expense parents: %, Expense children: %', parent_expense_count, child_expense_count;
  RAISE NOTICE 'Income parents: %, Income children: %', parent_income_count, child_income_count;
END;
$$ LANGUAGE plpgsql;

-- ---------------------------------------------------------
-- 9. Preview result
-- ---------------------------------------------------------

SELECT
  p.type,
  p.name AS parent_category,
  p.icon AS parent_icon,
  p.color AS parent_color,
  p.sort_order AS parent_sort_order,
  c.name AS child_category,
  c.icon AS child_icon,
  c.color AS child_color,
  c.sort_order AS child_sort_order
FROM public.categories p
LEFT JOIN public.categories c
  ON c.parent_id = p.id
WHERE p.is_system = TRUE
  AND p.parent_id IS NULL
ORDER BY
  p.type,
  p.sort_order,
  c.sort_order;