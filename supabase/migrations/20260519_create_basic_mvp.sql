-- Migration: Create basic MVP tables (profiles, categories, transactions)
-- Date: 2026-05-19
-- Idempotent: uses IF NOT EXISTS, DROP TRIGGER IF EXISTS, and ON CONFLICT DO NOTHING for seeds

-- Ensure pgcrypto for gen_random_uuid()
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- STEP 1: helper function to auto-update updated_at
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- STEP 2: profiles table
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  username TEXT UNIQUE,
  display_name TEXT,
  avatar_url TEXT,
  is_pro BOOLEAN NOT NULL DEFAULT FALSE,
  pro_expires_at TIMESTAMPTZ,
  scan_quota_used INTEGER DEFAULT 0,
  voice_quota_used INTEGER DEFAULT 0,
  quota_reset_date DATE DEFAULT CURRENT_DATE,
  default_currency TEXT DEFAULT 'IDR',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Trigger function to auto-create profile when a new auth.user is created
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
  _username TEXT;
  _display_name TEXT;
BEGIN
  _username := NULL;
  _display_name := NULL;

  IF NEW.email IS NOT NULL THEN
    _username := NEW.email;
  END IF;

  -- try common metadata columns to populate display_name
  BEGIN
    IF (pg_typeof(NEW.user_metadata) IS NOT NULL) THEN
      _display_name := (CASE WHEN NEW.user_metadata ? 'name' THEN NEW.user_metadata->> 'name' ELSE NULL END);
    ELSIF (pg_typeof(NEW.raw_user_meta_data) IS NOT NULL) THEN
      _display_name := (CASE WHEN NEW.raw_user_meta_data ? 'name' THEN NEW.raw_user_meta_data->> 'name' ELSE NULL END);
    END IF;
  EXCEPTION WHEN OTHERS THEN
    _display_name := NULL;
  END;

  INSERT INTO public.profiles (id, username, display_name, created_at, updated_at)
  VALUES (NEW.id, _username, _display_name, NOW(), NOW())
  ON CONFLICT (id) DO NOTHING;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create/replace trigger on auth.users: on_auth_user_created
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW
EXECUTE FUNCTION public.handle_new_user();

-- updated_at trigger for profiles
DROP TRIGGER IF EXISTS set_profiles_updated_at ON public.profiles;
CREATE TRIGGER set_profiles_updated_at
BEFORE UPDATE ON public.profiles
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

-- Enable RLS and create explicit policies for profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS profiles_select_own ON public.profiles;
CREATE POLICY profiles_select_own ON public.profiles
FOR SELECT
USING (auth.uid() = id);

DROP POLICY IF EXISTS profiles_update_own ON public.profiles;
CREATE POLICY profiles_update_own ON public.profiles
FOR UPDATE
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

-- STEP 3: categories table
CREATE TABLE IF NOT EXISTS public.categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('income', 'expense')),
  icon TEXT,
  color TEXT,
  is_system BOOLEAN DEFAULT FALSE,
  parent_id UUID REFERENCES public.categories(id),
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Unique index to prevent duplicate system seed entries
CREATE UNIQUE INDEX IF NOT EXISTS categories_system_name_type_idx ON public.categories (name, type, is_system);

-- Enable RLS and policy for categories: system categories visible to authenticated users
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS categories_select_system_or_owner ON public.categories;
CREATE POLICY categories_select_system_or_owner ON public.categories
FOR SELECT
USING (is_system = TRUE OR user_id = auth.uid());

