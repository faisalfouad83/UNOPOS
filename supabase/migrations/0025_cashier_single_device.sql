-- A cashier account works on one device at a time. Signing in claims the
-- account for that device; another device is refused until the cashier
-- signs out there, or the owner / a manager releases it. The same device
-- signing in again (e.g. after a crash) is always fine. Other roles are
-- not limited.

create table if not exists employee_device_sessions (
  user_id       text primary key references users (id) on delete cascade,
  store_id      text not null references stores (id) on delete cascade,
  device_id     text,
  device_name   text,
  claimed_at    timestamptz,
  released_at   timestamptz
);

alter table employee_device_sessions enable row level security;

-- Read: the store itself (and developers). Writes only through the
-- functions below.
create policy "tenant select" on employee_device_sessions
  for select using (store_id = current_store_id() or is_developer_admin());

-- Claim [p_employee_id] for this device after its PIN. Returns
-- {"ok": true} or {"ok": false, "device_name": ..., "since": ...}.
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

-- Signing out on the device that holds the account frees it.
create or replace function release_employee_device(p_employee_id text, p_device_id text)
returns void
language sql
security definer
set search_path = public
as $$
  update employee_device_sessions
  set device_id = null, device_name = null, released_at = now()
  where user_id = p_employee_id
    and store_id = current_store_id()
    and device_id = p_device_id;
$$;

grant execute on function release_employee_device(text, text) to authenticated;

-- The owner or a manager frees an account held by another device (left
-- open, broken, lost). They confirm with their own PIN; audited.
create or replace function force_release_employee_device(p_employee_id text, p_actor_id text, p_actor_pin text)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_store_id text := current_store_id();
  v_actor users;
  v_row employee_device_sessions;
begin
  if v_store_id is null then
    raise exception 'must be signed in as a store';
  end if;
  v_actor := employee_with_pin(p_actor_id, p_actor_pin);
  if v_actor.id is null then
    raise exception 'wrong PIN';
  end if;
  if v_actor.role not in ('owner', 'manager') then
    raise exception 'not allowed';
  end if;
  select * into v_row from employee_device_sessions
  where user_id = p_employee_id and store_id = v_store_id for update;
  if v_row.device_id is null then
    return;
  end if;
  update employee_device_sessions
  set device_id = null, device_name = null, released_at = now()
  where user_id = p_employee_id;

  insert into audit_logs (store_id, user_id, action, entity_type, entity_id, before_value_json, after_value_json)
  values (v_store_id, v_actor.id, 'employee.device_release', 'user', p_employee_id,
          jsonb_build_object('device_name', v_row.device_name, 'since', v_row.claimed_at)::text,
          null);
end;
$$;

grant execute on function force_release_employee_device(text, text, text) to authenticated;

alter publication supabase_realtime add table employee_device_sessions;
