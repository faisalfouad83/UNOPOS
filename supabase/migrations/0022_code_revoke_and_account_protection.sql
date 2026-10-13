-- Activation codes: developers can revoke a code or remove one that was
-- never used; a revoked code can never be redeemed. Every change is
-- written to the platform audit log.
--
-- Accounts: the owner's account can never be deactivated, demoted or
-- removed through the app; a manager only by the owner (checked with the
-- owner's PIN on the server); nobody can make themselves owner. Enforced by
-- triggers on `users`, so it holds whatever the client sends.

create or replace function current_developer_admin_id()
returns text
language sql
stable
security definer
set search_path = public
as $$
  select id from developer_admins where auth_user_id = auth.uid();
$$;

-- Revoke a code. An unused code simply can't be used any more. A code a
-- store already activated with is marked revoked; the store keeps its
-- current activation unless p_end_store_activation is true, in which case
-- that store (and only that store) is locked until it enters a new code.
create or replace function developer_revoke_activation_code(
  p_code_id text,
  p_end_store_activation boolean default false,
  p_reason text default null
)
returns activation_codes
language plpgsql
security definer
set search_path = public
as $$
declare
  v_code activation_codes;
begin
  if not is_developer_admin() then
    raise exception 'developer only';
  end if;
  select * into v_code from activation_codes where id = p_code_id for update;
  if v_code.id is null then
    raise exception 'activation code not found';
  end if;

  update activation_codes set status = 'revoked' where id = p_code_id returning * into v_code;

  if p_end_store_activation and v_code.redeemed_by_store_id is not null then
    perform set_config('unopos.license_update', 'on', true);
    update stores
      set expires_at = now(), activation_status = 'expired'
      where id = v_code.redeemed_by_store_id and activation_code_id = v_code.id;
    perform set_config('unopos.license_update', 'off', true);
  end if;

  insert into platform_audit_logs (admin_id, action, target_store_id, details_json)
  values (
    current_developer_admin_id(),
    'license.revoke',
    v_code.redeemed_by_store_id,
    jsonb_build_object('code_id', v_code.id, 'end_store_activation', p_end_store_activation, 'reason', p_reason)::text
  );
  return v_code;
end;
$$;

grant execute on function developer_revoke_activation_code(text, boolean, text) to authenticated;

-- Removing a code row is only allowed for codes no store ever used (the
-- RLS policy already limits it to developers); it is audited.
create or replace function guard_activation_code_removal()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if old.redeemed_by_store_id is not null
     or exists (select 1 from stores where activation_code_id = old.id) then
    raise exception 'this code was used by a store: revoke it instead';
  end if;
  insert into platform_audit_logs (admin_id, action, target_store_id, details_json)
  values (current_developer_admin_id(), 'license.remove', null,
          jsonb_build_object('code_id', old.id, 'store_name_ref', old.store_name_ref, 'status', old.status)::text);
  return old;
end;
$$;

create trigger trg_guard_activation_code_removal
  before delete on activation_codes
  for each row execute function guard_activation_code_removal();

-- Redeeming: a revoked code is refused, even for the store it belonged to.
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

create or replace function activation_code_status(p_code text)
returns text
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  v_code activation_codes;
begin
  select * into v_code from activation_codes where code = upper(trim(p_code));
  if v_code.id is null then
    return 'invalid';
  end if;
  if v_code.status = 'revoked' then
    return 'revoked';
  end if;
  if v_code.status <> 'unused' then
    return 'used';
  end if;
  if v_code.expires_at is not null and v_code.expires_at <= now() then
    return 'expired';
  end if;
  return 'unused';
end;
$$;

-- ---------------------------------------------------------------------------
-- Account protection
-- ---------------------------------------------------------------------------

-- The signed-in store's active employee whose PIN this is (null otherwise).
-- Internal: only called by the functions below.
create or replace function employee_with_pin(p_employee_id text, p_pin text)
returns users
language plpgsql
stable
security definer
set search_path = public, extensions
as $$
declare
  v_user users;
begin
  select u.* into v_user
  from users u
  join employee_credentials c on c.user_id = u.id
  where u.id = p_employee_id
    and u.store_id = current_store_id()
    and u.is_active
    and c.pin_hash = crypt(p_pin, c.pin_hash);
  return v_user;
end;
$$;

revoke execute on function employee_with_pin(text, text) from public, anon, authenticated;

create or replace function protect_privileged_employees()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if coalesce(current_setting('unopos.employee_admin', true), 'off') = 'on' or is_developer_admin() then
    return case when tg_op = 'DELETE' then old else new end;
  end if;

  if tg_op = 'INSERT' then
    if new.role = 'owner' and exists (select 1 from users where store_id = new.store_id and role = 'owner' and is_active) then
      raise exception 'this store already has an owner';
    end if;
    return new;
  end if;

  if tg_op = 'DELETE' then
    if old.role in ('owner', 'manager') then
      raise exception 'owner and manager accounts cannot be removed this way';
    end if;
    return old;
  end if;

  -- UPDATE
  if old.role = 'owner' and (new.role <> 'owner' or (old.is_active and not new.is_active)) then
    raise exception 'the owner account cannot be deactivated or changed to another role';
  end if;
  if new.role = 'owner' and old.role <> 'owner' then
    raise exception 'ownership can only be transferred through a separate, authorised process';
  end if;
  if old.role = 'manager' and (new.role <> 'manager' or (old.is_active and not new.is_active)) then
    raise exception 'only the owner can deactivate or demote a manager';
  end if;
  if new.role = 'manager' and old.role <> 'manager' then
    raise exception 'only the owner can make someone a manager';
  end if;
  return new;
end;
$$;

create trigger trg_protect_privileged_employees
  before insert or update or delete on users
  for each row execute function protect_privileged_employees();

-- Deactivate an employee (their history stays; they just can't sign in).
-- The acting employee proves who they are with their own PIN:
--  * the owner account: never;
--  * a manager: only the owner, and never themselves;
--  * anyone else: the owner or a manager.
create or replace function deactivate_employee(p_employee_id text, p_actor_id text, p_actor_pin text)
returns users
language plpgsql
security definer
set search_path = public
as $$
declare
  v_store_id text := current_store_id();
  v_actor users;
  v_target users;
begin
  if v_store_id is null then
    raise exception 'must be signed in as a store';
  end if;
  v_actor := employee_with_pin(p_actor_id, p_actor_pin);
  if v_actor.id is null then
    raise exception 'wrong PIN';
  end if;
  select * into v_target from users where id = p_employee_id and store_id = v_store_id for update;
  if v_target.id is null then
    raise exception 'employee not found';
  end if;
  if v_target.role = 'owner' then
    raise exception 'the owner account cannot be deactivated';
  end if;
  if v_target.id = v_actor.id then
    raise exception 'you cannot deactivate your own account';
  end if;
  if v_target.role = 'manager' and v_actor.role <> 'owner' then
    raise exception 'only the owner can deactivate a manager';
  end if;
  if v_actor.role not in ('owner', 'manager') then
    raise exception 'not allowed';
  end if;

  perform set_config('unopos.employee_admin', 'on', true);
  update users set is_active = false where id = v_target.id returning * into v_target;
  perform set_config('unopos.employee_admin', 'off', true);

  insert into audit_logs (store_id, user_id, action, entity_type, entity_id, before_value_json, after_value_json)
  values (v_store_id, v_actor.id, 'employee.deactivate', 'user', v_target.id,
          jsonb_build_object('role', v_target.role, 'is_active', true)::text,
          jsonb_build_object('is_active', false)::text);
  return v_target;
end;
$$;

grant execute on function deactivate_employee(text, text, text) to authenticated;

-- Change an employee's role. Promoting to or demoting from manager needs
-- the owner; nobody becomes owner here.
create or replace function change_employee_role(p_employee_id text, p_new_role text, p_actor_id text, p_actor_pin text)
returns users
language plpgsql
security definer
set search_path = public
as $$
declare
  v_store_id text := current_store_id();
  v_actor users;
  v_target users;
  v_old_role text;
begin
  if v_store_id is null then
    raise exception 'must be signed in as a store';
  end if;
  if p_new_role not in ('manager', 'cashier', 'warehouseManager') then
    raise exception 'invalid role';
  end if;
  v_actor := employee_with_pin(p_actor_id, p_actor_pin);
  if v_actor.id is null then
    raise exception 'wrong PIN';
  end if;
  select * into v_target from users where id = p_employee_id and store_id = v_store_id for update;
  if v_target.id is null then
    raise exception 'employee not found';
  end if;
  if v_target.role = 'owner' then
    raise exception 'the owner account cannot be changed to another role';
  end if;
  if (v_target.role = 'manager' or p_new_role = 'manager') and v_actor.role <> 'owner' then
    raise exception 'only the owner can make or unmake a manager';
  end if;
  if v_actor.role not in ('owner', 'manager') then
    raise exception 'not allowed';
  end if;

  v_old_role := v_target.role;
  perform set_config('unopos.employee_admin', 'on', true);
  update users set role = p_new_role where id = v_target.id returning * into v_target;
  perform set_config('unopos.employee_admin', 'off', true);

  insert into audit_logs (store_id, user_id, action, entity_type, entity_id, before_value_json, after_value_json)
  values (v_store_id, v_actor.id, 'employee.role', 'user', v_target.id,
          jsonb_build_object('role', v_old_role)::text, jsonb_build_object('role', p_new_role)::text);
  return v_target;
end;
$$;

grant execute on function change_employee_role(text, text, text, text) to authenticated;
