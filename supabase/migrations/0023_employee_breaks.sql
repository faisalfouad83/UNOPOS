-- Employee breaks: an employee steps away without closing their shift. The
-- till is locked while they're away and only their own PIN ends the break.
-- Limits (on/off, minutes per break, breaks per day, which roles) are store
-- settings, enforced here so they hold whatever the client sends.

alter table app_settings add column if not exists break_enabled boolean not null default false;
alter table app_settings add column if not exists break_max_minutes integer not null default 15;
alter table app_settings add column if not exists break_max_per_day integer not null default 2;
alter table app_settings add column if not exists break_roles text not null default 'cashier,warehouseManager';

create table if not exists employee_breaks (
  id                text primary key default gen_random_uuid()::text,
  store_id          text not null references stores (id) on delete cascade,
  branch_id         text references branches (id) on delete set null,
  user_id           text not null references users (id) on delete restrict,
  shift_id          text references shifts (id) on delete set null,
  started_at        timestamptz not null default now(),
  ended_at          timestamptz,
  allowed_minutes   integer not null,
  end_kind          text check (end_kind in ('returned', 'early', 'reconciled')),
  exceeded_minutes  integer not null default 0
);

create index if not exists idx_employee_breaks_store_day on employee_breaks (store_id, started_at desc);
create index if not exists idx_employee_breaks_user_open on employee_breaks (user_id) where ended_at is null;

alter table employee_breaks enable row level security;

-- Read: the store itself (and developers). Writes only through the
-- functions below — there is no insert/update policy.
create policy "tenant select" on employee_breaks
  for select using (store_id = current_store_id() or is_developer_admin());

-- "Today" is the store's day in Iraq.
create or replace function store_today_start()
returns timestamptz
language sql
stable
as $$
  select (date_trunc('day', now() at time zone 'Asia/Baghdad')) at time zone 'Asia/Baghdad';
$$;

create or replace function start_break(p_user_id text, p_branch_id text default null, p_shift_id text default null)
returns employee_breaks
language plpgsql
security definer
set search_path = public
as $$
declare
  v_store_id text := current_store_id();
  v_user users;
  v_settings app_settings;
  v_count integer;
  v_break employee_breaks;
begin
  if v_store_id is null then
    raise exception 'must be signed in as a store';
  end if;
  select * into v_user from users where id = p_user_id and store_id = v_store_id and is_active;
  if v_user.id is null then
    raise exception 'employee not found';
  end if;
  if p_branch_id is not null and not exists (select 1 from branches where id = p_branch_id and store_id = v_store_id) then
    raise exception 'branch does not belong to this store';
  end if;
  select * into v_settings from app_settings where store_id = v_store_id;
  if v_settings.store_id is null or not v_settings.break_enabled then
    raise exception 'breaks are off';
  end if;
  if not (v_user.role = any (string_to_array(v_settings.break_roles, ','))) then
    raise exception 'breaks not allowed for this role';
  end if;
  if exists (select 1 from employee_breaks where user_id = p_user_id and ended_at is null) then
    raise exception 'already on a break';
  end if;
  select count(*) into v_count from employee_breaks
    where user_id = p_user_id and started_at >= store_today_start();
  if v_count >= v_settings.break_max_per_day then
    raise exception 'no breaks left today';
  end if;

  insert into employee_breaks (store_id, branch_id, user_id, shift_id, allowed_minutes)
  values (v_store_id, p_branch_id, p_user_id, p_shift_id, v_settings.break_max_minutes)
  returning * into v_break;
  return v_break;
end;
$$;

grant execute on function start_break(text, text, text) to authenticated;

-- Ends a break. Only the employee who took it can end it, with their own
-- PIN. p_reconciled marks a break closed after the app was shut while the
-- employee was away (it ends when they next sign in).
create or replace function end_break(p_break_id text, p_pin text, p_reconciled boolean default false)
returns employee_breaks
language plpgsql
security definer
set search_path = public
as $$
declare
  v_store_id text := current_store_id();
  v_break employee_breaks;
  v_minutes integer;
begin
  if v_store_id is null then
    raise exception 'must be signed in as a store';
  end if;
  select * into v_break from employee_breaks where id = p_break_id and store_id = v_store_id for update;
  if v_break.id is null then
    raise exception 'break not found';
  end if;
  if v_break.ended_at is not null then
    return v_break;
  end if;
  if (employee_with_pin(v_break.user_id, p_pin)).id is null then
    raise exception 'wrong PIN';
  end if;

  v_minutes := ceil(extract(epoch from (now() - v_break.started_at)) / 60.0);
  update employee_breaks set
    ended_at = now(),
    exceeded_minutes = greatest(0, v_minutes - allowed_minutes),
    end_kind = case
      when p_reconciled then 'reconciled'
      when now() - started_at < make_interval(mins => allowed_minutes) then 'early'
      else 'returned' end
  where id = v_break.id
  returning * into v_break;
  return v_break;
end;
$$;

grant execute on function end_break(text, text, boolean) to authenticated;
