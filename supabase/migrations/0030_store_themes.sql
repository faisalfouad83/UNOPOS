-- =============================================================================
-- UNOPOS — Store themes (twelve looks) and developer theme assignments
-- =============================================================================
-- 1. app_settings.theme_key: the store's own theme choice. One of the twelve
--    theme keys, 'system' (Light or Dark following the device), or null for
--    "Automatic" (the developer's assignment, else Light). theme_mode stays
--    for older app versions; new apps keep it in step (dark theme -> 'dark',
--    light theme -> 'light', Automatic/'system' -> 'system').
-- 2. theme_assignments: themes the developer sets for every store
--    (scope = 'global') or for one store (scope = that store's id), each
--    optionally locked so the store can't choose another. The server is the
--    authority: only developer admins write; a store reads the global row
--    and its own row.
--
-- Precedence in the app (lib/core/theming/theme_resolution.dart):
--   locked developer assignment (the store's own row, else the global row)
--   > the store's own choice > developer assignment (store row, then
--   global) > Light.
--
-- There is no grouping of stores in UNOPOS, so there are no group scopes.
-- Idempotent: safe to run more than once. No rows are removed.
-- =============================================================================

-- 1. The store's own choice ----------------------------------------------------

alter table app_settings add column if not exists theme_key text;

do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conname = 'app_settings_theme_key_check' and conrelid = 'public.app_settings'::regclass
  ) then
    alter table app_settings add constraint app_settings_theme_key_check check (
      theme_key is null or theme_key in (
        'system',
        'light', 'dark', 'christmas', 'halloween', 'eid_al_fitr', 'eid_al_adha',
        'nowruz', 'ramadan', 'summer', 'autumn', 'spring', 'winter'
      )
    );
  end if;
end $$;

-- 2. Developer assignments -------------------------------------------------

create table if not exists theme_assignments (
  -- 'global' or a store id; one row per scope.
  scope       text primary key,
  -- The store, for a store row (null for the global row). Removing a store
  -- removes its assignment.
  store_id    text references stores(id) on delete cascade,
  theme_key   text not null,
  locked      boolean not null default false,
  updated_at  timestamptz not null default now(),
  updated_by  uuid default auth.uid(),
  constraint theme_assignments_theme_key_check check (theme_key in (
    'light', 'dark', 'christmas', 'halloween', 'eid_al_fitr', 'eid_al_adha',
    'nowruz', 'ramadan', 'summer', 'autumn', 'spring', 'winter'
  )),
  constraint theme_assignments_scope_check check (
    (scope = 'global' and store_id is null) or (scope <> 'global' and store_id = scope)
  )
);

create index if not exists theme_assignments_store_idx on theme_assignments(store_id);

-- Who changed it and when is stamped by the server, not trusted from the
-- client.
create or replace function theme_assignments_stamp()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  new.updated_at := now();
  new.updated_by := auth.uid();
  return new;
end;
$$;

create or replace trigger theme_assignments_stamp
  before insert or update on theme_assignments
  for each row execute function theme_assignments_stamp();

alter table theme_assignments enable row level security;

revoke all on theme_assignments from anon;
revoke all on theme_assignments from public;
grant select, insert, update, delete on theme_assignments to authenticated;

do $$
begin
  -- A store reads the global row and its own; developer admins read all.
  if not exists (select 1 from pg_policies where tablename = 'theme_assignments' and policyname = 'theme assignments: read') then
    create policy "theme assignments: read" on theme_assignments
      for select to authenticated
      using (is_developer_admin() or scope = 'global' or store_id = current_store_id());
  end if;
  -- Only developer admins add, change or remove assignments.
  if not exists (select 1 from pg_policies where tablename = 'theme_assignments' and policyname = 'theme assignments: developers add') then
    create policy "theme assignments: developers add" on theme_assignments
      for insert to authenticated
      with check (is_developer_admin());
  end if;
  if not exists (select 1 from pg_policies where tablename = 'theme_assignments' and policyname = 'theme assignments: developers change') then
    create policy "theme assignments: developers change" on theme_assignments
      for update to authenticated
      using (is_developer_admin())
      with check (is_developer_admin());
  end if;
  if not exists (select 1 from pg_policies where tablename = 'theme_assignments' and policyname = 'theme assignments: developers remove') then
    create policy "theme assignments: developers remove" on theme_assignments
      for delete to authenticated
      using (is_developer_admin());
  end if;
end $$;

-- Live updates to the store apps (supabase_flutter .stream()).
do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'theme_assignments'
  ) then
    alter publication supabase_realtime add table public.theme_assignments;
  end if;
end $$;
