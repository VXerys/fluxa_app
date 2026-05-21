-- Migration: wallet table + transaction wallet link + wallet balance sync
-- Date: 2026-05-21
-- Idempotent migration for existing deployments

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- STEP 1: wallets table
CREATE TABLE IF NOT EXISTS public.wallets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  type TEXT NOT NULL CHECK (
    type IN ('cash', 'bank', 'ewallet', 'credit', 'savings', 'investment')
  ),
  balance NUMERIC(15, 2) NOT NULL DEFAULT 0,
  currency TEXT NOT NULL DEFAULT 'IDR',
  icon TEXT,
  color TEXT,
  is_archived BOOLEAN DEFAULT FALSE,
  include_in_total BOOLEAN DEFAULT TRUE,
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_wallets_user_archived
  ON public.wallets (user_id, is_archived, sort_order);

DROP TRIGGER IF EXISTS set_wallets_updated_at ON public.wallets;
CREATE TRIGGER set_wallets_updated_at
BEFORE UPDATE ON public.wallets
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

ALTER TABLE public.wallets ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS wallets_select_own ON public.wallets;
CREATE POLICY wallets_select_own ON public.wallets
FOR SELECT
USING (auth.uid() = user_id);

DROP POLICY IF EXISTS wallets_insert_own ON public.wallets;
CREATE POLICY wallets_insert_own ON public.wallets
FOR INSERT
WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS wallets_update_own ON public.wallets;
CREATE POLICY wallets_update_own ON public.wallets
FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS wallets_delete_own ON public.wallets;
CREATE POLICY wallets_delete_own ON public.wallets
FOR DELETE
USING (auth.uid() = user_id);

-- STEP 2: link transactions -> wallets
ALTER TABLE public.transactions
  ADD COLUMN IF NOT EXISTS wallet_id UUID REFERENCES public.wallets(id);

CREATE INDEX IF NOT EXISTS idx_transactions_wallet_id
  ON public.transactions (wallet_id);

-- STEP 3: categories delete policy for custom categories only
DROP POLICY IF EXISTS categories_delete_own_custom ON public.categories;
CREATE POLICY categories_delete_own_custom ON public.categories
FOR DELETE
USING (auth.uid() = user_id AND is_system = FALSE);

-- STEP 4: wallet balance sync helpers
CREATE OR REPLACE FUNCTION public.wallet_amount_delta(
  tx_type TEXT,
  tx_amount NUMERIC
) RETURNS NUMERIC AS $$
BEGIN
  IF tx_type = 'income' THEN
    RETURN COALESCE(tx_amount, 0);
  ELSIF tx_type = 'expense' THEN
    RETURN COALESCE(tx_amount, 0) * -1;
  END IF;
  RETURN 0;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

CREATE OR REPLACE FUNCTION public.sync_wallet_balance_from_transaction()
RETURNS TRIGGER AS $$
DECLARE
  old_delta NUMERIC := 0;
  new_delta NUMERIC := 0;
BEGIN
  IF TG_OP = 'INSERT' THEN
    IF NEW.wallet_id IS NOT NULL AND COALESCE(NEW.is_deleted, FALSE) = FALSE THEN
      UPDATE public.wallets
      SET balance = balance + public.wallet_amount_delta(NEW.type, NEW.amount)
      WHERE id = NEW.wallet_id;
    END IF;
    RETURN NEW;
  END IF;

  IF TG_OP = 'UPDATE' THEN
    IF OLD.wallet_id IS NOT NULL AND COALESCE(OLD.is_deleted, FALSE) = FALSE THEN
      old_delta := public.wallet_amount_delta(OLD.type, OLD.amount);
      UPDATE public.wallets
      SET balance = balance - old_delta
      WHERE id = OLD.wallet_id;
    END IF;

    IF NEW.wallet_id IS NOT NULL AND COALESCE(NEW.is_deleted, FALSE) = FALSE THEN
      new_delta := public.wallet_amount_delta(NEW.type, NEW.amount);
      UPDATE public.wallets
      SET balance = balance + new_delta
      WHERE id = NEW.wallet_id;
    END IF;

    RETURN NEW;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS sync_wallet_balance_on_transaction ON public.transactions;
CREATE TRIGGER sync_wallet_balance_on_transaction
AFTER INSERT OR UPDATE ON public.transactions
FOR EACH ROW
EXECUTE FUNCTION public.sync_wallet_balance_from_transaction();

-- STEP 5: backfill for existing transactions without wallet_id
DO $$
DECLARE
  rec RECORD;
  v_wallet_id UUID;
  v_balance NUMERIC;
BEGIN
  FOR rec IN
    SELECT t.user_id
    FROM public.transactions t
    WHERE t.wallet_id IS NULL
    GROUP BY t.user_id
  LOOP
    SELECT w.id
      INTO v_wallet_id
    FROM public.wallets w
    WHERE w.user_id = rec.user_id
      AND w.name = 'Cash (Migrasi)'
      AND w.type = 'cash'
      AND w.currency = 'IDR'
    ORDER BY w.created_at ASC
    LIMIT 1;

    IF v_wallet_id IS NULL THEN
      INSERT INTO public.wallets (
        user_id, name, type, balance, currency, include_in_total, sort_order
      )
      VALUES (
        rec.user_id, 'Cash (Migrasi)', 'cash', 0, 'IDR', TRUE, -1
      )
      RETURNING id INTO v_wallet_id;
    END IF;

    UPDATE public.transactions
    SET wallet_id = v_wallet_id
    WHERE user_id = rec.user_id
      AND wallet_id IS NULL;

    SELECT
      COALESCE(
        SUM(
          CASE
            WHEN is_deleted = FALSE AND type = 'income' THEN amount
            WHEN is_deleted = FALSE AND type = 'expense' THEN amount * -1
            ELSE 0
          END
        ),
        0
      )
      INTO v_balance
    FROM public.transactions
    WHERE user_id = rec.user_id
      AND wallet_id = v_wallet_id;

    UPDATE public.wallets
    SET balance = v_balance
    WHERE id = v_wallet_id;
  END LOOP;
END;
$$ LANGUAGE plpgsql;

