-- =============================================================================
-- UNOPOS — Phase H2: Composite checkout RPCs
-- =============================================================================
-- These two functions are direct, reviewable ports of the existing Dart
-- orchestration in lib/features/pos/domain/complete_sale_use_case.dart and
-- process_sale_return_use_case.dart — same formulas (revenue/COGS math,
-- per-unit refund via truncating integer division, journal-line shapes per
-- payment method), same account codes (SystemAccountCodes in
-- lib/core/constants/default_chart_of_accounts.dart, inlined here as
-- literals — keep in sync if that file changes).
--
-- The reason these exist as RPCs at all: today, checkout/return processing
-- is 4-7 separate, independently-committed Dart calls across 4 repositories
-- with NO shared transaction — a crash mid-sequence can leave a completed
-- sale with no stock deducted, or stock deducted with no journal entry.
-- Kept separate from 0002_business_operations.sql because they're the
-- highest-risk/most-reviewed functions in this phase: money and stock
-- consistency for every sale a store ever makes depends on them.
--
-- Both call the primitives from 0002 (record_stock_movement,
-- post_journal_entry, next_sale_number) via ordinary SQL function calls —
-- a function called from within another function shares the same
-- transaction as its caller, so this is genuinely all-or-nothing.
-- =============================================================================

-- p_lines shape (only used when NOT resuming a held sale):
--   [{"product_id","quantity","unit_price_minor_units",
--     "discount_amount_minor_units","tax_amount_minor_units",
--     "cost_price_snapshot_minor_units"}, ...]
-- Returns: {"sale": {...with "lines":[...]}, "debt_entry_id": text|null}
create or replace function checkout_sale(
  p_branch_id text,
  p_cashier_id text,
  p_payment_method text,
  p_shift_id text default null,
  p_lines jsonb default null,
  p_amount_tendered_minor_units bigint default null,
  p_change_given_minor_units bigint default null,
  p_customer_name_for_pay_later text default null,
  p_resuming_sale_id text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_store_id text := current_store_id();
  v_sale_id text;
  v_sale_number text;
  v_now timestamptz := now();
  v_sale_row sales;
  v_line jsonb;
  v_sale_line record;
  v_subtotal bigint := 0;
  v_discount_total bigint := 0;
  v_tax_total bigint := 0;
  v_grand_total bigint := 0;
  v_revenue bigint := 0;
  v_cogs bigint := 0;
  v_qty bigint;
  v_unit_price bigint;
  v_disc bigint;
  v_tax bigint;
  v_cost bigint;
  v_line_total bigint;
  v_product_id text;
  v_line_id text;
  v_settlement_account text;
  v_memo text;
  v_journal jsonb;
  v_journal_id text;
  v_customer_id text;
  v_debt_entry_id text := null;
  v_lines_out jsonb;
begin
  if v_store_id is null then
    raise exception 'must be signed in as a store to check out a sale';
  end if;

  if p_resuming_sale_id is not null then
    -- Resuming a previously-held sale (created earlier via a plain
    -- createSale(status: held) call) — reuse its already-persisted lines,
    -- just flip it to completed.
    select * into v_sale_row from sales where id = p_resuming_sale_id and store_id = v_store_id and status = 'held';
    if v_sale_row.id is null then
      raise exception 'held sale not found';
    end if;
    v_sale_id := v_sale_row.id;
    v_sale_number := v_sale_row.sale_number;

    select coalesce(sum(quantity * unit_price_minor_units), 0), coalesce(sum(discount_amount_minor_units), 0), coalesce(sum(tax_amount_minor_units), 0)
      into v_subtotal, v_discount_total, v_tax_total
      from sale_lines where sale_id = v_sale_id;
    v_grand_total := v_subtotal - v_discount_total + v_tax_total;

    update sales set status = 'completed' where id = v_sale_id;
  else
    if p_lines is null or jsonb_array_length(p_lines) = 0 then
      raise exception 'a sale needs at least one line';
    end if;

    for v_line in select * from jsonb_array_elements(p_lines) loop
      v_qty := (v_line->>'quantity')::bigint;
      v_unit_price := (v_line->>'unit_price_minor_units')::bigint;
      v_disc := coalesce((v_line->>'discount_amount_minor_units')::bigint, 0);
      v_tax := coalesce((v_line->>'tax_amount_minor_units')::bigint, 0);
      v_subtotal := v_subtotal + v_unit_price * v_qty;
      v_discount_total := v_discount_total + v_disc;
      v_tax_total := v_tax_total + v_tax;
    end loop;
    v_grand_total := v_subtotal - v_discount_total + v_tax_total;

    v_sale_id := gen_random_uuid()::text;
    v_sale_number := next_sale_number();

    insert into sales (id, store_id, branch_id, sale_number, status, subtotal_minor_units, discount_total_minor_units, tax_total_minor_units, grand_total_minor_units, shift_id, cashier_id, created_at)
    values (v_sale_id, v_store_id, p_branch_id, v_sale_number, 'completed', v_subtotal, v_discount_total, v_tax_total, v_grand_total, p_shift_id, p_cashier_id, v_now);

    for v_line in select * from jsonb_array_elements(p_lines) loop
      v_product_id := v_line->>'product_id';
      v_qty := (v_line->>'quantity')::bigint;
      v_unit_price := (v_line->>'unit_price_minor_units')::bigint;
      v_disc := coalesce((v_line->>'discount_amount_minor_units')::bigint, 0);
      v_tax := coalesce((v_line->>'tax_amount_minor_units')::bigint, 0);
      v_cost := coalesce((v_line->>'cost_price_snapshot_minor_units')::bigint, 0);
      v_line_total := (v_unit_price * v_qty) - v_disc + v_tax;
      v_line_id := gen_random_uuid()::text;

      insert into sale_lines (id, store_id, sale_id, product_id, quantity, unit_price_minor_units, discount_amount_minor_units, tax_amount_minor_units, line_total_minor_units, cost_price_snapshot_minor_units)
      values (v_line_id, v_store_id, v_sale_id, v_product_id, v_qty, v_unit_price, v_disc, v_tax, v_line_total, v_cost);
    end loop;
  end if;

  -- Deduct stock for every line, whether freshly inserted above or already
  -- persisted from an earlier hold.
  for v_sale_line in select product_id, quantity from sale_lines where sale_id = v_sale_id loop
    perform record_stock_movement(v_sale_line.product_id, p_branch_id, 'saleOut', v_sale_line.quantity, 0, 'SALE', v_sale_id, p_cashier_id);
  end loop;

  v_revenue := v_subtotal - v_discount_total;
  select coalesce(sum(cost_price_snapshot_minor_units * quantity), 0) into v_cogs from sale_lines where sale_id = v_sale_id;

  -- Settlement account + memo by payment method — mirrors
  -- AccountingPostingService.postCashSale/postCardSale/postPayLaterSale.
  v_settlement_account := case p_payment_method
    when 'cash' then '1000'
    when 'card' then '1010'
    when 'payLater' then '1100'
    else null end;
  if v_settlement_account is null then
    raise exception 'unknown payment method: %', p_payment_method;
  end if;
  v_memo := case p_payment_method
    when 'cash' then 'Cash sale'
    when 'card' then 'Card sale'
    else 'Pay-later sale (on account)' end;

  v_journal := post_journal_entry(
    p_branch_id => p_branch_id,
    p_reference_type => 'SALE',
    p_reference_id => v_sale_id,
    p_memo => v_memo,
    p_created_by_user_id => p_cashier_id,
    p_lines => (
      select jsonb_agg(x) from (
        select jsonb_build_object('account_code', v_settlement_account, 'debit_minor_units', v_revenue + v_tax_total, 'credit_minor_units', 0, 'description', 'Settlement') as x
        union all
        select jsonb_build_object('account_code', '4000', 'debit_minor_units', 0, 'credit_minor_units', v_revenue, 'description', 'Revenue')
        union all
        select jsonb_build_object('account_code', '2100', 'debit_minor_units', 0, 'credit_minor_units', v_tax_total, 'description', 'Tax collected') where v_tax_total > 0
        union all
        select jsonb_build_object('account_code', '5000', 'debit_minor_units', v_cogs, 'credit_minor_units', 0, 'description', 'COGS') where v_cogs > 0
        union all
        select jsonb_build_object('account_code', '1200', 'debit_minor_units', 0, 'credit_minor_units', v_cogs, 'description', 'Inventory reduction') where v_cogs > 0
      ) t
    )
  );
  v_journal_id := v_journal->>'id';

  if p_payment_method = 'payLater' then
    if p_customer_name_for_pay_later is not null and length(trim(p_customer_name_for_pay_later)) > 0 then
      select id into v_customer_id from customers where store_id = v_store_id and name = trim(p_customer_name_for_pay_later) limit 1;
    end if;
    if v_customer_id is null then
      v_customer_id := gen_random_uuid()::text;
      insert into customers (id, store_id, name, created_at)
      values (v_customer_id, v_store_id, coalesce(nullif(trim(p_customer_name_for_pay_later), ''), 'Walk-in customer'), v_now);
    end if;

    v_debt_entry_id := gen_random_uuid()::text;
    insert into debt_ledger_entries (id, store_id, branch_id, customer_id, sale_id, journal_entry_id, original_amount_minor_units, receipt_ref, created_at)
    values (v_debt_entry_id, v_store_id, p_branch_id, v_customer_id, v_sale_id, v_journal_id, v_grand_total, v_sale_number, v_now);
  end if;

  update sales set
    payment_method = p_payment_method,
    amount_tendered_minor_units = p_amount_tendered_minor_units,
    change_given_minor_units = p_change_given_minor_units,
    journal_entry_id = v_journal_id,
    completed_at = v_now
  where id = v_sale_id;

  select coalesce(jsonb_agg(jsonb_build_object(
    'id', id, 'sale_id', sale_id, 'product_id', product_id, 'quantity', quantity,
    'unit_price_minor_units', unit_price_minor_units, 'discount_amount_minor_units', discount_amount_minor_units,
    'tax_amount_minor_units', tax_amount_minor_units, 'line_total_minor_units', line_total_minor_units,
    'cost_price_snapshot_minor_units', cost_price_snapshot_minor_units
  )), '[]'::jsonb) into v_lines_out from sale_lines where sale_id = v_sale_id;

  return jsonb_build_object(
    'sale', jsonb_build_object(
      'id', v_sale_id, 'store_id', v_store_id, 'branch_id', p_branch_id, 'sale_number', v_sale_number,
      'status', 'completed', 'customer_id', null, 'hold_label', null,
      'subtotal_minor_units', v_subtotal, 'discount_total_minor_units', v_discount_total,
      'tax_total_minor_units', v_tax_total, 'grand_total_minor_units', v_grand_total,
      'payment_method', p_payment_method, 'amount_tendered_minor_units', p_amount_tendered_minor_units,
      'change_given_minor_units', p_change_given_minor_units, 'shift_id', p_shift_id, 'cashier_id', p_cashier_id,
      'journal_entry_id', v_journal_id, 'created_at', v_now, 'completed_at', v_now, 'lines', v_lines_out
    ),
    'debt_entry_id', v_debt_entry_id
  );
end;
$$;

-- p_return_lines shape: [{"sale_line_id","quantity_returned"}, ...]
-- Returns: {"return_id": text|null} (null if every line had quantity 0)
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
  v_line_id text;
  v_was_pay_later boolean;
  v_settlement_account text;
  v_journal jsonb;
  v_journal_id text;
  v_debt debt_ledger_entries;
  v_new_original bigint;
begin
  if v_store_id is null then
    raise exception 'must be signed in as a store to process a sale return';
  end if;

  select * into v_sale from sales where id = p_original_sale_id and store_id = v_store_id;
  if v_sale.id is null then
    raise exception 'original sale not found';
  end if;

  if p_return_lines is null or jsonb_array_length(p_return_lines) = 0 then
    return jsonb_build_object('return_id', null);
  end if;

  insert into sale_returns (id, store_id, branch_id, original_sale_id, refund_method, processed_by_user_id, created_at)
  values (v_return_id, v_store_id, v_sale.branch_id, p_original_sale_id, case when p_refund_to_cash then 'cash' else 'card' end, p_processed_by_user_id, v_now);

  for v_rline in select * from jsonb_array_elements(p_return_lines) loop
    v_qty_returned := (v_rline->>'quantity_returned')::bigint;
    if v_qty_returned <= 0 then
      continue;
    end if;

    select * into v_sale_line from sale_lines where id = (v_rline->>'sale_line_id') and sale_id = p_original_sale_id;
    if v_sale_line.id is null then
      raise exception 'sale line not found: %', v_rline->>'sale_line_id';
    end if;

    -- Truncating integer division, same as ProcessSaleReturnUseCase — a
    -- per-unit refund derived from the line total (folding in discount/tax
    -- proportionally per whole unit).
    v_unit_total := case when v_sale_line.quantity = 0 then 0 else v_sale_line.line_total_minor_units / v_sale_line.quantity end;
    v_refund := v_unit_total * v_qty_returned;
    v_refund_total := v_refund_total + v_refund;
    v_restocked_cogs := v_restocked_cogs + v_sale_line.cost_price_snapshot_minor_units * v_qty_returned;

    v_line_id := gen_random_uuid()::text;
    insert into sale_return_lines (id, store_id, sale_return_id, sale_line_id, quantity_returned, refund_amount_minor_units)
    values (v_line_id, v_store_id, v_return_id, v_sale_line.id, v_qty_returned, v_refund);

    perform record_stock_movement(v_sale_line.product_id, v_sale.branch_id, 'returnIn', v_qty_returned, 0, 'SALE_RETURN', v_return_id, p_processed_by_user_id);
  end loop;

  if v_refund_total = 0 and v_restocked_cogs = 0 then
    return jsonb_build_object('return_id', v_return_id);
  end if;

  v_was_pay_later := v_sale.payment_method = 'payLater';
  v_settlement_account := case when v_was_pay_later then '1100' when p_refund_to_cash then '1000' else '1010' end;

  -- Mirrors AccountingPostingService.postSaleReturn.
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
        select jsonb_build_object('account_code', v_settlement_account, 'debit_minor_units', 0, 'credit_minor_units', v_refund_total, 'description', '')
        union all
        select jsonb_build_object('account_code', '1200', 'debit_minor_units', v_restocked_cogs, 'credit_minor_units', 0, 'description', '') where v_restocked_cogs > 0
        union all
        select jsonb_build_object('account_code', '5000', 'debit_minor_units', 0, 'credit_minor_units', v_restocked_cogs, 'description', '') where v_restocked_cogs > 0
      ) t
    )
  );
  v_journal_id := v_journal->>'id';

  update sale_returns set journal_entry_id = v_journal_id where id = v_return_id;

  if v_was_pay_later then
    select * into v_debt from debt_ledger_entries where sale_id = p_original_sale_id and store_id = v_store_id for update;
    if v_debt.id is not null then
      v_new_original := greatest(0, v_debt.original_amount_minor_units - v_refund_total);
      update debt_ledger_entries set
        original_amount_minor_units = v_new_original,
        status = case
          when v_debt.amount_paid_minor_units >= v_new_original then 'paid'
          when v_debt.amount_paid_minor_units > 0 then 'partiallyPaid'
          else 'open' end
      where id = v_debt.id;
    end if;
  end if;

  return jsonb_build_object('return_id', v_return_id);
end;
$$;
