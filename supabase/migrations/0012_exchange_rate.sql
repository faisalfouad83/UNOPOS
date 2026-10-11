-- Dollar/dinar: each store sets how many dinars a dollar is worth, the
-- till shows totals in both, and cash can be handed over in either. A sale
-- paid in the other currency records what was handed over and at what
-- rate (the sale's own amounts stay in the store's currency).

alter table app_settings add column if not exists usd_exchange_rate double precision not null default 0;

alter table sales add column if not exists paid_currency text;
alter table sales add column if not exists exchange_rate double precision;
alter table sales add column if not exists foreign_tendered_minor_units bigint;

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

  if p_sold_at is not null then
    v_result := jsonb_set(v_result, '{sale,created_at}', to_jsonb(p_sold_at));
    v_result := jsonb_set(v_result, '{sale,completed_at}', to_jsonb(p_sold_at));
  end if;

  return v_result;
end;
$$;
