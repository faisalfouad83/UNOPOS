-- =============================================================================
-- UNOPOS 0031 — activation codes carry a plan; plan entitlements; accounting
-- totals for the owner's accounting screens.
-- =============================================================================
--
-- Part A — plans on activation codes
--   * subscription_plans gains `features` (which app sections the plan
--     includes: {"accounting": false} switches that section off; a section
--     not named is included) and `max_devices` (how many tills may have a
--     cashier signed in at the same time; null = no limit).
--   * activation_codes gains `plan_id` (the plan the code switches the store
--     to; null = the store keeps its plan, as codes issued before this did)
--     and `target_store_id` (when set, only that store may use the code).
--   * record_activation_code takes the plan and target store (both
--     optional, so older Developer Consoles keep working) and checks the
--     end date matches the duration.
--   * redeem_activation_code / developer_assign_license apply the code's
--     plan together with its end date, in the same transaction, and refuse
--     a code meant for another store.
--   * store_entitlement() tells a signed-in store its plan, limits, the
--     sections it includes, its end date and how much of each limit it uses.
--   * claim_employee_device refuses a new till once the plan's device limit
--     is reached (the same device signing in again is always fine).
--
-- Part B — accounting
--   * account_totals(p_from, p_to): per account, the debits and credits in
--     [p_from, p_to) and the running totals up to p_to (for balances).
--   * account_movements_by_reference(p_from, p_to, p_codes): debits and
--     credits on the given accounts (default: cash 1000 and bank 1010) in
--     [p_from, p_to), split by what caused them (SALE, EXPENSE, ...) — the
--     direct-method cash flow statement.
--   Both read only the signed-in store's journal (current_store_id()), so a
--   client no longer needs to download every journal line to add them up.
-- =============================================================================

-- ---------------------------------------------------------------------------
-- A1. Plan columns
-- ---------------------------------------------------------------------------
alter table subscription_plans add column if not exists features jsonb not null default '{}'::jsonb;
alter table subscription_plans add column if not exists max_devices integer;

-- Device limits for the four existing plans (no store today uses more than
-- one or two tills). Every section stays included ('{}') until a developer
-- switches one off in the Developer Console, so no store loses anything
-- when this migration runs.
update subscription_plans set max_devices = 2 where id = 'starter' and max_devices is null;
update subscription_plans set max_devices = 5 where id = 'standard' and max_devices is null;
update subscription_plans set max_devices = 20 where id = 'professional' and max_devices is null;
-- enterprise: no device limit (null).

-- ---------------------------------------------------------------------------
-- A2. Activation code columns
-- ---------------------------------------------------------------------------
alter table activation_codes add column if not exists plan_id text references subscription_plans (id) on delete restrict;
alter table activation_codes add column if not exists target_store_id text references stores (id) on delete set null;

-- ---------------------------------------------------------------------------
-- A3. record_activation_code: plan + target store, validated here
-- ---------------------------------------------------------------------------
drop function if exists record_activation_code(text, text, text, timestamptz);

create or replace function record_activation_code(
  p_code text,
  p_store_name_ref text,
  p_tier text,
  p_expires_at timestamptz,
  p_plan_id text default null,
  p_target_store_id text default null
)
returns activation_codes
language plpgsql
security definer
set search_path = public
as $$
declare
  v_admin_id text;
  v_days integer;
  v_row activation_codes;
