-- 0027: fixes from the full review (security and money).
--
-- * low_stock_items reads with the caller's rights (it showed every store's
--   rows to anyone signed in).
-- * record_stock_movement: only this store's products and branches, only
--   positive quantities of a known kind.
-- * A purchase order or transfer is received once.
-- * A debt payment can't be zero, negative or more than what is owed.
-- * Journal entries leave out lines of nothing, so a free sale checks out.
-- * Returning a pay-later sale that was partly paid gives back the cash
--   part in cash (it all went to the receivable before).
-- * A pay-later customer typed with a different phone than a namesake on
--   file is a different customer; offline sales keep the time they were
--   made on their journal entry, debt and up-front payment.
-- * shift_cash_summary: what should be in the drawer, worked out the same
--   way everywhere.
-- * A store's own account can't create its store row with a paid licence.
-- * PINs: changing an owner's or manager's PIN needs the owner's own PIN;
--   PIN sign-in checks the chosen employee and slows down guessing.

alter view low_stock_items set (security_invoker = true);

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
  if p_quantity is null or p_quantity <= 0 then
    raise exception 'quantity must be positive';
  end if;
  if p_type not in ('purchaseIn', 'transferIn', 'adjustmentIn', 'returnIn', 'saleOut', 'transferOut', 'adjustmentOut', 'returnOut') then
    raise exception 'unknown stock movement type: %', p_type;
  end if;
  if not exists (select 1 from products where id = p_product_id and store_id = v_store_id) then
    raise exception 'product does not belong to this store';
  end if;
  if not exists (select 1 from branches where id = p_branch_id and store_id = v_store_id) then
    raise exception 'branch does not belong to this store';
  end if;

  v_signed := case when p_type in ('purchaseIn', 'transferIn', 'adjustmentIn', 'returnIn') then p_quantity else -p_quantity end;

  insert into stock_items (id, store_id, product_id, branch_id, quantity_on_hand)
  values (gen_random_uuid()::text, v_store_id, p_product_id, p_branch_id, v_signed)
  on conflict (product_id, branch_id)
  do update set quantity_on_hand = stock_items.quantity_on_hand + excluded.quantity_on_hand
  returning quantity_on_hand into v_new_qty;

  insert into stock_movements (id, store_id, product_id, branch_id, type, quantity, unit_cost_minor_units, reference_type, reference_id, created_by_user_id, created_at)
  values (gen_random_uuid()::text, v_store_id, p_product_id, p_branch_id, p_type, p_quantity, coalesce(p_unit_cost_minor_units, 0), p_reference_type, p_reference_id, p_created_by_user_id, now());

  return v_new_qty;
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

  -- Locked, so two devices receiving it at once can't both add the stock.
  select * into v_po from purchase_orders where id = p_purchase_order_id and store_id = v_store_id for update;
  if v_po.id is null then
    raise exception 'purchase order not found';
  end if;
  if v_po.status = 'received' then
    raise exception 'purchase order already received';
  end if;
  if v_po.status = 'cancelled' then
    raise exception 'purchase order was cancelled';
  end if;

  for v_line in select * from purchase_order_lines where purchase_order_id = p_purchase_order_id loop
    if v_line.quantity_ordered > 0 then
      perform record_stock_movement(v_line.product_id, v_po.branch_id, 'purchaseIn', v_line.quantity_ordered, v_line.unit_cost_minor_units, 'PURCHASE_ORDER', p_purchase_order_id, p_received_by_user_id);
    end if;
    update purchase_order_lines set quantity_received = v_line.quantity_ordered where id = v_line.id;
  end loop;

  update purchase_orders set status = 'received' where id = p_purchase_order_id;

  return v_po.total_cost_minor_units;
end;
$$;

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

  select * into v_transfer from stock_transfers where id = p_transfer_id and store_id = v_store_id for update;
  if v_transfer.id is null then
    raise exception 'stock transfer not found';
  end if;
  if v_transfer.status = 'received' then
    raise exception 'stock transfer already received';
  end if;
  if v_transfer.status = 'cancelled' then
    raise exception 'stock transfer was cancelled';
  end if;

  for v_line in select * from stock_transfer_lines where stock_transfer_id = p_transfer_id loop
    if v_line.quantity > 0 then
      perform record_stock_movement(v_line.product_id, v_transfer.from_branch_id, 'transferOut', v_line.quantity, 0, 'STOCK_TRANSFER', p_transfer_id, p_received_by_user_id);
      perform record_stock_movement(v_line.product_id, v_transfer.to_branch_id, 'transferIn', v_line.quantity, 0, 'STOCK_TRANSFER', p_transfer_id, p_received_by_user_id);
    end if;
  end loop;

  update stock_transfers set status = 'received', received_by_user_id = p_received_by_user_id, received_at = now() where id = p_transfer_id;
