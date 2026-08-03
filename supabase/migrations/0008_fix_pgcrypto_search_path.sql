-- =============================================================================
-- UNOPOS — Fix: pgcrypto functions not found (gen_salt/crypt)
-- =============================================================================
-- Supabase pre-installs pgcrypto into a dedicated `extensions` schema, not
-- `public` (this is Supabase's own default project setup, not something
-- 0001's `create extension if not exists pgcrypto` controls — it was
-- already installed there before that statement ever ran, so `if not
-- exists` made it a no-op). Every function below set `search_path =
-- public` only, so `gen_salt()`/`crypt()` couldn't be found at all —
-- "function gen_salt(unknown) does not exist". Fixed by adding the
-- `extensions` schema to search_path (harmless if pgcrypto happens to
-- already be in `public` on a different project — it just becomes
-- redundant there, not wrong).
-- =============================================================================

create or replace function create_employee(
  p_branch_id text,
  p_name text,
  p_role text,
  p_pin text,
  p_phone text default '',
  p_address text default '',
  p_salary_minor_units bigint default 0,
  p_allowances_minor_units bigint default 0,
  p_avatar_color_hex text default '#0F6E5C'
)
returns users
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  v_store_id text := current_store_id();
  v_user users;
begin
  if v_store_id is null then
    raise exception 'must be signed in as a store to create an employee';
  end if;
  if p_branch_id is not null and not exists (select 1 from branches where id = p_branch_id and store_id = v_store_id) then
    raise exception 'branch does not belong to this store';
  end if;

  insert into users (store_id, branch_id, name, role, phone, address, salary_minor_units, allowances_minor_units, avatar_color_hex)
  values (v_store_id, p_branch_id, p_name, p_role, p_phone, p_address, p_salary_minor_units, p_allowances_minor_units, p_avatar_color_hex)
  returning * into v_user;

  insert into employee_credentials (user_id, store_id, pin_hash)
  values (v_user.id, v_store_id, crypt(p_pin, gen_salt('bf')));

  return v_user;
end;
$$;

create or replace function update_employee_pin(p_user_id text, p_new_pin text)
returns void
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  v_store_id text := current_store_id();
begin
  if v_store_id is null then
    raise exception 'must be signed in as a store to update an employee pin';
  end if;
  if not exists (select 1 from users where id = p_user_id and store_id = v_store_id) then
    raise exception 'employee does not belong to this store';
  end if;

  update employee_credentials set pin_hash = crypt(p_new_pin, gen_salt('bf')), updated_at = now()
  where user_id = p_user_id;
end;
$$;

create or replace function verify_employee_pin(p_pin text)
returns users
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  v_store_id text := current_store_id();
  v_user users;
begin
  if v_store_id is null then
    raise exception 'must be signed in as a store to verify an employee pin';
  end if;

  select u.* into v_user
  from users u
  join employee_credentials c on c.user_id = u.id
  where u.store_id = v_store_id
    and u.is_active
    and c.pin_hash = crypt(p_pin, c.pin_hash)
  limit 1;

  if not found then
    return null;
  end if;

  return v_user;
end;
$$;

create or replace function developer_reset_store_password(p_store_id text, p_new_password text)
returns void
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  v_auth_user_id uuid;
begin
  if not is_developer_admin() then
    raise exception 'only a developer admin may reset a store password';
  end if;

  select auth_user_id into v_auth_user_id from stores where id = p_store_id;
  if v_auth_user_id is null then
    raise exception 'store not found';
  end if;

  update auth.users
    set encrypted_password = crypt(p_new_password, gen_salt('bf')),
        updated_at = now()
    where id = v_auth_user_id;
end;
$$;