begin
  select id into v_admin_id from developer_admins where auth_user_id = auth.uid();
  if v_admin_id is null then
    raise exception 'only a developer admin may issue activation codes';
  end if;

  if p_plan_id is not null
     and not exists (select 1 from subscription_plans where id = p_plan_id and is_active) then
    raise exception 'unknown or inactive plan %', p_plan_id;
  end if;
  if p_target_store_id is not null and not exists (select 1 from stores where id = p_target_store_id) then
    raise exception 'unknown store %', p_target_store_id;
  end if;

  -- The end date must be what the duration gives, counted from today (a
  -- day either side for time zones); lifetime codes have none.
  v_days := case p_tier
    when 'trial2Weeks' then 14
    when 'trial1Month' then 30
    when 'months3' then 90
    when 'months6' then 182
    when 'months12' then 365
    when 'lifetime' then null
    else -1
  end;
  if v_days = -1 then
    raise exception 'unknown duration %', p_tier;
  end if;
  if v_days is null and p_expires_at is not null then
    raise exception 'a lifetime code has no end date';
  end if;
  if v_days is not null and (
       p_expires_at is null
       or p_expires_at < now() + make_interval(days => v_days - 2)
       or p_expires_at > now() + make_interval(days => v_days + 2)) then
    raise exception 'end date does not match the % duration', p_tier;
  end if;

  insert into activation_codes (code, store_name_ref, tier, expires_at, issued_by_admin_id, plan_id, target_store_id)
  values (upper(trim(p_code)), p_store_name_ref, p_tier, p_expires_at, v_admin_id, p_plan_id, p_target_store_id)
  returning * into v_row;

  insert into platform_audit_logs (admin_id, action, target_store_id, details_json)
  values (v_admin_id, 'license.issue', p_target_store_id,
          jsonb_build_object('code_id', v_row.id, 'tier', p_tier, 'plan_id', p_plan_id,
                             'expires_at', p_expires_at, 'store_name_ref', p_store_name_ref)::text);
  return v_row;
end;
$$;

revoke all on function record_activation_code(text, text, text, timestamptz, text, text) from public, anon;
grant execute on function record_activation_code(text, text, text, timestamptz, text, text) to authenticated;

-- ---------------------------------------------------------------------------
-- A4. Redeeming applies the plan and the end date together
-- ---------------------------------------------------------------------------
create or replace function redeem_activation_code(p_code text)
returns stores
language plpgsql
security definer
set search_path = public
as $$
declare
  v_store_id text := current_store_id();
  v_code activation_codes;
  v_store stores;
begin
  if v_store_id is null then
    raise exception 'must be signed in as a store to redeem an activation code';
  end if;

  select * into v_code from activation_codes where code = upper(trim(p_code)) for update;
  if v_code.id is null then
    raise exception 'invalid activation code';
  end if;
  if v_code.status = 'revoked' then
    raise exception 'activation code revoked';
  end if;
  if v_code.target_store_id is not null and v_code.target_store_id <> v_store_id then
    raise exception 'activation code is for another store';
  end if;
  if v_code.status <> 'unused' and v_code.redeemed_by_store_id is distinct from v_store_id then
    raise exception 'activation code already %', v_code.status;
  end if;

  update activation_codes
    set status = 'active', redeemed_by_store_id = v_store_id, redeemed_at = coalesce(redeemed_at, now())
    where id = v_code.id;

  perform set_config('unopos.license_update', 'on', true);
  update stores
    set activation_status = 'active',
        activation_code_id = v_code.id,
        license_key = coalesce(license_key, generate_license_key()),
        expires_at = v_code.expires_at,
        plan_id = coalesce(v_code.plan_id, plan_id),
        subscription_status = 'active'
    where id = v_store_id
    returning * into v_store;
  perform set_config('unopos.license_update', 'off', true);

  return v_store;
end;
$$;

create or replace function developer_assign_license(p_store_id text, p_code text)
returns stores
language plpgsql
security definer
set search_path = public
as $$
declare
  v_code activation_codes;
  v_store stores;
begin
  if not is_developer_admin() then
    raise exception 'only a developer admin may assign a license';
  end if;

  select * into v_code from activation_codes where code = upper(trim(p_code)) for update;
  if v_code.id is null then
    raise exception 'invalid activation code';
  end if;
  if v_code.status <> 'unused' then
    raise exception 'activation code already %', v_code.status;
  end if;
  if v_code.target_store_id is not null and v_code.target_store_id <> p_store_id then
    raise exception 'activation code is for another store';
  end if;
  if not exists (select 1 from stores where id = p_store_id) then
    raise exception 'unknown store %', p_store_id;
  end if;

  update activation_codes
    set status = 'active', redeemed_by_store_id = p_store_id, redeemed_at = now()
    where id = v_code.id;

  update stores set
    activation_status = 'active',
    activation_code_id = v_code.id,
    license_key = coalesce(license_key, generate_license_key()),
    expires_at = v_code.expires_at,
    plan_id = coalesce(v_code.plan_id, plan_id),
    subscription_status = 'active'
  where id = p_store_id
  returning * into v_store;

  insert into platform_audit_logs (admin_id, action, target_store_id, details_json)
  values (current_developer_admin_id(), 'license.assign', p_store_id,
          jsonb_build_object('code_id', v_code.id, 'plan_id', v_code.plan_id, 'expires_at', v_code.expires_at)::text);

  return v_store;
