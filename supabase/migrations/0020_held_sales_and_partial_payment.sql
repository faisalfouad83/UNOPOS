-- Suspended (held) sales, done properly, and part-payment on pay-later:
--  * rehold_sale: re-holding a resumed sale keeps its number and place in
--    the list instead of adding a copy;
--  * checkout_sale_once: a resumed sale is sold from the cart as it is now
--    (items added or changed after resuming are charged) and the held sale
--    it came from is closed in the same transaction, so it can't be sold
--    twice or linger in the list;
--  * a pay-later sale can take part of the money up front; the rest stays
--    as the customer's debt;
--  * the branch a sale is rung up in must belong to the signed-in store.

-- Re-holding a resumed sale. Sale lines are never deleted: the cart as it
-- is now becomes a new held sale that takes over the old one's number and
-- place in the list (its created_at), and the old one is closed (voided,
-- renumbered with a suffix so a lookup by number finds the live one).
create or replace function rehold_sale(
  p_sale_id text,
  p_lines jsonb,
  p_customer_id text default null,
  p_hold_label text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_store_id text := current_store_id();
  v_old sales;
  v_new_id text := gen_random_uuid()::text;
  v_line jsonb;
  v_qty bigint;
  v_unit bigint;
  v_disc bigint;
  v_tax bigint;
  v_subtotal bigint := 0;
  v_discount bigint := 0;
  v_tax_total bigint := 0;
begin
  if v_store_id is null then
    raise exception 'must be signed in as a store';
  end if;
  select * into v_old from sales where id = p_sale_id and store_id = v_store_id for update;
  if v_old.id is null or v_old.status <> 'held' then
    raise exception 'held sale not found';
  end if;
  if p_lines is null or jsonb_array_length(p_lines) = 0 then
    raise exception 'a sale needs at least one line';
  end if;
  if p_customer_id is not null and not exists (select 1 from customers where id = p_customer_id and store_id = v_store_id) then
    raise exception 'Unknown customer';
  end if;

  update sales set status = 'voided', sale_number = v_old.sale_number || '-R' || substr(v_new_id, 1, 4)
    where id = v_old.id;

  insert into sales (id, store_id, branch_id, sale_number, status, customer_id, hold_label, shift_id, cashier_id, created_at)
  values (v_new_id, v_store_id, v_old.branch_id, v_old.sale_number, 'held', p_customer_id, p_hold_label,
          v_old.shift_id, v_old.cashier_id, v_old.created_at);

  for v_line in select * from jsonb_array_elements(p_lines) loop
    v_qty := (v_line->>'quantity')::bigint;
    v_unit := (v_line->>'unit_price_minor_units')::bigint;
    v_disc := coalesce((v_line->>'discount_amount_minor_units')::bigint, 0);
    v_tax := coalesce((v_line->>'tax_amount_minor_units')::bigint, 0);
    if v_qty <= 0 then
      raise exception 'quantity must be positive';
    end if;
    if not exists (select 1 from products where id = v_line->>'product_id' and store_id = v_store_id) then
      raise exception 'Unknown product';
    end if;
    v_subtotal := v_subtotal + v_unit * v_qty;
    v_discount := v_discount + v_disc;
    v_tax_total := v_tax_total + v_tax;
    insert into sale_lines (id, store_id, sale_id, product_id, quantity, unit_price_minor_units,
                            discount_amount_minor_units, tax_amount_minor_units, line_total_minor_units,
                            cost_price_snapshot_minor_units)
    values (gen_random_uuid()::text, v_store_id, v_new_id, v_line->>'product_id', v_qty, v_unit, v_disc, v_tax,
            v_unit * v_qty - v_disc + v_tax, coalesce((v_line->>'cost_price_snapshot_minor_units')::bigint, 0));
  end loop;

  update sales set
    subtotal_minor_units = v_subtotal,
    discount_total_minor_units = v_discount,
    tax_total_minor_units = v_tax_total,
    grand_total_minor_units = v_subtotal - v_discount + v_tax_total
  where id = v_new_id;

  return jsonb_build_object('sale_id', v_new_id);
end;
$$;

grant execute on function rehold_sale(text, jsonb, text, text) to authenticated;

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

  if coalesce(trim(p_extras ->> 'customer_phone'), '') <> '' then
    update customers c
    set phone = trim(p_extras ->> 'customer_phone')
    from sales s
    where s.id = v_sale_id and c.id = s.customer_id;
  end if;

  -- Pay-later with money up front: record it as the first payment on the
  -- debt (cash in, receivable down), exactly as a later payment would be.
  if p_payment_method = 'payLater' and v_paid_now > 0 then
    v_debt_id := v_result ->> 'debt_entry_id';
    if v_paid_now >= (v_result -> 'sale' ->> 'grand_total_minor_units')::bigint then
      raise exception 'paid in full: not a pay-later sale';
    end if;
    v_payment_id := record_debt_payment(v_debt_id, v_paid_now, 'cash', p_cashier_id);
    v_journal := post_journal_entry(
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
