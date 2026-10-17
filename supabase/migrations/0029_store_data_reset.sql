-- 0029: resetting a store's business data from the app (Settings → Reset
-- store data), all of it or one part, on the server, in one transaction.
--
-- What each part ("scope") removes. Invoices and sales are the same rows
-- here (`sales`), so there is one scope for both.
--
--   sales       every sale/invoice (held ones too) with its lines, returns
--               and return lines; the debts those invoices created (and the
--               payments on them); loyalty points earned or spent on them
--               (taken back off each customer's balance); and the journal
--               entries of all of these. Invoice numbers start again at 1.
--               Stock is NOT changed: quantities stay what they are now and
--               the stock history keeps its sale/return lines (the goods
--               really left the shelf).
--   debts       every customer debt and debt payment, with the payments'
--               journal entries. The receivable an invoice recorded stays
--               in that invoice's own journal entry (it belongs to the sale).
--   expenses    every expense (expense_details) with its journal entry, and
--               the reclassification entries made for it.
--   accounting  every journal entry and journal line (the books start at
--               zero). Expenses are journal entries in this schema, so they
--               go too. Sales, debts, stock and suppliers stay; their links
--               to the removed entries are cleared. The chart of accounts
--               is kept.
--   customers   every customer with their loyalty history and their debts
--               (a debt cannot exist without its customer: implies `debts`).
--               Kept sales lose their customer link.
--   inventory   every product, its stock (stock_items) and stock history,
--               categories, product/category discounts, purchase orders and
--               stock transfers (with their journal entries). Sale lines
--               refer to products, so this implies `sales`. Suppliers and
--               what is owed to them stay.
--   suppliers   every supplier, their transactions (purchases, payments)
--               and purchase orders, with the journal entries of these.
--   shifts      every closed shift and every finished break. Open shifts
--               and breaks in progress are kept (a till may be using them).
--               Kept sales lose their shift link.
--   full        all of the above, and every discount: the store is as new.
--
-- Always kept: the store itself (name, login, licence, plan, activation),
-- branches, employees and their PINs and devices, app settings, tax rates,
-- the chart of accounts, audit logs (the reset itself is logged), support
-- conversations, notifications and client_ops (the exactly-once record of
-- offline work, so an old queued operation can never run twice).
--
-- Books stay balanced: journal entries are only ever removed whole, lines
-- with their entry, and an entry goes together with every entry reversing
-- it.
--
-- Only the store owner may run it. The app asks for two confirmations and
-- takes (and checks) a full backup file first. It is online only: it is not
-- in run_client_op's list, so a queued offline operation can never run it.

create table if not exists store_resets (
  id               text primary key,
  store_id         text not null references stores (id) on delete cascade,
  -- 1 for the store's first reset, then 2, 3... Devices remember the last
  -- one they have seen and drop queued work for the reset parts made
  -- before it (so old offline changes cannot bring erased data back).
  generation       integer not null,
  scopes           text[] not null,
  requested_scopes text[] not null,
  actor_id         text,
  counts           jsonb not null default '{}'::jsonb,
  created_at       timestamptz not null default now(),
  unique (store_id, generation)
);

alter table store_resets enable row level security;

drop policy if exists "tenant select" on store_resets;
create policy "tenant select" on store_resets
  for select using (store_id = current_store_id());
-- No insert/update/delete policies: only reset_store_data writes here.

-- The parts a request really covers: `full` means every part, and a part
-- that cannot be removed without another brings it along (customers →
-- debts, inventory → sales, accounting → expenses). Unknown names are
-- refused.
create or replace function store_reset_scopes(p_scopes text[])
returns text[]
language plpgsql
immutable
set search_path = public
as $$
declare
  v_known constant text[] := array['sales', 'debts', 'expenses', 'accounting', 'customers', 'inventory', 'suppliers', 'shifts', 'full'];
  v text[] := coalesce(p_scopes, '{}'::text[]);
  s text;
begin
  foreach s in array v loop
    if s is null or not (s = any (v_known)) then
      raise exception 'unknown reset scope: %', coalesce(s, 'null');
    end if;
  end loop;
  if 'full' = any (v) then
    v := v_known;
  end if;
  if 'customers' = any (v) then v := v || 'debts'::text; end if;
  if 'inventory' = any (v) then v := v || 'sales'::text; end if;
  if 'accounting' = any (v) then v := v || 'expenses'::text; end if;
  return array(
    select k from unnest(v_known) with ordinality as t (k, i)
    where k = any (v)
    order by i
  );
end;
$$;

grant execute on function store_reset_scopes(text[]) to authenticated;

create or replace function store_reset_add_count(p_counts jsonb, p_key text, p_n bigint)
returns jsonb
language sql
immutable
set search_path = public
as $$
  select jsonb_set(p_counts, array[p_key], to_jsonb(coalesce((p_counts ->> p_key)::bigint, 0) + coalesce(p_n, 0)));
$$;

-- Removes the rows of [p_scopes] (already expanded by store_reset_scopes)
-- for store [p_store] and returns how many rows went from each table.
-- Internal: called only by reset_store_data and store_reset_preview,
-- which check who is asking.
create or replace function store_reset_apply(p_store text, p_scopes text[])
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  f_sales      boolean := 'sales' = any (p_scopes);
  f_debts      boolean := 'debts' = any (p_scopes);
  f_expenses   boolean := 'expenses' = any (p_scopes);
  f_accounting boolean := 'accounting' = any (p_scopes);
  f_customers  boolean := 'customers' = any (p_scopes);
  f_inventory  boolean := 'inventory' = any (p_scopes);
  f_suppliers  boolean := 'suppliers' = any (p_scopes);
  f_shifts     boolean := 'shifts' = any (p_scopes);
  f_full       boolean := 'full' = any (p_scopes);
  c   jsonb := '{}'::jsonb;
  n   bigint;
  v_je   text[] := '{}'::text[];
  v_exp  text[];
  v_more text[];
begin
  if p_store is null then
    raise exception 'no store';
  end if;

  -- 1. The journal entries that belong to what is being removed (worked
  --    out first, while the records that point at them still exist).
  if f_accounting then
    v_je := array(select id from journal_entries where store_id = p_store);
  else
    if f_sales then
      v_je := v_je
        || array(select id from journal_entries where store_id = p_store and reference_type in ('SALE', 'RETURN'))
        || array(select journal_entry_id from sales where store_id = p_store and journal_entry_id is not null)
        || array(select journal_entry_id from sale_returns where store_id = p_store and journal_entry_id is not null);
    end if;
    if f_debts or f_sales then
      -- Payments on the debts being removed: all of them, or (sales only)
      -- those on debts that invoices created.
      v_je := v_je
        || array(
          select p.journal_entry_id
          from debt_payments p join debt_ledger_entries d on d.id = p.debt_ledger_entry_id
          where d.store_id = p_store and p.journal_entry_id is not null and (f_debts or d.sale_id is not null))
        || array(
          select j.id
          from journal_entries j
          join debt_payments p on p.id = j.reference_id
          join debt_ledger_entries d on d.id = p.debt_ledger_entry_id
          where j.store_id = p_store and j.reference_type = 'DEBT_PAYMENT' and (f_debts or d.sale_id is not null));
    end if;
    if f_debts then
      v_je := v_je
        || array(select id from journal_entries where store_id = p_store and reference_type = 'DEBT_PAYMENT')
        -- A debt not made by an invoice owns its entry; an invoice's debt
        -- points at the invoice's entry, which stays with the invoice.
        || array(select journal_entry_id from debt_ledger_entries
                 where store_id = p_store and sale_id is null and journal_entry_id is not null);
    end if;
    if f_expenses then
      v_exp := array(select id from journal_entries where store_id = p_store and reference_type = 'EXPENSE')
        || array(select journal_entry_id from expense_details where store_id = p_store);
      v_je := v_je || v_exp
        || array(select j.id from journal_entries j join unnest(v_exp) as x (id) on j.reference_id = x.id
                 where j.store_id = p_store and j.reference_type = 'ADJUSTMENT');
    end if;
    if f_suppliers or f_inventory then
      -- Purchase orders go with either part.
      v_je := v_je
        || array(select j.id from journal_entries j join purchase_orders po on po.id = j.reference_id
                 where j.store_id = p_store and po.store_id = p_store and j.reference_type = 'PURCHASE');
    end if;
    if f_suppliers then
      v_je := v_je
        || array(select id from journal_entries where store_id = p_store and reference_type in ('PURCHASE', 'SUPPLIER_PAYMENT'))
        || array(select journal_entry_id from supplier_transactions where store_id = p_store and journal_entry_id is not null);
    end if;
    if f_inventory then
      -- Stock write-offs are posted against the stock movement.
      v_je := v_je
        || array(select j.id from journal_entries j join stock_movements m on m.id = j.reference_id
                 where j.store_id = p_store and m.store_id = p_store and j.reference_type = 'ADJUSTMENT');
    end if;

    v_je := array(select distinct x from unnest(v_je) as x where x is not null);
    -- An entry goes with every entry reversing it (and those reversing
    -- them), so no reversal is left without its original.
    loop
      v_more := array(
        select j.id from journal_entries j
        where j.store_id = p_store and j.reversal_of_entry_id in (select unnest(v_je))
        except
        select unnest(v_je));
      exit when coalesce(cardinality(v_more), 0) = 0;
      v_je := v_je || v_more;
    end loop;
  end if;

  -- 2. Loyalty points.
  if f_customers then
    delete from loyalty_transactions where store_id = p_store;
    get diagnostics n = row_count; c := store_reset_add_count(c, 'loyalty_transactions', n);
  elsif f_sales then
    -- Points earned or spent on removed invoices come off the balance.
    update customers cu set loyalty_points = greatest(0, cu.loyalty_points - t.points)
    from (
      select customer_id, sum(points) as points from loyalty_transactions
      where store_id = p_store and sale_id is not null group by customer_id
    ) t
    where cu.id = t.customer_id and cu.store_id = p_store and t.points <> 0;
    get diagnostics n = row_count; c := store_reset_add_count(c, 'customers_points_adjusted', n);
    delete from loyalty_transactions where store_id = p_store and sale_id is not null;
    get diagnostics n = row_count; c := store_reset_add_count(c, 'loyalty_transactions', n);
  end if;

  -- 3. Debts.
  if f_debts then
    delete from debt_payments where store_id = p_store;
    get diagnostics n = row_count; c := store_reset_add_count(c, 'debt_payments', n);
    delete from debt_ledger_entries where store_id = p_store;
    get diagnostics n = row_count; c := store_reset_add_count(c, 'debt_ledger_entries', n);
  elsif f_sales then
    delete from debt_payments p using debt_ledger_entries d
    where p.debt_ledger_entry_id = d.id and d.store_id = p_store and p.store_id = p_store and d.sale_id is not null;
    get diagnostics n = row_count; c := store_reset_add_count(c, 'debt_payments', n);
    delete from debt_ledger_entries where store_id = p_store and sale_id is not null;
    get diagnostics n = row_count; c := store_reset_add_count(c, 'debt_ledger_entries', n);
  end if;

  -- 4. Sales / invoices.
  if f_sales then
    delete from sale_return_lines where store_id = p_store;
    get diagnostics n = row_count; c := store_reset_add_count(c, 'sale_return_lines', n);
    delete from sale_returns where store_id = p_store;
    get diagnostics n = row_count; c := store_reset_add_count(c, 'sale_returns', n);
    delete from sale_lines where store_id = p_store;
    get diagnostics n = row_count; c := store_reset_add_count(c, 'sale_lines', n);
    delete from sales where store_id = p_store;
    get diagnostics n = row_count; c := store_reset_add_count(c, 'sales', n);
    update stores set last_sale_seq = 0 where id = p_store;
  end if;

  -- 5. Customers.
  if f_customers then
    if not f_sales then
      update sales set customer_id = null where store_id = p_store and customer_id is not null;
      get diagnostics n = row_count; c := store_reset_add_count(c, 'sales_unlinked_from_customers', n);
    end if;
    delete from customers where store_id = p_store;
    get diagnostics n = row_count; c := store_reset_add_count(c, 'customers', n);
  end if;

  -- 6. Suppliers, purchase orders, stock transfers, products.
  if f_suppliers then
    delete from supplier_transactions where store_id = p_store;
    get diagnostics n = row_count; c := store_reset_add_count(c, 'supplier_transactions', n);
  end if;
  if f_suppliers or f_inventory then
    delete from purchase_order_lines where store_id = p_store;
    get diagnostics n = row_count; c := store_reset_add_count(c, 'purchase_order_lines', n);
    delete from purchase_orders where store_id = p_store;
    get diagnostics n = row_count; c := store_reset_add_count(c, 'purchase_orders', n);
  end if;
  if f_suppliers then
    delete from suppliers where store_id = p_store;
    get diagnostics n = row_count; c := store_reset_add_count(c, 'suppliers', n);
  end if;
  if f_inventory then
    delete from stock_transfer_lines where store_id = p_store;
    get diagnostics n = row_count; c := store_reset_add_count(c, 'stock_transfer_lines', n);
    delete from stock_transfers where store_id = p_store;
    get diagnostics n = row_count; c := store_reset_add_count(c, 'stock_transfers', n);
    if f_full then
      delete from discounts where store_id = p_store;
    else
      delete from discounts where store_id = p_store and applied_scope in ('product', 'category');
    end if;
    get diagnostics n = row_count; c := store_reset_add_count(c, 'discounts', n);
    delete from stock_movements where store_id = p_store;
    get diagnostics n = row_count; c := store_reset_add_count(c, 'stock_movements', n);
    delete from stock_items where store_id = p_store;
    get diagnostics n = row_count; c := store_reset_add_count(c, 'stock_items', n);
    delete from products where store_id = p_store;
    get diagnostics n = row_count; c := store_reset_add_count(c, 'products', n);
    delete from categories where store_id = p_store;
    get diagnostics n = row_count; c := store_reset_add_count(c, 'categories', n);
  end if;

  -- 7. Shifts and breaks (open ones are kept).
  if f_shifts then
    delete from employee_breaks where store_id = p_store and ended_at is not null;
    get diagnostics n = row_count; c := store_reset_add_count(c, 'employee_breaks', n);
    delete from shifts where store_id = p_store and status = 'closed';
    get diagnostics n = row_count; c := store_reset_add_count(c, 'shifts', n);
  end if;

  -- 8. The journal entries, whole: expense details and lines with them.
  if cardinality(v_je) > 0 then
    delete from expense_details e using (select distinct unnest(v_je) as id) x
    where e.journal_entry_id = x.id and e.store_id = p_store;
    get diagnostics n = row_count; c := store_reset_add_count(c, 'expense_details', n);
    delete from journal_lines l using (select distinct unnest(v_je) as id) x
    where l.journal_entry_id = x.id and l.store_id = p_store;
    get diagnostics n = row_count; c := store_reset_add_count(c, 'journal_lines', n);
    delete from journal_entries j using (select distinct unnest(v_je) as id) x
    where j.id = x.id and j.store_id = p_store;
    get diagnostics n = row_count; c := store_reset_add_count(c, 'journal_entries', n);
  end if;

  return c;
end;
$$;

revoke execute on function store_reset_apply(text, text[]) from public, anon, authenticated;
revoke execute on function store_reset_add_count(jsonb, text, bigint) from public, anon, authenticated;

-- Resets the signed-in store's data for [p_scopes], once per [p_reset_id]:
-- asking again with the same id (the reply was lost, the app closed
-- midway) does nothing more and returns the first result
-- (`duplicate: true`). [p_actor_id] is the employee asking; it must be the
-- store's active owner. Returns {reset_id, generation, scopes, counts,
-- created_at, duplicate}.
create or replace function reset_store_data(p_reset_id text, p_scopes text[], p_actor_id text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_store  text := current_store_id();
  v_prev   store_resets;
  v_actor  users;
  v_scopes text[];
  v_counts jsonb;
  v_gen    integer;
  v_at     timestamptz := now();
begin
  if v_store is null then
    raise exception 'must be signed in as a store';
  end if;
  if coalesce(p_reset_id, '') = '' then
    raise exception 'reset id required';
  end if;
  v_scopes := store_reset_scopes(p_scopes);
  if coalesce(cardinality(v_scopes), 0) = 0 then
    raise exception 'choose what to reset';
  end if;

  -- One reset at a time per store, and no sale in between: checkouts
  -- update this row too, so they wait for the reset to finish.
  perform 1 from stores where id = v_store for update;

  select * into v_prev from store_resets where id = p_reset_id;
  if v_prev.id is not null then
    if v_prev.store_id <> v_store then
      raise exception 'reset id already used';
    end if;
    return jsonb_build_object(
      'reset_id', v_prev.id, 'generation', v_prev.generation, 'scopes', to_jsonb(v_prev.scopes),
      'counts', v_prev.counts, 'created_at', v_prev.created_at, 'duplicate', true);
  end if;

  select * into v_actor from users where id = p_actor_id and store_id = v_store and is_active;
  if v_actor.id is null or v_actor.role <> 'owner' then
    raise exception 'only the store owner can reset store data';
  end if;

  v_counts := store_reset_apply(v_store, v_scopes);

  select coalesce(max(generation), 0) + 1 into v_gen from store_resets where store_id = v_store;
  insert into store_resets (id, store_id, generation, scopes, requested_scopes, actor_id, counts, created_at)
  values (p_reset_id, v_store, v_gen, v_scopes, coalesce(p_scopes, '{}'::text[]), v_actor.id, v_counts, v_at);

  insert into audit_logs (store_id, user_id, action, entity_type, entity_id, before_value_json, after_value_json)
  values (v_store, v_actor.id, 'store.reset', 'store', v_store, null,
          jsonb_build_object('reset_id', p_reset_id, 'generation', v_gen, 'scopes', to_jsonb(v_scopes), 'counts', v_counts)::text);

  return jsonb_build_object(
    'reset_id', p_reset_id, 'generation', v_gen, 'scopes', to_jsonb(v_scopes),
    'counts', v_counts, 'created_at', v_at, 'duplicate', false);
end;
$$;

revoke execute on function reset_store_data(text, text[], text) from public, anon;
grant execute on function reset_store_data(text, text[], text) to authenticated;

-- How many rows a reset of [p_scopes] would remove from each table, for the
-- confirmation screen: the reset is run and then undone (nothing changes),
-- so the figures are exactly what it would do now. Returns {scopes, counts}.
create or replace function store_reset_preview(p_scopes text[])
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_store  text := current_store_id();
  v_scopes text[];
  v_counts jsonb := '{}'::jsonb;
begin
  if v_store is null then
    raise exception 'must be signed in as a store';
  end if;
  v_scopes := store_reset_scopes(p_scopes);
  begin
    v_counts := store_reset_apply(v_store, v_scopes);
    raise exception using errcode = 'UPRVW', message = 'preview only';
  exception when sqlstate 'UPRVW' then
    null; -- everything above is rolled back; the counts are kept
  end;
  return jsonb_build_object('scopes', to_jsonb(v_scopes), 'counts', v_counts);
end;
$$;

revoke execute on function store_reset_preview(text[]) from public, anon;
grant execute on function store_reset_preview(text[]) to authenticated;