end;
$$;

-- ---------------------------------------------------------------------------
-- A5. What the signed-in store's plan gives it
-- ---------------------------------------------------------------------------
create or replace function store_entitlement()
returns jsonb
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  v_store stores;
  v_plan subscription_plans;
begin
  select * into v_store from stores where id = current_store_id();
  if v_store.id is null then
    raise exception 'must be signed in as a store';
  end if;
  select * into v_plan from subscription_plans where id = v_store.plan_id;

  return jsonb_build_object(
    'plan_id', v_store.plan_id,
    'plan_name', coalesce(v_plan.name, v_store.plan_id),
    'features', coalesce(v_plan.features, '{}'::jsonb),
    'limits', jsonb_build_object(
      'employees', v_plan.max_employees,
      'branches', v_plan.max_branches,
      'products', v_plan.max_products,
      'devices', v_plan.max_devices,
      'daily_transactions', v_plan.max_daily_transactions
    ),
    'usage', jsonb_build_object(
      'employees', (select count(*) from users where store_id = v_store.id),
      'branches', (select count(*) from branches where store_id = v_store.id),
      'products', (select count(*) from products where store_id = v_store.id),
      'devices', (select count(distinct device_id) from employee_device_sessions
                  where store_id = v_store.id and device_id is not null),
      'daily_transactions', (select count(*) from sales
                             where store_id = v_store.id and created_at >= date_trunc('day', now()))
    ),
    'expires_at', v_store.expires_at,
    'activation_status', v_store.activation_status,
    'subscription_status', v_store.subscription_status,
    'is_disabled', v_store.is_disabled,
    'is_suspended', v_store.is_suspended,
    'server_time', now()
  );
end;
$$;

revoke all on function store_entitlement() from public, anon;
grant execute on function store_entitlement() to authenticated;

