# Supabase migrations — Basic MVP

This folder contains SQL to set up the Supabase database for Fluxa Basic MVP (tables: `profiles`, `categories`, `transactions`). The main migration file is:

- `supabase/migrations/20260519_create_basic_mvp.sql`

How to run

1) Supabase Dashboard (recommended)
   - Open your project at https://app.supabase.com
   - Go to **SQL Editor** → **New query**
   - Paste the contents of `supabase/migrations/20260519_create_basic_mvp.sql` and Run

2) psql (CLI)
   - Get the DB connection string from Project settings → Database (use SSL/require)
   - Run:

```bash
psql "<YOUR_DB_CONNECTION_STRING>" -f supabase/migrations/20260519_create_basic_mvp.sql
```

3) Docker (if you don't have psql locally)

```bash
docker run --rm -v "$(pwd)":/work -w /work postgres:15 psql "<YOUR_DB_CONNECTION_STRING>" -f supabase/migrations/20260519_create_basic_mvp.sql
```

Verification queries (after running)

```sql
-- 1) Ensure tables exist
SELECT tablename FROM pg_tables WHERE schemaname='public' AND tablename IN ('profiles','categories','transactions');

-- 2) Count system categories
SELECT type, count(*) FROM public.categories WHERE is_system = TRUE GROUP BY type;

-- 3) RLS status
SELECT c.relname, c.relrowsecurity
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname = 'public' AND c.relname IN ('profiles','categories','transactions');

-- 4) List policies
SELECT * FROM pg_policies WHERE schemaname = 'public' AND tablename IN ('profiles','categories','transactions') ORDER BY tablename, policyname;
```

Notes
- The migration is written to be idempotent (IF NOT EXISTS, DROP TRIGGER IF EXISTS, ON CONFLICT DO NOTHING).
- I attempted to apply the migration remotely but this agent environment is read-only for Supabase operations. If you want me to apply it directly, either enable write access for this MCP session or provide a secure DB connection for me to use (preferred: service_role via a secure mechanism). Otherwise please run the SQL above in the SQL editor and paste the verification output here — I will validate and iterate.
