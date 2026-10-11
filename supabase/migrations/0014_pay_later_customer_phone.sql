-- Debt reminders: the pay-later checkout can carry the customer's phone
-- (p_extras.customer_phone), saved on the customer so the Debts screen can
-- send a WhatsApp reminder. The sale is also linked to its customer.

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
begin
  if p_client_sale_id is not null then
    select id into v_existing_id
    from sales
    where store_id = v_store_id and client_sale_id = p_client_sale_id;
    if v_existing_id is not null then
      return jsonb_build_object('duplicate', true, 'sale_id', v_existing_id);
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

  update sales
  set client_sale_id = p_client_sale_id,
      created_at = coalesce(p_sold_at, created_at),
      completed_at = coalesce(p_sold_at, completed_at),
      paid_currency = p_extras ->> 'paid_currency',
      exchange_rate = (p_extras ->> 'exchange_rate')::double precision,
      foreign_tendered_minor_units = (p_extras ->> 'foreign_tendered_minor_units')::bigint
  where id = v_sale_id;

  -- A pay-later sale's customer comes from its debt entry; link it on the
  -- sale too, and save the phone the cashier entered (for reminders).
  update sales s
  set customer_id = d.customer_id
  from debt_ledger_entries d
  where s.id = v_sale_id and d.sale_id = v_sale_id and s.customer_id is null;

  if coalesce(trim(p_extras ->> 'customer_phone'), '') <> '' then
    update customers c
    set phone = trim(p_extras ->> 'customer_phone')
    from sales s
    where s.id = v_sale_id and c.id = s.customer_id;
  end if;

  if p_sold_at is not null then
    v_result := jsonb_set(v_result, '{sale,created_at}', to_jsonb(p_sold_at));
    v_result := jsonb_set(v_result, '{sale,completed_at}', to_jsonb(p_sold_at));
  end if;

  return v_result;
end;
$$;
