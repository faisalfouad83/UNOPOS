-- =============================================================================
-- UNOPOS — Fix: RealtimeSubscribeException / "channelError" on every watch*()
-- =============================================================================
-- supabase_flutter's .stream() opens a Postgres logical-replication channel
-- via Supabase Realtime, which only broadcasts changes for tables explicitly
-- added to the `supabase_realtime` publication — a project starts with that
-- publication empty. None of the prior migrations added any table to it, so
-- every watch*() method in every *_repository_supabase.dart file (tile
-- picker, dashboard, inventory, POS, debts, suppliers, accounting, shifts,
-- settings, audit, developer console, notifications) was broken the same
-- way, not just the employee list. Idempotent: safe to run more than once.
-- =============================================================================

do $$
declare
  t text;
begin
  foreach t in array array[
    'users', 'stores', 'subscription_plans', 'platform_audit_logs', 'audit_logs',
    'shifts', 'notification_recipients', 'app_settings', 'journal_entries',
    'categories', 'tax_rates', 'products', 'stock_items', 'stock_transfers',
    'discounts', 'purchase_orders', 'suppliers', 'supplier_transactions',
    'customers', 'debt_ledger_entries', 'debt_payments', 'sales'
  ]
  loop
    if not exists (
      select 1 from pg_publication_tables
      where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = t
    ) then
      execute format('alter publication supabase_realtime add table public.%I', t);
    end if;
  end loop;
end $$;