-- Seed system categories (idempotent)
INSERT INTO public.categories (name, type, is_system, created_at) VALUES
('Makan & Minum', 'expense', TRUE, NOW()),
('Transportasi', 'expense', TRUE, NOW()),
('Belanja', 'expense', TRUE, NOW()),
('Tagihan', 'expense', TRUE, NOW()),
('Kesehatan', 'expense', TRUE, NOW()),
('Hiburan', 'expense', TRUE, NOW()),
('Pendidikan', 'expense', TRUE, NOW()),
('Lainnya', 'expense', TRUE, NOW()),
('Gaji', 'income', TRUE, NOW()),
('Freelance', 'income', TRUE, NOW()),
('Bonus', 'income', TRUE, NOW()),
('Hadiah', 'income', TRUE, NOW()),
('Jualan', 'income', TRUE, NOW()),
('Lainnya', 'income', TRUE, NOW())
ON CONFLICT (name, type, is_system) DO NOTHING;

-- STEP 4: transactions table
CREATE TABLE IF NOT EXISTS public.transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  category_id UUID REFERENCES public.categories(id),
  type TEXT NOT NULL CHECK (type IN ('income', 'expense')),
  amount NUMERIC(15,2) NOT NULL CHECK (amount > 0),
  currency TEXT NOT NULL DEFAULT 'IDR',
  note TEXT,
  date DATE NOT NULL,
  time TIME,
  is_deleted BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_transactions_user_date ON public.transactions (user_id, date DESC);
CREATE INDEX IF NOT EXISTS idx_transactions_category ON public.transactions (category_id);
CREATE INDEX IF NOT EXISTS idx_transactions_user_type ON public.transactions (user_id, type);

-- updated_at trigger for transactions
DROP TRIGGER IF EXISTS set_transactions_updated_at ON public.transactions;
CREATE TRIGGER set_transactions_updated_at
BEFORE UPDATE ON public.transactions
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

-- Enable RLS and explicit policies for transactions
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS transactions_select_own ON public.transactions;
CREATE POLICY transactions_select_own ON public.transactions
FOR SELECT
USING (auth.uid() = user_id);

DROP POLICY IF EXISTS transactions_insert_own ON public.transactions;
CREATE POLICY transactions_insert_own ON public.transactions
FOR INSERT
WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS transactions_update_own ON public.transactions;
CREATE POLICY transactions_update_own ON public.transactions
FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS transactions_delete_own ON public.transactions;
CREATE POLICY transactions_delete_own ON public.transactions
FOR DELETE
USING (auth.uid() = user_id);

-- STEP 5: verification notices (optional)
DO $$
DECLARE
  tbl_count INT;
  cat_exp INT;
  cat_inc INT;
  cat_total INT;
  rls_profiles BOOL;
  rls_categories BOOL;
  rls_transactions BOOL;
  rec RECORD;
BEGIN
  SELECT count(*) INTO tbl_count FROM pg_tables WHERE schemaname='public' AND tablename IN ('profiles','categories','transactions');
  RAISE NOTICE 'tables_found: %', tbl_count;

  SELECT count(*) INTO cat_exp FROM public.categories WHERE is_system = TRUE AND type = 'expense';
  SELECT count(*) INTO cat_inc FROM public.categories WHERE is_system = TRUE AND type = 'income';
  cat_total := cat_exp + cat_inc;
  RAISE NOTICE 'system_categories_total=% expense=% income=%', cat_total, cat_exp, cat_inc;

  SELECT relrowsecurity INTO rls_profiles FROM pg_class WHERE oid = 'public.profiles'::regclass;
  SELECT relrowsecurity INTO rls_categories FROM pg_class WHERE oid = 'public.categories'::regclass;
  SELECT relrowsecurity INTO rls_transactions FROM pg_class WHERE oid = 'public.transactions'::regclass;
  RAISE NOTICE 'rls_profiles=% rls_categories=% rls_transactions=%', rls_profiles, rls_categories, rls_transactions;

  FOR rec IN SELECT policyname, tablename, qual, with_check FROM pg_policies WHERE schemaname='public' AND tablename IN ('profiles','categories','transactions') ORDER BY tablename, policyname LOOP
    RAISE NOTICE 'policy % on %: qual=% with_check=%', rec.policyname, rec.tablename, rec.qual, rec.with_check;
  END LOOP;
END;
$$ LANGUAGE plpgsql;