-- ---------------------------------------------------------------------------
-- A6. Device limit: a cashier signing in on one more till than the plan
--     allows is refused with {"ok": false, "reason": "plan_device_limit"}.
-- ---------------------------------------------------------------------------
create or replace function claim_employee_device(
  p_employee_id text,
  p_pin text,
  p_device_id text,
  p_device_name text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_emp users;
  v_row employee_device_sessions;
  v_limit integer;
  v_in_use integer;
begin
  if coalesce(p_device_id, '') = '' then
    raise exception 'device id required';
  end if;
  v_emp := employee_with_pin(p_employee_id, p_pin);
  if v_emp.id is null then
    raise exception 'wrong PIN';
  end if;
  if v_emp.role <> 'cashier' then
    return jsonb_build_object('ok', true);
  end if;

  select * into v_row from employee_device_sessions where user_id = v_emp.id for update;
  if v_row.device_id is not null and v_row.device_id <> p_device_id then
    return jsonb_build_object('ok', false, 'device_name', v_row.device_name, 'since', v_row.claimed_at);
  end if;

  -- A till already in use (by any cashier of this store) never counts twice.
  select sp.max_devices into v_limit
  from stores s join subscription_plans sp on sp.id = s.plan_id
  where s.id = v_emp.store_id;
  if v_limit is not null and not exists (
       select 1 from employee_device_sessions
       where store_id = v_emp.store_id and device_id = p_device_id) then
    -- Serialise concurrent claims for the same store.
    perform 1 from stores where id = v_emp.store_id for update;
    select count(distinct device_id) into v_in_use
    from employee_device_sessions
    where store_id = v_emp.store_id and device_id is not null and user_id <> v_emp.id;
    if v_in_use >= v_limit then
      return jsonb_build_object('ok', false, 'reason', 'plan_device_limit', 'limit', v_limit);
    end if;
  end if;

  insert into employee_device_sessions (user_id, store_id, device_id, device_name, claimed_at, released_at)
  values (v_emp.id, v_emp.store_id, p_device_id, left(p_device_name, 80), now(), null)
  on conflict (user_id) do update
    set device_id = excluded.device_id,
        device_name = excluded.device_name,
        claimed_at = case when employee_device_sessions.device_id = excluded.device_id
                          then employee_device_sessions.claimed_at else now() end,
        released_at = null;
  return jsonb_build_object('ok', true);
end;
$$;

grant execute on function claim_employee_device(text, text, text, text) to authenticated;

-- ---------------------------------------------------------------------------
-- B1. Accounting totals per account
-- ---------------------------------------------------------------------------
create index if not exists idx_journal_entries_store_date on journal_entries (store_id, entry_date);

-- Every account of the signed-in store (also ones with no entries), with
--   period_debit / period_credit:  lines dated p_from <= entry_date < p_to
--   closing_debit / closing_credit: lines dated before p_to (all history)
-- p_from null = from the first entry; p_to null = now. Amounts are minor
-- units; the client works out balances by account type.
create or replace function account_totals(p_from timestamptz default null, p_to timestamptz default null)
returns table (
  account_code text,
  account_name text,
  account_type text,
  period_debit bigint,
  period_credit bigint,
  closing_debit bigint,
  closing_credit bigint
)
language sql
stable
security definer
set search_path = public
as $$
  with store as (
    select current_store_id() as id, coalesce(p_to, now()) as to_at
  ),
  sums as (
    select
      jl.account_id,
      sum(case when p_from is null or je.entry_date >= p_from then jl.debit_minor_units else 0 end) as period_debit,
      sum(case when p_from is null or je.entry_date >= p_from then jl.credit_minor_units else 0 end) as period_credit,
      sum(jl.debit_minor_units) as closing_debit,
      sum(jl.credit_minor_units) as closing_credit
    from journal_lines jl
    join journal_entries je on je.id = jl.journal_entry_id
    cross join store
    where jl.store_id = store.id
      and je.store_id = store.id
      and je.entry_date < store.to_at
    group by jl.account_id
  )
  select
    coa.code,
    coa.name,
    coa.type,
    coalesce(s.period_debit, 0)::bigint,
    coalesce(s.period_credit, 0)::bigint,
    coalesce(s.closing_debit, 0)::bigint,
    coalesce(s.closing_credit, 0)::bigint
  from chart_of_accounts coa
  cross join store
  left join sums s on s.account_id = coa.id
  where coa.store_id = store.id
  order by coa.code;
$$;

revoke all on function account_totals(timestamptz, timestamptz) from public, anon;
grant execute on function account_totals(timestamptz, timestamptz) to authenticated;

-- ---------------------------------------------------------------------------
-- B2. Movements on chosen accounts by what caused them (cash flow)
-- ---------------------------------------------------------------------------
create or replace function account_movements_by_reference(
  p_from timestamptz default null,
  p_to timestamptz default null,
  p_codes text[] default array['1000', '1010']
)
returns table (account_code text, reference_type text, debit bigint, credit bigint)
language sql
stable
security definer
set search_path = public
as $$
  select coa.code, je.reference_type, sum(jl.debit_minor_units)::bigint, sum(jl.credit_minor_units)::bigint
  from journal_lines jl
  join journal_entries je on je.id = jl.journal_entry_id
  join chart_of_accounts coa on coa.id = jl.account_id
  where jl.store_id = current_store_id()
    and je.store_id = current_store_id()
    and coa.code = any (coalesce(p_codes, array['1000', '1010']))
    and (p_from is null or je.entry_date >= p_from)
    and je.entry_date < coalesce(p_to, now())
  group by coa.code, je.reference_type
  order by coa.code, je.reference_type;
$$;

revoke all on function account_movements_by_reference(timestamptz, timestamptz, text[]) from public, anon;
grant execute on function account_movements_by_reference(timestamptz, timestamptz, text[]) to authenticated;
