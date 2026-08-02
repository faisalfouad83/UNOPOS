-- =============================================================================
-- UNOPOS — Phase H3: Developer Console support functions
-- =============================================================================
-- Most Developer Console actions need no new SQL at all: the `stores` RLS
-- policies from 0001 already give a signed-in developer_admin full
-- select/update/delete access to every store row (view, edit, activate,
-- deactivate, suspend, delete, extend subscription are all plain
-- `.from('stores')` calls from the Flutter side), and
-- platform_notifications/notification_recipients are already
-- developer-writable. Only two actions genuinely need a SECURITY DEFINER
-- function: resetting a store's login password (touches the `auth` schema,
-- which no client role can reach directly) and assigning a license to a
-- store on the developer's initiative rather than the store's own
-- self-service redemption.
-- =============================================================================

-- Resets a store's login password without the Supabase Admin API (not
-- reachable from this sandbox — no Edge Functions deployed). Writes
-- directly into auth.users.encrypted_password using the same bcrypt format
-- GoTrue itself uses. This is a best-effort workaround, not the officially
-- documented path — verify it actually logs the store in successfully
-- against your real Supabase project before relying on it in production.
-- If Supabase changes its password-hashing internals this may need
-- revisiting; the fully-supported alternative is calling the Admin API's
-- updateUserById() from a trusted server context (e.g. an Edge Function),
-- once one can be deployed.
create or replace function developer_reset_store_password(p_store_id text, p_new_password text)
returns void
language plpgsql
security definer
set search_path = public
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

-- Assigns a previously-generated, still-unused activation code to a store
-- directly (vs. redeem_activation_code, which only the store's own session
-- can call for self-service redemption). Same redemption bookkeeping.
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

  select * into v_code from activation_codes where code = p_code for update;
  if v_code.id is null then
    raise exception 'invalid activation code';
  end if;
  if v_code.status <> 'unused' then
    raise exception 'activation code already %', v_code.status;
  end if;

  update activation_codes
    set status = 'active', redeemed_by_store_id = p_store_id, redeemed_at = now()
    where id = v_code.id;

  update stores set
    activation_status = 'active',
    activation_code_id = v_code.id,
    license_key = coalesce(license_key, generate_license_key()),
    expires_at = v_code.expires_at,
    subscription_status = 'active'
  where id = p_store_id
  returning * into v_store;

  return v_store;
end;
$$;
