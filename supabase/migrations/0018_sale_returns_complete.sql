-- Returns, done properly:
--  * each sale line remembers how much of it was returned, so the same
--    items can't be returned twice and reports can show net sales/profit;
--  * the invoice is marked refunded / partiallyRefunded;
--  * loyalty points earned on the invoice are taken back in proportion.

alter table sale_lines add column if not exists quantity_returned bigint not null default 0;

update sale_lines sl set quantity_returned = r.qty
from (select sale_line_id, sum(quantity_returned) qty from sale_return_lines group by sale_line_id) r
where r.sale_line_id = sl.id;

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
  v_settlement_account text;
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

  v_was_pay_later := v_sale.payment_method = 'payLater';
  v_settlement_account := case when v_was_pay_later then '1100' when p_refund_to_cash then '1000' else '1010' end;

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

  -- Take back the loyalty points this invoice earned, in proportion to the
  -- amount refunded (never more than were earned, never below zero).
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

  return jsonb_build_object('return_id', v_return_id, 'refund', v_refund_total);
end;
$$;
