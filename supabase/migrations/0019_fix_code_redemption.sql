-- Redeeming a code never actually activated the store: the row-protection
-- trigger below silently put activation_status / expires_at back, because
-- it only trusted developer sessions. The code was still marked used, so a
-- store ended up locked with its codes spent.
--
-- Fix: trusted server functions raise a transaction-local flag before they
-- touch those columns, and the trigger honours it. Clients can't set it —
-- set_config isn't reachable through the API.

create or replace function protect_store_privileged_columns()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if is_developer_admin() or current_setting('unopos.license_update', true) = 'on' then
    return new;
  end if;
  new.plan_id := old.plan_id;
  new.subscription_status := old.subscription_status;
  new.activation_status := old.activation_status;
  new.license_key := old.license_key;
  new.activation_code_id := old.activation_code_id;
  new.is_disabled := old.is_disabled;
  new.is_suspended := old.is_suspended;
  new.expires_at := old.expires_at;
  new.store_login_id := old.store_login_id;
  new.auth_user_id := old.auth_user_id;
  return new;
end;
$$;

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
  -- Entering the same code again on the store that already used it just
  -- re-applies it (e.g. the first attempt's screen never moved on).
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
        subscription_status = 'active'
    where id = v_store_id
    returning * into v_store;
  perform set_config('unopos.license_update', 'off', true);

  return v_store;
end;
$$;
