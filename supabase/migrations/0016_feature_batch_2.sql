-- Second feature batch:
--  * loyalty can be switched on/off explicitly (was implied by the earn rate)
--  * optional "100% discount keeps a 5% margin over cost" protection
--  * per-employee permissions (comma-separated keys; null = role defaults)
--  * expense types (fixed / variable / negligible / custom) per expense
--  * 2-week trial activation codes, and new cloud stores start on a 2-week
--    trial instead of running unlicensed forever
--  * the till can attach a registered customer to any sale

alter table app_settings add column if not exists loyalty_enabled boolean not null default false;
update app_settings set loyalty_enabled = true where loyalty_spend_per_point_minor > 0;
alter table app_settings add column if not exists full_discount_keeps_margin boolean not null default false;

alter table users add column if not exists permissions text;

create table if not exists expense_details (
  journal_entry_id    text primary key references journal_entries (id) on delete cascade,
  store_id            text not null references stores (id) on delete cascade,
  expense_group       text not null check (expense_group in ('fixed', 'variable', 'negligible', 'custom')),
  category            text not null,
  amount_minor_units  bigint not null,
  entry_date          timestamptz not null default now()
);
create index if not exists idx_expense_details_store_date on expense_details (store_id, entry_date);

alter table expense_details enable row level security;
create policy "tenant select" on expense_details for select using (store_id = current_store_id() or is_developer_admin());
create policy "tenant insert" on expense_details for insert with check (store_id = current_store_id() or is_developer_admin());
create policy "tenant update" on expense_details for update using (store_id = current_store_id() or is_developer_admin()) with check (store_id = current_store_id() or is_developer_admin());
create policy "tenant delete" on expense_details for delete using (store_id = current_store_id() or is_developer_admin());
alter publication supabase_realtime add table public.expense_details;

alter table activation_codes drop constraint if exists activation_codes_tier_check;
alter table activation_codes add constraint activation_codes_tier_check
  check (tier in ('trial1Month', 'months3', 'months6', 'months12', 'lifetime', 'trial2Weeks'));

create or replace function set_store_trial_expiry()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  if new.expires_at is null and new.activation_status = 'pending' then
    new.expires_at := now() + interval '14 days';
  end if;
  return new;
end;
$$;

drop trigger if exists trg_store_trial_expiry on stores;
create trigger trg_store_trial_expiry before insert on stores
  for each row execute function set_store_trial_expiry();

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

  -- A registered customer chosen at the till (instead of a walk-in): the
  -- sale and, for pay-later, its debt belong to that customer.
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

  -- Loyalty: redeem the points the till applied as a discount, then earn
  -- points on what was actually paid. Any failure here (unknown customer,
  -- not enough points) rolls back the whole sale.
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