end;
$$;

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
  if p_amount_minor_units is null or p_amount_minor_units <= 0 then
    raise exception 'payment must be more than zero';
  end if;

  select * into v_entry from debt_ledger_entries where id = p_debt_ledger_entry_id and store_id = v_store_id for update;
  if v_entry.id is null then
    raise exception 'debt ledger entry not found';
  end if;
  if p_amount_minor_units > v_entry.original_amount_minor_units - v_entry.amount_paid_minor_units then
    raise exception 'payment is more than what is owed';
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
  v_lines jsonb;
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

  -- Lines of nothing are left out (a sale given away free has no takings
  -- or revenue to record). If nothing is left there is nothing to post.
  select coalesce(jsonb_agg(l), '[]'::jsonb) into v_lines
  from jsonb_array_elements(p_lines) l
  where coalesce((l ->> 'debit_minor_units')::bigint, 0) <> 0
     or coalesce((l ->> 'credit_minor_units')::bigint, 0) <> 0;
  if jsonb_array_length(v_lines) = 0 then
    return null;
  end if;
  if jsonb_array_length(v_lines) < 2 then
    raise exception 'a journal entry needs at least two lines';
  end if;

  for v_line in select * from jsonb_array_elements(v_lines) loop
    v_debit := coalesce((v_line->>'debit_minor_units')::bigint, 0);
    v_credit := coalesce((v_line->>'credit_minor_units')::bigint, 0);
    if v_debit < 0 or v_credit < 0 then
      raise exception 'journal amounts cannot be negative (account %)', v_line->>'account_code';
    end if;
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

  for v_line in select * from jsonb_array_elements(v_lines) loop
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

