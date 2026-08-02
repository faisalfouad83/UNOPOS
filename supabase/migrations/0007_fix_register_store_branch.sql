-- =============================================================================
-- UNOPOS — Fix: register_store() double-created a branch
-- =============================================================================
-- register_store() (0002) auto-created one branch for every new store. But
-- the app's own onboarding flow (CreateManagerScreen) ALSO creates a branch
-- right after — a leftover from the local/Drift onboarding flow, where
-- register_store() doesn't exist and CreateManagerScreen is the only thing
-- that ever creates a branch. On Supabase this meant every new store ended
-- up with two branch-insert attempts, and the Starter plan's max_branches
-- limit (1) blocked the second one — the plan-limit trigger from
-- 0005_plan_limits.sql raised an exception that surfaced in the app as a
-- generic error on the PIN field during onboarding, easy to misread as
-- "wrong PIN" even though it had nothing to do with the PIN.
--
-- Fix: register_store() no longer creates a branch. Branch creation is
-- CreateManagerScreen's job alone, same as it always was on Drift.
-- =============================================================================

create or replace function register_store(
  p_store_login_id text,
  p_display_name text,
  p_owner_name text,
  p_phone text
)
returns stores
language plpgsql
security definer
set search_path = public
as $$
declare
  v_store stores;
begin
  if auth.uid() is null then
    raise exception 'must be signed in to register a store';
  end if;

  if exists (select 1 from stores where auth_user_id = auth.uid()) then
    raise exception 'this account already owns a store';
  end if;

  insert into stores (store_login_id, auth_user_id, display_name, owner_name, phone, plan_id, subscription_status, activation_status)
  values (p_store_login_id, auth.uid(), p_display_name, p_owner_name, p_phone, 'starter', 'trial', 'pending')
  returning * into v_store;

  insert into app_settings (id, store_id)
  values (v_store.id, v_store.id);

  -- Kept in sync with lib/core/constants/default_chart_of_accounts.dart —
  -- if that list changes, this must change with it.
  insert into chart_of_accounts (store_id, code, name, type, is_system_account) values
    (v_store.id, '1000', 'Cash on Hand',                     'asset',     true),
    (v_store.id, '1010', 'Bank Account',                     'asset',     true),
    (v_store.id, '1100', 'Accounts Receivable',               'asset',     true),
    (v_store.id, '1200', 'Inventory',                         'asset',     true),
    (v_store.id, '2000', 'Accounts Payable',                  'liability', true),
    (v_store.id, '2100', 'VAT / Sales Tax Payable',           'liability', true),
    (v_store.id, '3000', 'Owner''s Equity',                   'equity',    true),
    (v_store.id, '3100', 'Retained Earnings',                 'equity',    true),
    (v_store.id, '4000', 'Sales Revenue',                     'revenue',   true),
    (v_store.id, '4100', 'Sales Returns & Allowances',        'revenue',   true),
    (v_store.id, '4200', 'Discounts Given',                   'revenue',   true),
    (v_store.id, '5000', 'Cost of Goods Sold',                'cogs',      true),
    (v_store.id, '6000', 'Rent Expense',                      'expense',   true),
    (v_store.id, '6010', 'Utilities Expense',                 'expense',   true),
    (v_store.id, '6020', 'Salaries & Wages Expense',          'expense',   true),
    (v_store.id, '6030', 'Supplies Expense',                  'expense',   true),
    (v_store.id, '6040', 'General / Miscellaneous Expense',   'expense',   true),
    (v_store.id, '6050', 'Card Processing Fees',              'expense',   true),
    (v_store.id, '6060', 'Inventory Shrinkage Expense',       'expense',   true);

  return v_store;
end;
$$;
