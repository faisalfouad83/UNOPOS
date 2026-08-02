-- =============================================================================
-- UNOPOS — Phase H2: Core Business Operations (schema additions + RPCs)
-- =============================================================================
-- Adds what Phase H1's schema was missing to support the 8 remaining
-- repositories: a safe per-store sale-number counter, indexes on FK columns
-- that now cross the network instead of hitting an in-process SQLite file,
-- a low-stock view, and every "atomic primitive" RPC — the Postgres
-- equivalent of the Drift `_db.transaction()` blocks in the original app,
-- plus a couple of read-then-write sequences (reduce_debt_original_amount)
-- that were NOT atomic in the Drift version but need to be under concurrent
-- Postgres writers.
--
-- Also fixes a bug in 0001: register_store() seeded only 9 Chart-of-Accounts
-- rows; the app's real default list (kDefaultChartOfAccounts in
-- lib/core/constants/default_chart_of_accounts.dart) has 19, and
-- AccountingPostingService posts directly to several of the missing ones
-- (bank, vatPayable, discountsGiven, shrinkageExpense, ...). Left unfixed,
-- a real store's first card sale or taxed sale would fail. Fixed here via
-- `create or replace function` rather than editing 0001 — once a migration
-- has shipped it's never edited, only superseded.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Schema additions
-- -----------------------------------------------------------------------------

alter table stores add column last_sale_seq bigint not null default 0;

create index sale_lines_sale_id_idx on sale_lines (sale_id);
create index journal_lines_journal_entry_id_idx on journal_lines (journal_entry_id);
create index stock_transfer_lines_transfer_id_idx on stock_transfer_lines (stock_transfer_id);
create index purchase_order_lines_po_id_idx on purchase_order_lines (purchase_order_id);
create index debt_payments_entry_id_idx on debt_payments (debt_ledger_entry_id);
create index supplier_transactions_supplier_id_idx on supplier_transactions (supplier_id);

-- quantity_on_hand <= reorder_level is a column-to-column comparison, which
-- PostgREST filters can't express directly — a view lets watchLowStock's
-- Supabase implementation query it as an ordinary table. No SECURITY
-- DEFINER involved, so RLS on the underlying tables still applies to
-- whichever role queries this view (the Supabase default for plain views).
create view low_stock_items as
  select p.*, s.quantity_on_hand, s.branch_id
  from products p
  join stock_items s on s.product_id = p.id
  where s.quantity_on_hand <= p.reorder_level and p.is_active;

-- -----------------------------------------------------------------------------
-- register_store() — redefined with the correct 19-account seed list,
-- byte-for-byte matching kDefaultChartOfAccounts. Everything else about the
-- function (store/branch/settings creation) is unchanged from 0001.
-- -----------------------------------------------------------------------------

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
  v_branch_id text;
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

  insert into branches (store_id, name, is_main_branch, is_active)
  values (v_store.id, p_display_name, true, true)
  returning id into v_branch_id;

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

-- -----------------------------------------------------------------------------
-- Sale numbering — replaces the racy client-side "count(*) then format"
-- scheme with a real atomic counter. The UPDATE's row lock on the store row
-- serializes concurrent callers automatically, so duplicates are impossible
-- (gaps on a failed/aborted transaction are fine and expected).
-- -----------------------------------------------------------------------------

create or replace function next_sale_number()
returns text
language plpgsql
security definer
set search_path = public
as $$
declare
  v_store_id text := current_store_id();
  v_seq bigint;
begin
  if v_store_id is null then
    raise exception 'must be signed in as a store to generate a sale number';
  end if;

  update stores set last_sale_seq = last_sale_seq + 1 where id = v_store_id returning last_sale_seq into v_seq;
  return 'S-' || lpad(v_seq::text, 6, '0');
end;
$$;