create or replace function process_sale_return(
  p_original_sale_id text,
  p_return_lines jsonb,
  p_processed_by_user_id text,
  p_refund_to_cash boolean
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_store_id text := current_store_id();
  v_sale sales;
  v_return_id text := gen_random_uuid()::text;
  v_now timestamptz := now();
  v_rline jsonb;
  v_sale_line sale_lines;
  v_unit_total bigint;
  v_qty_returned bigint;
  v_refund bigint;
  v_refund_total bigint := 0;
  v_restocked_cogs bigint := 0;
  v_was_pay_later boolean;
  v_money_account text;
  v_to_receivable bigint := 0;
  v_to_money bigint;
  v_journal jsonb;
  v_journal_id text;
  v_debt debt_ledger_entries;
  v_new_original bigint;
  v_earned bigint;
  v_take_back bigint;
  v_remaining bigint;
begin
  if v_store_id is null then
    raise exception 'must be signed in as a store to process a sale return';
  end if;

  select * into v_sale from sales where id = p_original_sale_id and store_id = v_store_id for update;
  if v_sale.id is null then
    raise exception 'original sale not found';
  end if;
  if v_sale.status not in ('completed', 'partiallyRefunded') then
    raise exception 'sale cannot be returned (status %)', v_sale.status;
  end if;

  if p_return_lines is null or jsonb_array_length(p_return_lines) = 0 then
    return jsonb_build_object('return_id', null);
  end if;

  insert into sale_returns (id, store_id, branch_id, original_sale_id, refund_method, processed_by_user_id, created_at)
  values (v_return_id, v_store_id, v_sale.branch_id, p_original_sale_id,
          case when p_refund_to_cash then 'cash' else 'card' end,
          p_processed_by_user_id, v_now);

  for v_rline in select * from jsonb_array_elements(p_return_lines) loop
    v_qty_returned := (v_rline->>'quantity_returned')::bigint;
    if v_qty_returned <= 0 then
      continue;
    end if;

    select * into v_sale_line from sale_lines
      where id = (v_rline->>'sale_line_id') and sale_id = p_original_sale_id for update;
    if v_sale_line.id is null then
      raise exception 'sale line not found: %', v_rline->>'sale_line_id';
    end if;
    if v_qty_returned > v_sale_line.quantity - v_sale_line.quantity_returned then
      raise exception 'return exceeds remaining quantity';
    end if;

    v_unit_total := case when v_sale_line.quantity = 0 then 0 else v_sale_line.line_total_minor_units / v_sale_line.quantity end;
    v_refund := v_unit_total * v_qty_returned;
    v_refund_total := v_refund_total + v_refund;
    v_restocked_cogs := v_restocked_cogs + v_sale_line.cost_price_snapshot_minor_units * v_qty_returned;

    insert into sale_return_lines (id, store_id, sale_return_id, sale_line_id, quantity_returned, refund_amount_minor_units)
    values (gen_random_uuid()::text, v_store_id, v_return_id, v_sale_line.id, v_qty_returned, v_refund);

    update sale_lines set quantity_returned = quantity_returned + v_qty_returned where id = v_sale_line.id;

    perform record_stock_movement(v_sale_line.product_id, v_sale.branch_id, 'returnIn', v_qty_returned, 0, 'SALE_RETURN', v_return_id, p_processed_by_user_id);
  end loop;

  update sales set status = case
      when exists (select 1 from sale_lines where sale_id = v_sale.id and quantity_returned < quantity)
        then 'partiallyRefunded' else 'refunded' end
    where id = v_sale.id;

  if v_refund_total = 0 and v_restocked_cogs = 0 then
    return jsonb_build_object('return_id', v_return_id, 'refund', 0);
  end if;

  -- Paid later: the refund first comes off what the customer still owes;
  -- only what they had already paid beyond that is handed back.
  v_was_pay_later := v_sale.payment_method = 'payLater';
  v_money_account := case when p_refund_to_cash then '1000' else '1010' end;
  if v_was_pay_later then
    select * into v_debt from debt_ledger_entries where sale_id = p_original_sale_id and store_id = v_store_id for update;
    if v_debt.id is not null then
      v_to_receivable := least(v_refund_total, greatest(0, v_debt.original_amount_minor_units - v_debt.amount_paid_minor_units));
    else
      v_to_receivable := v_refund_total;
    end if;
  end if;
  v_to_money := v_refund_total - v_to_receivable;

  v_journal := post_journal_entry(
    p_branch_id => v_sale.branch_id,
    p_reference_type => 'RETURN',
    p_reference_id => v_return_id,
    p_memo => 'Sale return / refund',
    p_created_by_user_id => p_processed_by_user_id,
    p_lines => (
      select jsonb_agg(x) from (
        select jsonb_build_object('account_code', '4100', 'debit_minor_units', v_refund_total, 'credit_minor_units', 0, 'description', '') as x
        union all
        select jsonb_build_object('account_code', '1100', 'debit_minor_units', 0, 'credit_minor_units', v_to_receivable, 'description', '') where v_to_receivable > 0
        union all
        select jsonb_build_object('account_code', v_money_account, 'debit_minor_units', 0, 'credit_minor_units', v_to_money, 'description', '') where v_to_money > 0
        union all
        select jsonb_build_object('account_code', '1200', 'debit_minor_units', v_restocked_cogs, 'credit_minor_units', 0, 'description', '') where v_restocked_cogs > 0
        union all
        select jsonb_build_object('account_code', '5000', 'debit_minor_units', 0, 'credit_minor_units', v_restocked_cogs, 'description', '') where v_restocked_cogs > 0
      ) t
    )
  );
  v_journal_id := v_journal->>'id';
  update sale_returns set journal_entry_id = v_journal_id where id = v_return_id;

  if v_was_pay_later and v_debt.id is not null then
    v_new_original := greatest(0, v_debt.original_amount_minor_units - v_refund_total);
    update debt_ledger_entries set
      original_amount_minor_units = v_new_original,
      -- What was handed back is no longer paid.
      amount_paid_minor_units = greatest(0, v_debt.amount_paid_minor_units - v_to_money),
      status = case
        when greatest(0, v_debt.amount_paid_minor_units - v_to_money) >= v_new_original then 'paid'
        when greatest(0, v_debt.amount_paid_minor_units - v_to_money) > 0 then 'partiallyPaid'
        else 'open' end
    where id = v_debt.id;
  end if;

  if v_sale.customer_id is not null and v_sale.grand_total_minor_units > 0 then
    select coalesce(sum(points), 0) into v_earned from loyalty_transactions
      where sale_id = v_sale.id and reason = 'earn';
    if v_earned > 0 then
      select coalesce(-sum(points), 0) into v_take_back from loyalty_transactions
        where sale_id = v_sale.id and reason = 'return';
      v_remaining := v_earned - v_take_back;
      v_take_back := least(v_remaining, (v_earned * v_refund_total) / v_sale.grand_total_minor_units);
      if v_take_back > 0 then
        update customers set loyalty_points = greatest(0, loyalty_points - v_take_back)
          where id = v_sale.customer_id and store_id = v_store_id;
        insert into loyalty_transactions (store_id, customer_id, sale_id, points, reason)
          values (v_store_id, v_sale.customer_id, v_sale.id, -v_take_back, 'return');
      end if;
    end if;
  end if;

  return jsonb_build_object('return_id', v_return_id, 'refund', v_refund_total, 'refund_cash', v_to_money);
end;
$$;

create or replace function checkout_sale_once(
  p_client_sale_id text,
  p_branch_id text,
  p_cashier_id text,
  p_payment_method text,
  p_shift_id text default null,
  p_lines jsonb default null,
  p_amount_tendered_minor_units bigint default null,
  p_change_given_minor_units bigint default null,
  p_customer_name_for_pay_later text default null,
  p_resuming_sale_id text default null,
  p_sold_at timestamptz default null,
  p_extras jsonb default '{}'::jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_store_id text := current_store_id();
  v_existing_id text;
  v_result jsonb;
  v_sale_id text;
  v_loyalty_customer text;
  v_spend_per_point bigint;
  v_balance bigint;
  v_redeem bigint;
  v_earn bigint;
  v_loyalty_enabled boolean;
  v_release text := nullif(p_extras ->> 'release_held_sale_id', '');
  v_paid_now bigint := coalesce((p_extras ->> 'paid_now_minor_units')::bigint, 0);
  v_debt_id text;
  v_payment_id text;
  v_journal jsonb;
  v_phone text;
  v_customer customers;
  v_other text;
begin
  if v_store_id is null then
    raise exception 'must be signed in as a store to check out a sale';
  end if;

  if p_client_sale_id is not null then
    select id into v_existing_id
    from sales
    where store_id = v_store_id and client_sale_id = p_client_sale_id;
    if v_existing_id is not null then
      return jsonb_build_object('duplicate', true, 'sale_id', v_existing_id);
    end if;
  end if;

  if not exists (select 1 from branches where id = p_branch_id and store_id = v_store_id) then
    raise exception 'branch does not belong to this store';
  end if;

  -- The held sale this cart was resumed from: lock it so two tills can't
  -- both sell it, and refuse if it was already sold or discarded.
  if v_release is not null then
    perform 1 from sales where id = v_release and store_id = v_store_id and status = 'held' for update;
    if not found then
      raise exception 'held sale already closed';
    end if;
  end if;

  v_result := checkout_sale(
    p_branch_id,
    p_cashier_id,
    p_payment_method,
    p_shift_id,
    p_lines,
    p_amount_tendered_minor_units,
    p_change_given_minor_units,
    p_customer_name_for_pay_later,
    p_resuming_sale_id
  );
  v_sale_id := v_result -> 'sale' ->> 'id';

  if v_release is not null and v_release <> v_sale_id then
    update sales set status = 'voided' where id = v_release and store_id = v_store_id and status = 'held';
  end if;

  update sales
  set client_sale_id = p_client_sale_id,
      created_at = coalesce(p_sold_at, created_at),
      completed_at = coalesce(p_sold_at, completed_at),
      paid_currency = p_extras ->> 'paid_currency',
      exchange_rate = (p_extras ->> 'exchange_rate')::double precision,
      foreign_tendered_minor_units = (p_extras ->> 'foreign_tendered_minor_units')::bigint
  where id = v_sale_id;

  update sales s
  set customer_id = d.customer_id
  from debt_ledger_entries d
  where s.id = v_sale_id and d.sale_id = v_sale_id and s.customer_id is null;

  if nullif(p_extras ->> 'customer_id', '') is not null then
    if not exists (select 1 from customers where id = p_extras ->> 'customer_id' and store_id = v_store_id) then
      raise exception 'Unknown customer';
    end if;
    update sales set customer_id = p_extras ->> 'customer_id' where id = v_sale_id;
    update debt_ledger_entries set customer_id = p_extras ->> 'customer_id' where sale_id = v_sale_id;
  end if;

  -- A phone typed for a pay-later customer. The customer found by name is
  -- only the same person when the phone matches (or they have none yet);
  -- otherwise it is someone else with the same name, kept apart.
  v_phone := nullif(trim(coalesce(p_extras ->> 'customer_phone', '')), '');
  if v_phone is not null then
    select c.* into v_customer from customers c join sales s on s.customer_id = c.id where s.id = v_sale_id;
    if v_customer.id is not null then
      if coalesce(trim(v_customer.phone), '') in ('', v_phone) then
        update customers set phone = v_phone where id = v_customer.id;
      elsif nullif(p_extras ->> 'customer_id', '') is null then
        select id into v_other from customers
          where store_id = v_store_id and name = v_customer.name and trim(phone) = v_phone
          limit 1;
        if v_other is null then
          v_other := gen_random_uuid()::text;
          insert into customers (id, store_id, name, phone, created_at)
          values (v_other, v_store_id, v_customer.name, v_phone, now());
        end if;
        update sales set customer_id = v_other where id = v_sale_id;
        update debt_ledger_entries set customer_id = v_other where sale_id = v_sale_id;
      end if;
    end if;
  end if;

  -- A sale made offline is dated when it was made, not when it arrived:
  -- its journal entry and debt with it.
  if p_sold_at is not null then
    update journal_entries set entry_date = p_sold_at
      where id = v_result -> 'sale' ->> 'journal_entry_id' and store_id = v_store_id;
    update debt_ledger_entries set created_at = p_sold_at where sale_id = v_sale_id;
  end if;

  -- Pay-later with money up front: record it as the first payment on the
  -- debt (cash in, receivable down), exactly as a later payment would be.
  if p_payment_method = 'payLater' and v_paid_now > 0 then
    v_debt_id := v_result ->> 'debt_entry_id';
    if v_paid_now >= (v_result -> 'sale' ->> 'grand_total_minor_units')::bigint then
      raise exception 'paid in full: not a pay-later sale';
    end if;
    v_payment_id := record_debt_payment(v_debt_id, v_paid_now, 'cash', p_cashier_id);
    update debt_payments set paid_at = coalesce(p_sold_at, paid_at) where id = v_payment_id;
    v_journal := post_journal_entry(
      p_entry_date => p_sold_at,
      p_branch_id => p_branch_id,
      p_reference_type => 'DEBT_PAYMENT',
      p_reference_id => v_payment_id,
      p_memo => 'Customer debt payment received',
      p_created_by_user_id => p_cashier_id,
      p_lines => jsonb_build_array(
        jsonb_build_object('account_code', '1000', 'debit_minor_units', v_paid_now, 'credit_minor_units', 0, 'description', ''),
        jsonb_build_object('account_code', '1100', 'debit_minor_units', 0, 'credit_minor_units', v_paid_now, 'description', '')
      )
    );
    update debt_payments set journal_entry_id = v_journal ->> 'id' where id = v_payment_id;
    update sales set amount_tendered_minor_units = v_paid_now where id = v_sale_id;
    v_result := jsonb_set(v_result, '{sale,amount_tendered_minor_units}', to_jsonb(v_paid_now));
  end if;

  v_loyalty_customer := nullif(p_extras ->> 'loyalty_customer_id', '');
  if v_loyalty_customer is not null then
    select loyalty_points into v_balance
    from customers
    where id = v_loyalty_customer and store_id = v_store_id
    for update;
    if not found then
      raise exception 'Unknown loyalty customer';
    end if;

    v_redeem := coalesce((p_extras ->> 'points_redeemed')::bigint, 0);
    if v_redeem < 0 or v_redeem > v_balance then
      raise exception 'Not enough loyalty points';
    end if;

    select loyalty_spend_per_point_minor, loyalty_enabled into v_spend_per_point, v_loyalty_enabled
    from app_settings where store_id = v_store_id;
    v_earn := case
      when coalesce(v_loyalty_enabled, false) and coalesce(v_spend_per_point, 0) > 0
        then (v_result -> 'sale' ->> 'grand_total_minor_units')::bigint / v_spend_per_point
      else 0
    end;

    update customers set loyalty_points = loyalty_points - v_redeem + v_earn where id = v_loyalty_customer;
    update sales set customer_id = v_loyalty_customer where id = v_sale_id;

    if v_redeem > 0 then
      insert into loyalty_transactions (store_id, customer_id, sale_id, points, reason)
      values (v_store_id, v_loyalty_customer, v_sale_id, -v_redeem, 'redeem');
    end if;
    if v_earn > 0 then
      insert into loyalty_transactions (store_id, customer_id, sale_id, points, reason)
      values (v_store_id, v_loyalty_customer, v_sale_id, v_earn, 'earn');
    end if;

    v_result := v_result || jsonb_build_object(
      'loyalty', jsonb_build_object('earned', v_earn, 'redeemed', v_redeem, 'balance', v_balance - v_redeem + v_earn)
    );
  end if;

  if p_sold_at is not null then
    v_result := jsonb_set(v_result, '{sale,created_at}', to_jsonb(p_sold_at));
    v_result := jsonb_set(v_result, '{sale,completed_at}', to_jsonb(p_sold_at));
  end if;

  return v_result;
end;
$$;
-- What should be in a shift's cash drawer, in the store's currency:
-- the float it opened with, plus cash taken for sales (paid in another
-- currency, that currency went in and change came out), plus debts paid in
-- cash to this cashier (money taken up front on pay-later sales included),
-- minus cash handed back for returns and cash spent on expenses, both by
-- this cashier at this branch while the shift was open. Cash taken in
-- other currencies is listed apart.
create or replace function shift_cash_summary(p_shift_id text)
returns jsonb
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  v_store_id text := current_store_id();
  v_shift shifts;
  v_to timestamptz;
  v_cash_account text;
  v_sales bigint;
  v_foreign_change bigint;
  v_foreign jsonb;
  v_debts bigint;
  v_refunds bigint;
  v_expenses bigint;
begin
  if v_store_id is null then
    raise exception 'must be signed in as a store';
  end if;
  select * into v_shift from shifts where id = p_shift_id and store_id = v_store_id;
  if v_shift.id is null then
    raise exception 'shift not found';
  end if;
  v_to := coalesce(v_shift.closed_at, now());
  select id into v_cash_account from chart_of_accounts where store_id = v_store_id and code = '1000';

  select
    coalesce(sum(case when coalesce(foreign_tendered_minor_units, 0) > 0 then 0
                      when amount_tendered_minor_units is null then grand_total_minor_units
                      else amount_tendered_minor_units - coalesce(change_given_minor_units, 0) end), 0),
    coalesce(sum(case when coalesce(foreign_tendered_minor_units, 0) > 0 then coalesce(change_given_minor_units, 0) else 0 end), 0)
  into v_sales, v_foreign_change
  from sales
  where store_id = v_store_id and shift_id = v_shift.id and payment_method = 'cash'
    and status in ('completed', 'partiallyRefunded', 'refunded');

  select coalesce(jsonb_agg(jsonb_build_object('currency', currency, 'amount_minor_units', amount)), '[]'::jsonb)
  into v_foreign
  from (
    select coalesce(paid_currency, 'USD') as currency, sum(foreign_tendered_minor_units) as amount
    from sales
    where store_id = v_store_id and shift_id = v_shift.id and payment_method = 'cash'
      and status in ('completed', 'partiallyRefunded', 'refunded') and coalesce(foreign_tendered_minor_units, 0) > 0
    group by 1
  ) f;

  select coalesce(sum(amount_minor_units), 0) into v_debts
  from debt_payments
  where store_id = v_store_id and payment_method = 'cash' and received_by_user_id = v_shift.cashier_id
    and paid_at >= v_shift.opened_at and paid_at <= v_to;

  select coalesce(sum(l.credit_minor_units - l.debit_minor_units), 0) into v_refunds
  from sale_returns r
  join journal_lines l on l.journal_entry_id = r.journal_entry_id and l.account_id = v_cash_account
  where r.store_id = v_store_id and r.processed_by_user_id = v_shift.cashier_id and r.branch_id = v_shift.branch_id
    and r.created_at >= v_shift.opened_at and r.created_at <= v_to;

  -- Expenses taken back (reversed) don't count.
  select coalesce(sum(l.credit_minor_units - l.debit_minor_units), 0) into v_expenses
  from journal_entries e
  join journal_lines l on l.journal_entry_id = e.id and l.account_id = v_cash_account
  where e.store_id = v_store_id and e.reference_type = 'EXPENSE' and not e.is_reversal
    and e.created_by_user_id = v_shift.cashier_id and e.branch_id = v_shift.branch_id
    and e.entry_date >= v_shift.opened_at and e.entry_date <= v_to
    and not exists (select 1 from journal_entries rv where rv.reversal_of_entry_id = e.id);

  return jsonb_build_object(
    'shift_id', v_shift.id,
    'opening_minor_units', v_shift.opening_cash_float_minor_units,
    'cash_sales_minor_units', v_sales - v_foreign_change,
    'debt_payments_minor_units', v_debts,
    'refunds_minor_units', v_refunds,
    'expenses_minor_units', v_expenses,
    'expected_minor_units', v_shift.opening_cash_float_minor_units + v_sales - v_foreign_change + v_debts - v_refunds - v_expenses,
    'foreign', v_foreign,
    'as_of', v_to
  );
end;
$$;

grant execute on function shift_cash_summary(text) to authenticated;

-- A store's own account creating its row directly (the sign-up function
-- and the developer console aren't limited): it starts as a pending
-- trial like any other, and an account has one store.
create or replace function protect_store_insert()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  if current_user not in ('authenticated', 'anon') or is_developer_admin() then
    return new;
  end if;
  if exists (select 1 from stores where auth_user_id = auth.uid()) then
    raise exception 'this account already owns a store';
  end if;
  new.plan_id := 'starter';
  new.subscription_status := 'trial';
  new.activation_status := 'pending';
  new.license_key := null;
  new.activation_code_id := null;
  new.is_disabled := false;
  new.is_suspended := false;
  new.expires_at := null;
  new.last_sale_seq := 0;
  return new;
end;
$$;

create or replace trigger stores_protect_privileged_insert
  before insert on stores
  for each row execute function protect_store_insert();

-- Wrong PINs in a row, per store and employee ('*' = any employee): after
-- five, sign-in waits 30 seconds, doubling each time, up to 15 minutes.
create table if not exists pin_attempts (
  store_id text not null,
  scope text not null,
  failures int not null default 0,
  last_failure_at timestamptz,
  locked_until timestamptz,
  primary key (store_id, scope)
);
alter table pin_attempts enable row level security;
revoke all on pin_attempts from anon, authenticated;

create or replace function pin_wait_seconds(p_scope text)
returns int
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(
    (select greatest(0, ceil(extract(epoch from locked_until - now())))::int
     from pin_attempts where store_id = current_store_id() and scope = p_scope),
    0);
$$;

create or replace function pin_attempt(p_scope text, p_ok boolean)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_store_id text := current_store_id();
  v_failures int;
begin
  if p_ok then
    update pin_attempts set failures = 0, locked_until = null where store_id = v_store_id and scope = p_scope;
    return;
  end if;
  insert into pin_attempts (store_id, scope, failures, last_failure_at)
  values (v_store_id, p_scope, 1, now())
  on conflict (store_id, scope) do update set
    failures = case when pin_attempts.last_failure_at < now() - interval '15 minutes' then 1 else pin_attempts.failures + 1 end,
    last_failure_at = now()
  returning failures into v_failures;
  if v_failures >= 5 then
    update pin_attempts
    set locked_until = now() + least(interval '15 minutes', interval '30 seconds' * power(2, least(v_failures - 5, 10)))
    where store_id = v_store_id and scope = p_scope;
  end if;
end;
$$;

revoke execute on function pin_wait_seconds(text) from public, anon, authenticated;
revoke execute on function pin_attempt(text, boolean) from public, anon, authenticated;

-- PIN sign-in for the employee chosen on the screen (two employees may
-- share a PIN). Null when the PIN is wrong.
create or replace function verify_employee_pin_for(p_employee_id text, p_pin text)
returns users
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  v_user users;
  v_wait int;
begin
  if current_store_id() is null then
    raise exception 'must be signed in as a store to verify an employee pin';
  end if;
  v_wait := pin_wait_seconds(p_employee_id);
  if v_wait > 0 then
    raise exception 'too many PIN attempts' using detail = v_wait::text;
  end if;
  v_user := employee_with_pin(p_employee_id, p_pin);
  perform pin_attempt(p_employee_id, v_user.id is not null);
  if v_user.id is null then
    return null;
  end if;
  return v_user;
end;
$$;

grant execute on function verify_employee_pin_for(text, text) to authenticated;

-- The older PIN sign-in (any employee with this PIN), kept for apps not
-- yet updated; it slows down guessing too.
create or replace function verify_employee_pin(p_pin text)
returns users
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  v_store_id text := current_store_id();
  v_user users;
  v_wait int;
begin
  if v_store_id is null then
    raise exception 'must be signed in as a store to verify an employee pin';
  end if;
  v_wait := pin_wait_seconds('*');
  if v_wait > 0 then
    raise exception 'too many PIN attempts' using detail = v_wait::text;
  end if;

  select u.* into v_user
  from users u
  join employee_credentials c on c.user_id = u.id
  where u.store_id = v_store_id
    and u.is_active
    and c.pin_hash = crypt(p_pin, c.pin_hash)
  order by case u.role when 'owner' then 0 when 'manager' then 1 else 2 end, u.id
  limit 1;

  perform pin_attempt('*', v_user.id is not null);
  if v_user.id is null then
    return null;
  end if;
  return v_user;
end;
$$;

-- Changing a PIN, confirmed with the PIN of whoever is doing it: the owner
-- for the owner's or a manager's, the owner or a manager for anyone else's;
-- anyone may change their own.
create or replace function set_employee_pin(p_employee_id text, p_new_pin text, p_actor_id text, p_actor_pin text)
returns void
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  v_store_id text := current_store_id();
  v_actor users;
  v_target users;
begin
  if v_store_id is null then
    raise exception 'must be signed in as a store';
  end if;
  if p_new_pin is null or p_new_pin !~ '^[0-9]{4,8}$' then
    raise exception 'a PIN is 4 to 8 digits';
  end if;
  v_actor := employee_with_pin(p_actor_id, p_actor_pin);
  if v_actor.id is null then
    raise exception 'wrong PIN';
  end if;
  select * into v_target from users where id = p_employee_id and store_id = v_store_id for update;
  if v_target.id is null then
    raise exception 'employee not found';
  end if;
  if v_target.id <> v_actor.id then
    if v_actor.role not in ('owner', 'manager') then
      raise exception 'not allowed';
    end if;
    if v_target.role in ('owner', 'manager') and v_actor.role <> 'owner' then
      raise exception 'only the owner can change the PIN of the owner or a manager';
    end if;
  end if;

  update employee_credentials set pin_hash = crypt(p_new_pin, gen_salt('bf')), updated_at = now()
  where user_id = v_target.id;
  if not found then
    insert into employee_credentials (user_id, store_id, pin_hash)
    values (v_target.id, v_store_id, crypt(p_new_pin, gen_salt('bf')));
  end if;
  perform pin_attempt(v_target.id, true);

  insert into audit_logs (store_id, user_id, action, entity_type, entity_id, before_value_json, after_value_json)
  values (v_store_id, v_actor.id, 'employee.pin', 'user', v_target.id, null, null);
end;
$$;

grant execute on function set_employee_pin(text, text, text, text) to authenticated;

-- The older PIN change (no one confirms it), kept for apps not yet
-- updated: only for employees who are neither the owner nor a manager.
create or replace function update_employee_pin(p_user_id text, p_new_pin text)
returns void
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  v_store_id text := current_store_id();
  v_role text;
begin
  if v_store_id is null then
    raise exception 'must be signed in as a store to update an employee pin';
  end if;
  select role into v_role from users where id = p_user_id and store_id = v_store_id;
  if v_role is null then
    raise exception 'employee does not belong to this store';
  end if;
  if v_role in ('owner', 'manager') then
    raise exception 'only the owner can change the PIN of the owner or a manager';
  end if;
  if p_new_pin is null or p_new_pin !~ '^[0-9]{4,8}$' then
    raise exception 'a PIN is 4 to 8 digits';
  end if;

  update employee_credentials set pin_hash = crypt(p_new_pin, gen_salt('bf')), updated_at = now()
  where user_id = p_user_id;
end;
$$;