-- -----------------------------------------------------------------------------
-- Stock movement — the core atomic primitive every stock-affecting write
-- funnels through. Upserts stock_items via ON CONFLICT so the read-modify-
-- write is a single atomic statement (no lost updates under concurrent
-- callers, unlike the original read-then-write Drift version — a non-issue
-- with SQLite's single writer, a real one with multiple Postgres clients).
-- -----------------------------------------------------------------------------

create or replace function record_stock_movement(
  p_product_id text,
  p_branch_id text,
  p_type text,
  p_quantity bigint,
  p_unit_cost_minor_units bigint default 0,
  p_reference_type text default null,
  p_reference_id text default null,
  p_created_by_user_id text default null
)
returns bigint
language plpgsql
security definer
set search_path = public
as $$
declare
  v_store_id text := current_store_id();
  v_signed bigint;
  v_new_qty bigint;
begin
  if v_store_id is null then
    raise exception 'must be signed in as a store to record a stock movement';
  end if;

  v_signed := case when p_type in ('purchaseIn', 'transferIn', 'adjustmentIn', 'returnIn') then p_quantity else -p_quantity end;

  insert into stock_items (id, store_id, product_id, branch_id, quantity_on_hand)
  values (gen_random_uuid()::text, v_store_id, p_product_id, p_branch_id, v_signed)
  on conflict (product_id, branch_id)
  do update set quantity_on_hand = stock_items.quantity_on_hand + excluded.quantity_on_hand
  returning quantity_on_hand into v_new_qty;

  insert into stock_movements (id, store_id, product_id, branch_id, type, quantity, unit_cost_minor_units, reference_type, reference_id, created_by_user_id, created_at)
  values (gen_random_uuid()::text, v_store_id, p_product_id, p_branch_id, p_type, p_quantity, p_unit_cost_minor_units, p_reference_type, p_reference_id, p_created_by_user_id, now());

  return v_new_qty;
end;
$$;

-- -----------------------------------------------------------------------------
-- Stock transfer / purchase order receiving — each was TWO+ separate,
-- non-atomically-committed statements in the Drift version (a crash mid-loop
-- could leave partial stock movements with the header stuck 'pending').
-- As a single Postgres function call, the whole thing is now genuinely one
-- transaction: it all commits together or none of it does.
-- -----------------------------------------------------------------------------

create or replace function receive_stock_transfer(p_transfer_id text, p_received_by_user_id text)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_store_id text := current_store_id();
  v_transfer stock_transfers;
  v_line record;
begin
  if v_store_id is null then
    raise exception 'must be signed in as a store to receive a stock transfer';
  end if;

  select * into v_transfer from stock_transfers where id = p_transfer_id and store_id = v_store_id;
  if v_transfer.id is null then
    raise exception 'stock transfer not found';
  end if;

  for v_line in select * from stock_transfer_lines where stock_transfer_id = p_transfer_id loop
    perform record_stock_movement(v_line.product_id, v_transfer.from_branch_id, 'transferOut', v_line.quantity, 0, 'STOCK_TRANSFER', p_transfer_id, p_received_by_user_id);
    perform record_stock_movement(v_line.product_id, v_transfer.to_branch_id, 'transferIn', v_line.quantity, 0, 'STOCK_TRANSFER', p_transfer_id, p_received_by_user_id);
  end loop;

  update stock_transfers set status = 'received', received_by_user_id = p_received_by_user_id, received_at = now() where id = p_transfer_id;
end;
$$;

create or replace function receive_purchase_order(p_purchase_order_id text, p_received_by_user_id text)
returns bigint
language plpgsql
security definer
set search_path = public
as $$
declare
  v_store_id text := current_store_id();
  v_po purchase_orders;
  v_line record;
begin
  if v_store_id is null then
    raise exception 'must be signed in as a store to receive a purchase order';
  end if;

  select * into v_po from purchase_orders where id = p_purchase_order_id and store_id = v_store_id;
  if v_po.id is null then
    raise exception 'purchase order not found';
  end if;

  for v_line in select * from purchase_order_lines where purchase_order_id = p_purchase_order_id loop
    perform record_stock_movement(v_line.product_id, v_po.branch_id, 'purchaseIn', v_line.quantity_ordered, v_line.unit_cost_minor_units, 'PURCHASE_ORDER', p_purchase_order_id, p_received_by_user_id);
    update purchase_order_lines set quantity_received = v_line.quantity_ordered where id = v_line.id;
  end loop;

  update purchase_orders set status = 'received' where id = p_purchase_order_id;

  return v_po.total_cost_minor_units;
end;
$$;

-- -----------------------------------------------------------------------------
-- Double-entry posting primitive — the ONLY way journal_entries/journal_lines
-- get written, mirroring AccountingRepository.postJournalEntry's validation
-- exactly (>=2 lines, each line debit XOR credit, sum(debit)=sum(credit),
-- every account code must exist in this store's chart of accounts).
-- p_lines shape: [{"account_code": "...", "debit_minor_units": n,
-- "credit_minor_units": n, "description": "..."}, ...]
-- -----------------------------------------------------------------------------

create or replace function post_journal_entry(
  p_branch_id text,
  p_reference_type text,
  p_reference_id text default null,
  p_memo text default '',
  p_created_by_user_id text default null,
  p_lines jsonb default '[]'::jsonb,
  p_entry_date timestamptz default null
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_store_id text := current_store_id();
  v_entry_id text := gen_random_uuid()::text;
  v_now timestamptz := now();
  v_date timestamptz := coalesce(p_entry_date, v_now);
  v_line jsonb;
  v_debit_total bigint := 0;
  v_credit_total bigint := 0;
  v_debit bigint;
  v_credit bigint;
  v_account_id text;
  v_line_id text;
  v_lines_out jsonb := '[]'::jsonb;
begin
  if v_store_id is null then
    raise exception 'must be signed in as a store to post a journal entry';
  end if;

  if p_lines is null or jsonb_array_length(p_lines) < 2 then
    raise exception 'a journal entry needs at least two lines';
  end if;

  for v_line in select * from jsonb_array_elements(p_lines) loop
    v_debit := coalesce((v_line->>'debit_minor_units')::bigint, 0);
    v_credit := coalesce((v_line->>'credit_minor_units')::bigint, 0);
    if (v_debit > 0) = (v_credit > 0) then
      raise exception 'each journal line must be either a debit or a credit, never both/neither (account %)', v_line->>'account_code';
    end if;
    v_debit_total := v_debit_total + v_debit;
    v_credit_total := v_credit_total + v_credit;
  end loop;

  if v_debit_total <> v_credit_total then
    raise exception 'journal entry does not balance: debits=% credits=%', v_debit_total, v_credit_total;
  end if;

  insert into journal_entries (id, store_id, branch_id, entry_date, reference_type, reference_id, memo, created_by_user_id, created_at)
  values (v_entry_id, v_store_id, p_branch_id, v_date, p_reference_type, p_reference_id, coalesce(p_memo, ''), p_created_by_user_id, v_now);

  for v_line in select * from jsonb_array_elements(p_lines) loop
    select id into v_account_id from chart_of_accounts where store_id = v_store_id and code = v_line->>'account_code';
    if v_account_id is null then
      raise exception 'unknown chart-of-accounts code: %', v_line->>'account_code';
    end if;

    v_line_id := gen_random_uuid()::text;
    insert into journal_lines (id, store_id, journal_entry_id, account_id, debit_minor_units, credit_minor_units, description)
    values (
      v_line_id, v_store_id, v_entry_id, v_account_id,
      coalesce((v_line->>'debit_minor_units')::bigint, 0),
      coalesce((v_line->>'credit_minor_units')::bigint, 0),
      coalesce(v_line->>'description', '')
    );

    v_lines_out := v_lines_out || jsonb_build_object(
      'id', v_line_id,
      'account_id', v_account_id,
      'account_code', v_line->>'account_code',
      'debit_minor_units', coalesce((v_line->>'debit_minor_units')::bigint, 0),
      'credit_minor_units', coalesce((v_line->>'credit_minor_units')::bigint, 0),
      'description', coalesce(v_line->>'description', '')
    );
  end loop;

  return jsonb_build_object(
    'id', v_entry_id, 'store_id', v_store_id, 'branch_id', p_branch_id, 'entry_date', v_date,
    'reference_type', p_reference_type, 'reference_id', p_reference_id, 'memo', coalesce(p_memo, ''),
    'created_by_user_id', p_created_by_user_id, 'is_reversal', false, 'reversal_of_entry_id', null,
    'created_at', v_now, 'lines', v_lines_out
  );
end;
$$;

create or replace function post_reversing_entry(
  p_original_entry_id text,
  p_created_by_user_id text,
  p_memo text default 'Reversal'
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_store_id text := current_store_id();
  v_original journal_entries;
  v_entry_id text := gen_random_uuid()::text;
  v_now timestamptz := now();
  v_line record;
  v_line_id text;
  v_lines_out jsonb := '[]'::jsonb;
begin
  if v_store_id is null then
    raise exception 'must be signed in as a store to post a reversing entry';
  end if;

  select * into v_original from journal_entries where id = p_original_entry_id and store_id = v_store_id;
  if v_original.id is null then
    raise exception 'journal entry not found';
  end if;

  insert into journal_entries (id, store_id, branch_id, entry_date, reference_type, reference_id, memo, created_by_user_id, is_reversal, reversal_of_entry_id, created_at)
  values (v_entry_id, v_store_id, v_original.branch_id, v_now, v_original.reference_type, v_original.reference_id, coalesce(p_memo, 'Reversal'), p_created_by_user_id, true, p_original_entry_id, v_now);

  for v_line in
    select jl.*, coa.code as account_code
    from journal_lines jl
    join chart_of_accounts coa on coa.id = jl.account_id
    where jl.journal_entry_id = p_original_entry_id
  loop
    v_line_id := gen_random_uuid()::text;
    insert into journal_lines (id, store_id, journal_entry_id, account_id, debit_minor_units, credit_minor_units, description)
    values (v_line_id, v_store_id, v_entry_id, v_line.account_id, v_line.credit_minor_units, v_line.debit_minor_units, v_line.description);

    v_lines_out := v_lines_out || jsonb_build_object(
      'id', v_line_id, 'account_id', v_line.account_id, 'account_code', v_line.account_code,
      'debit_minor_units', v_line.credit_minor_units, 'credit_minor_units', v_line.debit_minor_units,
      'description', v_line.description
    );
  end loop;

  return jsonb_build_object(
    'id', v_entry_id, 'store_id', v_store_id, 'branch_id', v_original.branch_id, 'entry_date', v_now,
    'reference_type', v_original.reference_type, 'reference_id', v_original.reference_id, 'memo', coalesce(p_memo, 'Reversal'),
    'created_by_user_id', p_created_by_user_id, 'is_reversal', true, 'reversal_of_entry_id', p_original_entry_id,
    'created_at', v_now, 'lines', v_lines_out
  );
end;
$$;

-- Account code -> net balance in minor units (debits-credits for
-- asset/expense/cogs, credits-debits for liability/equity/revenue),
-- replacing a client-side pull-everything-then-aggregate-in-Dart pattern
-- with one GROUP BY.
create or replace function trial_balance(p_as_of timestamptz default null)
returns table(account_code text, balance_minor_units bigint)
language sql
stable
security definer
set search_path = public
as $$
  select
    coa.code,
    case when coa.type in ('asset', 'expense', 'cogs')
         then sum(jl.debit_minor_units) - sum(jl.credit_minor_units)
         else sum(jl.credit_minor_units) - sum(jl.debit_minor_units) end
  from journal_lines jl
  join journal_entries je on je.id = jl.journal_entry_id
  join chart_of_accounts coa on coa.id = jl.account_id
  where jl.store_id = current_store_id()
    and (p_as_of is null or je.entry_date <= p_as_of)
  group by coa.code;
$$;

-- -----------------------------------------------------------------------------
-- Debts — recordPayment was already atomic (a Drift transaction);
-- reduceOriginalAmount was NOT (a separate read then a separate write) and
-- shared the exact same status-derivation logic duplicated verbatim in the
-- Drift source. Both become row-locked (`for update`) single function calls
-- here, closing the race the Drift version had under concurrent writers.
-- -----------------------------------------------------------------------------

create or replace function record_debt_payment(
  p_debt_ledger_entry_id text,
  p_amount_minor_units bigint,
  p_payment_method text,
  p_received_by_user_id text
)
returns text
language plpgsql
security definer
set search_path = public
as $$
declare
  v_store_id text := current_store_id();
  v_entry debt_ledger_entries;
  v_payment_id text := gen_random_uuid()::text;
  v_new_paid bigint;
  v_new_status text;
begin
  if v_store_id is null then
    raise exception 'must be signed in as a store to record a debt payment';
  end if;

  select * into v_entry from debt_ledger_entries where id = p_debt_ledger_entry_id and store_id = v_store_id for update;
  if v_entry.id is null then
    raise exception 'debt ledger entry not found';
  end if;

  insert into debt_payments (id, store_id, debt_ledger_entry_id, amount_minor_units, payment_method, received_by_user_id, paid_at)
  values (v_payment_id, v_store_id, p_debt_ledger_entry_id, p_amount_minor_units, p_payment_method, p_received_by_user_id, now());

  v_new_paid := v_entry.amount_paid_minor_units + p_amount_minor_units;
  v_new_status := case
    when v_new_paid >= v_entry.original_amount_minor_units then 'paid'
    when v_new_paid > 0 then 'partiallyPaid'
    else 'open' end;

  update debt_ledger_entries set amount_paid_minor_units = v_new_paid, status = v_new_status where id = p_debt_ledger_entry_id;

  return v_payment_id;
end;
$$;

create or replace function reduce_debt_original_amount(p_debt_ledger_entry_id text, p_reduce_by_minor_units bigint)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_store_id text := current_store_id();
  v_entry debt_ledger_entries;
  v_new_original bigint;
  v_new_status text;
begin
  if v_store_id is null then
    raise exception 'must be signed in as a store to adjust a debt entry';
  end if;

  select * into v_entry from debt_ledger_entries where id = p_debt_ledger_entry_id and store_id = v_store_id for update;
  if v_entry.id is null then
    raise exception 'debt ledger entry not found';
  end if;

  v_new_original := greatest(0, v_entry.original_amount_minor_units - p_reduce_by_minor_units);
  v_new_status := case
    when v_entry.amount_paid_minor_units >= v_new_original then 'paid'
    when v_entry.amount_paid_minor_units > 0 then 'partiallyPaid'
    else 'open' end;

  update debt_ledger_entries set original_amount_minor_units = v_new_original, status = v_new_status where id = p_debt_ledger_entry_id;
end;
$$;

-- -----------------------------------------------------------------------------
-- Suppliers — replaces a pull-every-transaction-then-sum-in-Dart pattern.
-- -----------------------------------------------------------------------------

create or replace function supplier_balance_owed(p_supplier_id text)
returns bigint
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(sum(amount_minor_units) filter (where type in ('purchase', 'adjustment')), 0)
       - coalesce(sum(amount_minor_units) filter (where type = 'payment'), 0)
  from supplier_transactions
  where supplier_id = p_supplier_id and store_id = current_store_id();
$$;
