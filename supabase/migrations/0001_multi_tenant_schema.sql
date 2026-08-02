-- =============================================================================
-- UNOPOS — Multi-Tenant SaaS Schema (Phase H1)
-- =============================================================================
-- One shared Postgres database serves every store. Isolation between stores
-- is enforced by Row-Level Security (RLS), not by application code — a bug in
-- the Flutter app cannot leak one store's data to another because Postgres
-- itself refuses the query. Read this file top to bottom before running it;
-- it is the single most security-critical file in the project.
--
-- Run this once against a fresh Supabase project's SQL editor (or via the
-- Supabase CLI: `supabase db push`). It is written to be idempotent-ish for
-- development (DROP ... IF EXISTS is deliberately NOT used on tables, so it
-- fails loudly instead of silently wiping data if re-run against a live DB).
--
-- Naming: every tenant table has a `store_id` column. RLS policies compare it
-- against the caller's own store via `stores.auth_user_id = auth.uid()`.
-- There are no employee-level Supabase Auth accounts — the STORE is the
-- authenticated principal (via Store ID + Password, mapped to a synthetic
-- email). Employees authenticate at the app layer via PIN, checked through
-- the `verify_employee_pin` SECURITY DEFINER function below, on top of an
-- already-authenticated store session.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 0. Extensions
-- -----------------------------------------------------------------------------
create extension if not exists pgcrypto; -- gen_random_uuid(), crypt(), gen_salt()

-- -----------------------------------------------------------------------------
-- 1. Helper functions used by RLS policies (defined early so policies can use them)
-- -----------------------------------------------------------------------------

-- True if the caller is a signed-in Developer (platform staff), never a store.
create or replace function is_developer_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from developer_admins d where d.auth_user_id = auth.uid()
  );
$$;

-- The store id owned by the calling authenticated session, or null if the
-- caller isn't a store (e.g. is a developer, or is unauthenticated).
create or replace function current_store_id()
returns text
language sql
stable
security definer
set search_path = public
as $$
  select id from stores where auth_user_id = auth.uid();
$$;

-- =============================================================================
-- 2. PLATFORM TABLES (not store-scoped — only Developer Console can touch these)
-- =============================================================================

create table subscription_plans (
  id                      text primary key,               -- 'starter' | 'standard' | 'professional' | 'enterprise'
  name                    text not null,
  max_employees           integer not null,
  max_branches            integer not null,
  max_products            integer not null,
  max_users               integer not null,
  max_warehouses          integer not null,
  max_storage_mb          integer not null,
  max_daily_transactions  integer not null,
  is_active               boolean not null default true,
  created_at              timestamptz not null default now()
);

create table stores (
  id                      text primary key default gen_random_uuid()::text,
  store_login_id          text not null unique,
  auth_user_id            uuid not null unique references auth.users (id) on delete cascade,
  display_name            text not null,
  owner_name              text not null default '',
  phone                   text not null default '',
  address                 text not null default '',
  currency_code           text not null default 'IQD',
  logo_url                text,
  settings                jsonb not null default '{}'::jsonb,

  plan_id                 text not null default 'starter' references subscription_plans (id) on delete restrict,
  subscription_status     text not null default 'trial',      -- trial/active/pastDue/cancelled
  activation_status       text not null default 'pending',    -- pending/active/expired/revoked
  license_key             text unique,                        -- UNO-XXXX-XXXX-XXXX, set on activation
  activation_code_id      text,                                -- fk added after activation_codes exists (below)

  is_disabled             boolean not null default false,      -- developer kill switch (login blocked)
  is_suspended            boolean not null default false,      -- developer soft-suspend (read-only / grace period)

  created_at              timestamptz not null default now(),
  expires_at              timestamptz,
  last_login_at           timestamptz
);

create table developer_admins (
  id            text primary key default gen_random_uuid()::text,
  auth_user_id  uuid not null unique references auth.users (id) on delete cascade,
  name          text not null,
  created_at    timestamptz not null default now()
);

create table activation_codes (
  id                    text primary key default gen_random_uuid()::text,
  code                  text not null unique,   -- full signed UNPS-...-... string (ActivationCodeCodec)
  store_name_ref        text not null,
  tier                  text not null check (tier in ('trial1Month','months3','months6','months12','lifetime')),
  issued_at             timestamptz not null default now(),
  expires_at            timestamptz,             -- null = lifetime
  status                text not null default 'unused' check (status in ('unused','active','expired','revoked')),
  redeemed_by_store_id  text references stores (id) on delete set null,
  redeemed_at           timestamptz,
  issued_by_admin_id    text references developer_admins (id) on delete set null
);

alter table stores
  add constraint stores_activation_code_id_fkey
  foreign key (activation_code_id) references activation_codes (id) on delete set null;

create table platform_notifications (
  id            text primary key default gen_random_uuid()::text,
  title         text not null,
  body          text not null,
  target_scope  text not null default 'all' check (target_scope in ('all','specific')),
  created_by_admin_id text references developer_admins (id) on delete set null,
  created_at    timestamptz not null default now()
);

create table notification_recipients (
  id                text primary key default gen_random_uuid()::text,
  notification_id   text not null references platform_notifications (id) on delete cascade,
  store_id          text not null references stores (id) on delete cascade,
  read_at           timestamptz,
  unique (notification_id, store_id)
);

create table platform_audit_logs (
  id              text primary key default gen_random_uuid()::text,
  admin_id        text references developer_admins (id) on delete set null,
  action          text not null,        -- e.g. 'store.suspend', 'license.generate'
  target_store_id text references stores (id) on delete set null,
  details_json    text,
  created_at      timestamptz not null default now()
);

-- -----------------------------------------------------------------------------
-- Platform table RLS — developer-only, nobody else can read or write these.
-- -----------------------------------------------------------------------------
alter table subscription_plans enable row level security;
alter table stores enable row level security;
alter table developer_admins enable row level security;
alter table activation_codes enable row level security;
alter table platform_notifications enable row level security;
alter table notification_recipients enable row level security;
alter table platform_audit_logs enable row level security;

-- subscription_plans: every authenticated store may read the plan catalogue
-- (needed to render "upgrade" screens); only developers may write.
create policy "plans readable by authenticated" on subscription_plans
  for select using (auth.role() = 'authenticated');
create policy "plans writable by developer" on subscription_plans
  for all using (is_developer_admin()) with check (is_developer_admin());

-- stores: a store may see/update only its own row; developers see/manage all.
-- Column-level protection of privileged fields (plan_id, license_key, status
-- flags) is enforced by the trigger further below, not by this policy.
create policy "store reads own row" on stores
  for select using (auth_user_id = auth.uid() or is_developer_admin());
create policy "store updates own row" on stores
  for update using (auth_user_id = auth.uid() or is_developer_admin())
  with check (auth_user_id = auth.uid() or is_developer_admin());
create policy "developer inserts stores" on stores
  for insert with check (is_developer_admin() or auth_user_id = auth.uid());
create policy "developer deletes stores" on stores
  for delete using (is_developer_admin());

-- developer_admins: only visible/manageable by other developers (bootstrapping
-- the very first row must be done from the Supabase SQL editor / dashboard).
create policy "developer admins manage themselves" on developer_admins
  for all using (is_developer_admin()) with check (is_developer_admin());

-- activation_codes: developer-only table access. Stores never query this
-- table directly — redemption happens through the redeem_activation_code()
-- function below, which runs as SECURITY DEFINER.
create policy "activation codes developer only" on activation_codes
  for all using (is_developer_admin()) with check (is_developer_admin());

create policy "notifications developer only" on platform_notifications
  for all using (is_developer_admin()) with check (is_developer_admin());

-- notification_recipients: a store may read (and mark read) only its own
-- inbox rows; developers manage all.
create policy "store reads own notifications" on notification_recipients
  for select using (store_id = current_store_id() or is_developer_admin());
create policy "store marks own notifications read" on notification_recipients
  for update using (store_id = current_store_id() or is_developer_admin())
  with check (store_id = current_store_id() or is_developer_admin());
create policy "developer manages notification recipients" on notification_recipients
  for insert with check (is_developer_admin());
create policy "developer deletes notification recipients" on notification_recipients
  for delete using (is_developer_admin());

create policy "audit logs developer only" on platform_audit_logs
  for all using (is_developer_admin()) with check (is_developer_admin());

-- Trigger: a store can update its own row (display info, settings), but may
-- never change the fields that control its own billing/licensing/access —
-- those are silently pinned back to their prior value unless the caller is a
-- developer. This is what makes "no client should modify its own plan or
-- reactivate itself by editing a row" actually true, not just a UI hint.
create or replace function protect_store_privileged_columns()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if is_developer_admin() then
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

create trigger stores_protect_privileged_columns
  before update on stores
  for each row execute function protect_store_privileged_columns();

-- =============================================================================
-- 3. TENANT TABLES (one row set per store; every table carries store_id)
-- =============================================================================
-- Created in dependency order (referenced tables before referencing ones).

create table branches (
  id              text primary key default gen_random_uuid()::text,
  store_id        text not null references stores (id) on delete cascade,
  name            text not null,
  address         text not null default '',
  phone           text not null default '',
  is_main_branch  boolean not null default false,
  is_active       boolean not null default true,
  created_at      timestamptz not null default now()
);

-- Employees, including owners/managers. PIN hash is NOT here — see
-- employee_credentials below. The hidden Developer identity is never a row
-- in this table (see lib/core/constants/roles.dart).
create table users (
  id                        text primary key default gen_random_uuid()::text,
  store_id                  text not null references stores (id) on delete cascade,
  branch_id                 text references branches (id) on delete set null,
  name                      text not null,
  role                      text not null check (role in ('owner','manager','cashier','warehouseManager')),
  phone                     text not null default '',
  address                   text not null default '',
  salary_minor_units        bigint not null default 0,
  allowances_minor_units    bigint not null default 0,
  avatar_color_hex          text not null default '#0F6E5C',
  is_active                 boolean not null default true,
  created_at                timestamptz not null default now()
);

-- PIN hashes, deliberately split into their own table with RLS enabled and
-- ZERO policies granted to `authenticated`. No client can ever `select` a
-- hash — the only access path is the SECURITY DEFINER functions below.
create table employee_credentials (
  user_id    text primary key references users (id) on delete cascade,
  store_id   text not null references stores (id) on delete cascade,
  pin_hash   text not null,
  updated_at timestamptz not null default now()
);
alter table employee_credentials enable row level security;
-- Intentionally no policies here — default-deny for the `authenticated` role.

create table categories (
  id                  text primary key default gen_random_uuid()::text,
  store_id            text not null references stores (id) on delete cascade,
  name                text not null,
  parent_category_id  text references categories (id) on delete set null
);

create table tax_rates (
  id            text primary key default gen_random_uuid()::text,
  store_id      text not null references stores (id) on delete cascade,
  name          text not null,
  rate_percent  double precision not null,
  is_default    boolean not null default false
);

create table products (
  id                        text primary key default gen_random_uuid()::text,
  store_id                  text not null references stores (id) on delete cascade,
  category_id               text references categories (id) on delete set null,
  sku                       text not null,
  barcode                   text,
  name                      text not null,
  unit                      text not null default 'pcs',
  cost_price_minor_units    bigint not null default 0,
  sell_price_minor_units    bigint not null default 0,
  tax_rate_id               text references tax_rates (id) on delete set null,
  reorder_level             integer not null default 0,
  image_path                text,
  is_active                 boolean not null default true,
  created_at                timestamptz not null default now()
);

create table customers (
  id          text primary key default gen_random_uuid()::text,
  store_id    text not null references stores (id) on delete cascade,
  name        text not null,
  phone       text,
  address     text,
  created_at  timestamptz not null default now()
);

create table suppliers (
  id              text primary key default gen_random_uuid()::text,
  store_id        text not null references stores (id) on delete cascade,
  name            text not null,
  contact_phone   text,
  contact_person  text,
  address         text,
  created_at      timestamptz not null default now()
);

create table chart_of_accounts (
  id                 text primary key default gen_random_uuid()::text,
  store_id           text not null references stores (id) on delete cascade,
  code               text not null,
  name               text not null,
  type               text not null check (type in ('asset','liability','equity','revenue','cogs','expense')),
  parent_account_id  text references chart_of_accounts (id) on delete set null,
  is_system_account  boolean not null default false,
  is_active          boolean not null default true
);

-- One header per business transaction. Never edited or deleted after
-- creation — corrections are reversing entries via reversal_of_entry_id, so
-- the ledger stays a true immutable audit trail.
create table journal_entries (
  id                    text primary key default gen_random_uuid()::text,
  store_id              text not null references stores (id) on delete cascade,
  branch_id             text not null references branches (id) on delete restrict,
  entry_date            timestamptz not null,
  reference_type        text not null check (reference_type in
                          ('SALE','PURCHASE','SUPPLIER_PAYMENT','DEBT_PAYMENT','EXPENSE','RETURN','ADJUSTMENT','MANUAL','OPENING_BALANCE')),
  reference_id          text,
  memo                  text not null default '',
  created_by_user_id    text not null references users (id) on delete restrict,
  is_reversal           boolean not null default false,
  reversal_of_entry_id  text references journal_entries (id) on delete set null,
  created_at            timestamptz not null default now()
);

create table journal_lines (
  id                  text primary key default gen_random_uuid()::text,
  store_id            text not null references stores (id) on delete cascade,
  journal_entry_id    text not null references journal_entries (id) on delete cascade,
  account_id          text not null references chart_of_accounts (id) on delete restrict,
  debit_minor_units   bigint not null default 0,
  credit_minor_units  bigint not null default 0,
  description         text not null default ''
);

create table shifts (
  id                                  text primary key default gen_random_uuid()::text,
  store_id                            text not null references stores (id) on delete cascade,
  branch_id                           text not null references branches (id) on delete restrict,
  cashier_id                          text not null references users (id) on delete restrict,
  opened_at                           timestamptz not null default now(),
  closed_at                           timestamptz,
  opening_cash_float_minor_units      bigint not null default 0,
  expected_cash_at_close_minor_units  bigint,
  counted_cash_at_close_minor_units   bigint,
  discrepancy_minor_units             bigint,
  status                              text not null default 'open' check (status in ('open','closed'))
);

-- A sale in any state, including held/parked sales (status = 'held'). There
-- is deliberately no separate "held sale" table — resuming a hold just loads
-- this row back into the cart.
create table sales (
  id                              text primary key default gen_random_uuid()::text,
  store_id                        text not null references stores (id) on delete cascade,
  branch_id                       text not null references branches (id) on delete restrict,
  sale_number                     text not null,
  status                          text not null check (status in ('held','completed','refunded','partiallyRefunded','voided')),
  customer_id                     text references customers (id) on delete set null,
  hold_label                      text,
  subtotal_minor_units            bigint not null default 0,
  discount_total_minor_units      bigint not null default 0,
  tax_total_minor_units           bigint not null default 0,
  grand_total_minor_units         bigint not null default 0,
  payment_method                  text check (payment_method in ('cash','card','payLater')),
  amount_tendered_minor_units     bigint,
  change_given_minor_units        bigint,
  shift_id                        text references shifts (id) on delete set null,
  cashier_id                      text not null references users (id) on delete restrict,
  journal_entry_id                text references journal_entries (id) on delete set null,
  created_at                      timestamptz not null default now(),
  completed_at                    timestamptz
);

create table sale_lines (
  id                                text primary key default gen_random_uuid()::text,
  store_id                          text not null references stores (id) on delete cascade,
  sale_id                           text not null references sales (id) on delete cascade,
  product_id                        text not null references products (id) on delete restrict,
  quantity                          bigint not null,
  unit_price_minor_units            bigint not null,
  discount_amount_minor_units       bigint not null default 0,
  tax_amount_minor_units            bigint not null default 0,
  line_total_minor_units            bigint not null,
  cost_price_snapshot_minor_units   bigint not null default 0
);

create table sale_returns (
  id                    text primary key default gen_random_uuid()::text,
  store_id              text not null references stores (id) on delete cascade,
  branch_id             text not null references branches (id) on delete restrict,
  original_sale_id      text not null references sales (id) on delete restrict,
  refund_method         text not null check (refund_method in ('cash','card','storeCredit')),
  journal_entry_id      text references journal_entries (id) on delete set null,
  processed_by_user_id  text not null references users (id) on delete restrict,
  created_at            timestamptz not null default now()
);

create table sale_return_lines (
  id                            text primary key default gen_random_uuid()::text,
  store_id                      text not null references stores (id) on delete cascade,
  sale_return_id                text not null references sale_returns (id) on delete cascade,
  sale_line_id                  text not null references sale_lines (id) on delete restrict,
  quantity_returned              bigint not null,
  refund_amount_minor_units     bigint not null
);

create table debt_ledger_entries (
  id                              text primary key default gen_random_uuid()::text,
  store_id                        text not null references stores (id) on delete cascade,
  branch_id                       text not null references branches (id) on delete restrict,
  customer_id                     text not null references customers (id) on delete restrict,
  sale_id                         text references sales (id) on delete set null,
  journal_entry_id                text references journal_entries (id) on delete set null,
  original_amount_minor_units     bigint not null,
  amount_paid_minor_units         bigint not null default 0,
  receipt_ref                     text,
  status                          text not null default 'open' check (status in ('open','partiallyPaid','paid')),
  created_at                      timestamptz not null default now()
);

create table debt_payments (
  id                        text primary key default gen_random_uuid()::text,
  store_id                  text not null references stores (id) on delete cascade,
  debt_ledger_entry_id      text not null references debt_ledger_entries (id) on delete cascade,
  amount_minor_units        bigint not null,
  payment_method            text not null check (payment_method in ('cash','card')),
  received_by_user_id       text not null references users (id) on delete restrict,
  journal_entry_id          text references journal_entries (id) on delete set null,
  paid_at                   timestamptz not null default now()
);

-- Per-branch quantity on hand for a product. One row per (product_id, branch_id).
create table stock_items (
  id                  text primary key default gen_random_uuid()::text,
  store_id            text not null references stores (id) on delete cascade,
  product_id          text not null references products (id) on delete cascade,
  branch_id           text not null references branches (id) on delete cascade,
  quantity_on_hand    bigint not null default 0,
  reserved_quantity   bigint not null default 0,
  last_counted_at     timestamptz,
  unique (product_id, branch_id)
);

-- Immutable audit trail of every stock change — the source of truth that
-- stock_items.quantity_on_hand is derived from/reconciled against.
create table stock_movements (
  id                      text primary key default gen_random_uuid()::text,
  store_id                text not null references stores (id) on delete cascade,
  product_id              text not null references products (id) on delete restrict,
  branch_id               text not null references branches (id) on delete restrict,
  type                    text not null check (type in
                            ('purchaseIn','saleOut','transferIn','transferOut','adjustmentIn','adjustmentOut','returnIn','returnOut')),
  quantity                bigint not null,
  unit_cost_minor_units   bigint not null default 0,
  reference_type          text,
  reference_id            text,
  created_by_user_id      text not null references users (id) on delete restrict,
  created_at              timestamptz not null default now()
);

create table stock_transfers (
  id                     text primary key default gen_random_uuid()::text,
  store_id               text not null references stores (id) on delete cascade,
  from_branch_id         text not null references branches (id) on delete restrict,
  to_branch_id           text not null references branches (id) on delete restrict,
  status                 text not null default 'pending' check (status in ('pending','inTransit','received','cancelled')),
  requested_by_user_id   text not null references users (id) on delete restrict,
  received_by_user_id    text references users (id) on delete set null,
  created_at             timestamptz not null default now(),
  received_at            timestamptz
);

create table stock_transfer_lines (
  id                  text primary key default gen_random_uuid()::text,
  store_id            text not null references stores (id) on delete cascade,
  stock_transfer_id   text not null references stock_transfers (id) on delete cascade,
  product_id          text not null references products (id) on delete restrict,
  quantity            bigint not null
);

create table purchase_orders (
  id                        text primary key default gen_random_uuid()::text,
  store_id                  text not null references stores (id) on delete cascade,
  branch_id                 text not null references branches (id) on delete restrict,
  supplier_id                text not null references suppliers (id) on delete restrict,
  status                    text not null default 'draft' check (status in ('draft','ordered','partiallyReceived','received','cancelled')),
  order_date                timestamptz not null default now(),
  expected_date             timestamptz,
  total_cost_minor_units    bigint not null default 0,
  paid_immediately          boolean not null default false
);

create table purchase_order_lines (
  id                        text primary key default gen_random_uuid()::text,
  store_id                  text not null references stores (id) on delete cascade,
  purchase_order_id         text not null references purchase_orders (id) on delete cascade,
  product_id                text not null references products (id) on delete restrict,
  quantity_ordered          bigint not null,
  quantity_received         bigint not null default 0,
  unit_cost_minor_units     bigint not null
);

-- A running record of everything owed to / paid to a supplier. The
-- supplier's current balance is a live query (purchases minus payments),
-- never a value trusted to stay in sync on its own.
create table supplier_transactions (
  id                              text primary key default gen_random_uuid()::text,
  store_id                        text not null references stores (id) on delete cascade,
  supplier_id                     text not null references suppliers (id) on delete restrict,
  type                            text not null check (type in ('purchase','payment','adjustment')),
  amount_minor_units              bigint not null,
  related_purchase_order_id       text references purchase_orders (id) on delete set null,
  delivery_date                   timestamptz,
  journal_entry_id                text references journal_entries (id) on delete set null,
  created_by_user_id              text not null references users (id) on delete restrict,
  created_at                      timestamptz not null default now()
);

create table discounts (
  id                text primary key default gen_random_uuid()::text,
  store_id          text not null references stores (id) on delete cascade,
  name              text not null,
  type              text not null check (type in ('percentOff','amountOff')),
  value             bigint not null,
  applied_scope     text not null check (applied_scope in ('product','category','cart')),
  scope_target_id   text,
  start_date        timestamptz,
  end_date          timestamptz,
  is_active         boolean not null default true
);

-- Singleton-per-store settings row. id is always equal to store_id.
create table app_settings (
  id                            text primary key,
  store_id                      text not null unique references stores (id) on delete cascade,
  default_language              text not null default 'en',
  theme_mode                    text not null default 'system' check (theme_mode in ('light','dark','system')),
  currency_code                 text not null default 'USD',
  currency_symbol                text not null default '$',
  default_vat_rate_percent      double precision not null default 0,
  printer_config_json           text not null default '{}',
  auto_backup_enabled           boolean not null default false,
  auto_backup_time_of_day       text not null default '22:00',
  auto_backup_folder_path       text,
  low_stock_threshold_default   integer not null default 5
);

create table audit_logs (
  id                text primary key default gen_random_uuid()::text,
  store_id          text not null references stores (id) on delete cascade,
  user_id           text not null references users (id) on delete restrict,
  action            text not null,
  entity_type       text not null,
  entity_id         text,
  before_value_json text,
  after_value_json  text,
  "timestamp"       timestamptz not null default now()
);

-- =============================================================================
-- 4. INDEXES — every tenant table gets a store_id index (RLS join hot path),
-- plus the lookups the app actually performs (barcode scan, sale numbering,
-- FK columns that are queried directly).
-- =============================================================================

create index idx_branches_store on branches (store_id);
create index idx_users_store on users (store_id);
create index idx_users_branch on users (branch_id);
create index idx_employee_credentials_store on employee_credentials (store_id);
create index idx_categories_store on categories (store_id);
create index idx_tax_rates_store on tax_rates (store_id);
create index idx_products_store on products (store_id);
create index idx_products_barcode on products (store_id, barcode);
create index idx_products_sku on products (store_id, sku);
create index idx_customers_store on customers (store_id);
create index idx_suppliers_store on suppliers (store_id);
create index idx_chart_of_accounts_store on chart_of_accounts (store_id);
create index idx_journal_entries_store on journal_entries (store_id);
create index idx_journal_entries_ref on journal_entries (store_id, reference_type, reference_id);
create index idx_journal_lines_store on journal_lines (store_id);
create index idx_journal_lines_entry on journal_lines (journal_entry_id);
create index idx_journal_lines_account on journal_lines (account_id);
create index idx_shifts_store on shifts (store_id);
create index idx_shifts_branch on shifts (branch_id);
create index idx_sales_store on sales (store_id);
create index idx_sales_branch_status on sales (store_id, branch_id, status);
create index idx_sales_number on sales (store_id, sale_number);
create index idx_sale_lines_store on sale_lines (store_id);
create index idx_sale_lines_sale on sale_lines (sale_id);
create index idx_sale_lines_product on sale_lines (product_id);
create index idx_sale_returns_store on sale_returns (store_id);
create index idx_sale_returns_original_sale on sale_returns (original_sale_id);
create index idx_sale_return_lines_store on sale_return_lines (store_id);
create index idx_sale_return_lines_return on sale_return_lines (sale_return_id);
create index idx_debt_ledger_entries_store on debt_ledger_entries (store_id);
create index idx_debt_ledger_entries_customer on debt_ledger_entries (store_id, customer_id);
create index idx_debt_ledger_entries_status on debt_ledger_entries (store_id, status);
create index idx_debt_payments_store on debt_payments (store_id);
create index idx_debt_payments_entry on debt_payments (debt_ledger_entry_id);
create index idx_stock_items_store on stock_items (store_id);
create index idx_stock_items_branch on stock_items (store_id, branch_id);
create index idx_stock_movements_store on stock_movements (store_id);
create index idx_stock_movements_product on stock_movements (product_id, branch_id);
create index idx_stock_transfers_store on stock_transfers (store_id);
create index idx_stock_transfer_lines_store on stock_transfer_lines (store_id);
create index idx_stock_transfer_lines_transfer on stock_transfer_lines (stock_transfer_id);
create index idx_purchase_orders_store on purchase_orders (store_id);
create index idx_purchase_orders_supplier on purchase_orders (store_id, supplier_id);
create index idx_purchase_order_lines_store on purchase_order_lines (store_id);
create index idx_purchase_order_lines_po on purchase_order_lines (purchase_order_id);
create index idx_supplier_transactions_store on supplier_transactions (store_id);
create index idx_supplier_transactions_supplier on supplier_transactions (store_id, supplier_id);
create index idx_discounts_store on discounts (store_id);
create index idx_audit_logs_store on audit_logs (store_id);
create index idx_audit_logs_entity on audit_logs (store_id, entity_type, entity_id);
create index idx_stores_login_id on stores (store_login_id);
create index idx_stores_auth_user on stores (auth_user_id);
create index idx_activation_codes_code on activation_codes (code);
create index idx_notification_recipients_store on notification_recipients (store_id);

-- =============================================================================
-- 5. TENANT ROW-LEVEL SECURITY — one uniform policy set, applied by a loop
-- instead of 27 × 4 hand-written CREATE POLICY statements. Every table here
-- gets: enable RLS, then select/insert/update/delete policies all requiring
-- store_id = current_store_id() (i.e. the row belongs to the caller's own
-- store), OR the caller is a developer admin (full visibility for support /
-- the Developer Console's per-store drill-down views).
--
-- employee_credentials is deliberately EXCLUDED — it keeps its own
-- default-deny policy set (none) defined above.
-- =============================================================================

do $$
declare
  t text;
  tenant_tables text[] := array[
    'branches', 'users', 'categories', 'tax_rates', 'products',
    'customers', 'suppliers', 'chart_of_accounts', 'journal_entries', 'journal_lines',
    'shifts', 'sales', 'sale_lines', 'sale_returns', 'sale_return_lines',
    'debt_ledger_entries', 'debt_payments', 'stock_items', 'stock_movements', 'stock_transfers',
    'stock_transfer_lines', 'purchase_orders', 'purchase_order_lines', 'supplier_transactions', 'discounts',
    'app_settings', 'audit_logs'
  ];
begin
  foreach t in array tenant_tables loop
    execute format('alter table %I enable row level security;', t);

    execute format(
      'create policy "tenant select" on %I for select using (store_id = current_store_id() or is_developer_admin());',
      t
    );
    execute format(
      'create policy "tenant insert" on %I for insert with check (store_id = current_store_id() or is_developer_admin());',
      t
    );
    execute format(
      'create policy "tenant update" on %I for update using (store_id = current_store_id() or is_developer_admin()) with check (store_id = current_store_id() or is_developer_admin());',
      t
    );
    execute format(
      'create policy "tenant delete" on %I for delete using (store_id = current_store_id() or is_developer_admin());',
      t
    );
  end loop;
end $$;

-- =============================================================================
-- 6. SECURITY DEFINER FUNCTIONS — the only door into employee_credentials,
-- and the atomic entry points for store registration and license redemption.
-- =============================================================================

-- Generates a license key in the exact UNO-XXXX-XXXX-XXXX format, avoiding
-- visually ambiguous characters (0/O, 1/I).
create or replace function generate_license_key()
returns text
language plpgsql
as $$
declare
  alphabet text := '23456789ABCDEFGHJKLMNPQRSTUVWXYZ';
  result text := 'UNO-';
  group_idx int;
  char_idx int;
begin
  for group_idx in 1..3 loop
    for char_idx in 1..4 loop
      result := result || substr(alphabet, 1 + floor(random() * length(alphabet))::int, 1);
    end loop;
    if group_idx < 3 then
      result := result || '-';
    end if;
  end loop;
  return result;
end;
$$;

-- Called immediately after supabase.auth.signUp() during registration. Runs
-- as the newly-created auth user (auth.uid() is already set). Creates the
-- store row, seeds a default Chart of Accounts and settings row, and starts
-- the store on a trial. Registration deliberately does NOT set plan_id to
-- anything paid — upgrades/activation happen through the Developer Console
-- or activation-code redemption afterwards.
create or replace function register_store(
  p_store_login_id text,
  p_display_name text,
  p_owner_name text,
  p_phone text
)
returns stores
language plpgsql
security definer
set search_path = public
as $$
declare
  v_store stores;
  v_branch_id text;
begin
  if auth.uid() is null then
    raise exception 'must be signed in to register a store';
  end if;

  if exists (select 1 from stores where auth_user_id = auth.uid()) then
    raise exception 'this account already owns a store';
  end if;

  insert into stores (store_login_id, auth_user_id, display_name, owner_name, phone, plan_id, subscription_status, activation_status)
  values (p_store_login_id, auth.uid(), p_display_name, p_owner_name, p_phone, 'starter', 'trial', 'pending')
  returning * into v_store;

  insert into branches (store_id, name, is_main_branch, is_active)
  values (v_store.id, p_display_name, true, true)
  returning id into v_branch_id;

  insert into app_settings (id, store_id)
  values (v_store.id, v_store.id);

  insert into chart_of_accounts (store_id, code, name, type, is_system_account) values
    (v_store.id, '1000', 'Cash',                  'asset',     true),
    (v_store.id, '1100', 'Accounts Receivable',    'asset',     true),
    (v_store.id, '1200', 'Inventory',              'asset',     true),
    (v_store.id, '2000', 'Accounts Payable',       'liability', true),
    (v_store.id, '3000', 'Owner''s Equity',        'equity',    true),
    (v_store.id, '4000', 'Sales Revenue',          'revenue',   true),
    (v_store.id, '4100', 'Sales Returns',          'revenue',   true),
    (v_store.id, '5000', 'Cost of Goods Sold',     'cogs',      true),
    (v_store.id, '6000', 'Operating Expenses',     'expense',   true);

  return v_store;
end;
$$;

-- Developer-only: mints an activation code (the client's existing
-- ActivationCodeCodec still runs client-side to produce the signed `code`
-- string — this function just records it and its metadata).
create or replace function record_activation_code(
  p_code text,
  p_store_name_ref text,
  p_tier text,
  p_expires_at timestamptz
)
returns activation_codes
language plpgsql
security definer
set search_path = public
as $$
declare
  v_admin_id text;
  v_row activation_codes;
begin
  select id into v_admin_id from developer_admins where auth_user_id = auth.uid();
  if v_admin_id is null then
    raise exception 'only a developer admin may issue activation codes';
  end if;

  insert into activation_codes (code, store_name_ref, tier, expires_at, issued_by_admin_id)
  values (p_code, p_store_name_ref, p_tier, p_expires_at, v_admin_id)
  returning * into v_row;

  return v_row;
end;
$$;

-- Redeems a previously-issued, still-unused activation code against the
-- calling store. Sets activation_status/expires_at/license_key on the store
-- and marks the code as redeemed — all inside one transaction so a code can
-- never be redeemed twice even under concurrent calls (row lock via UPDATE).
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

  select * into v_code from activation_codes where code = p_code for update;
  if v_code.id is null then
    raise exception 'invalid activation code';
  end if;
  if v_code.status <> 'unused' then
    raise exception 'activation code already % ', v_code.status;
  end if;

  update activation_codes
    set status = 'active', redeemed_by_store_id = v_store_id, redeemed_at = now()
    where id = v_code.id;

  update stores
    set activation_status = 'active',
        activation_code_id = v_code.id,
        license_key = coalesce(license_key, generate_license_key()),
        expires_at = v_code.expires_at,
        subscription_status = 'active'
    where id = v_store_id
    returning * into v_store;

  return v_store;
end;
$$;

-- Creates an employee (users row) plus its PIN hash (employee_credentials
-- row) atomically. p_pin is a plain 4+ digit PIN; hashed here via pgcrypto
-- so it never needs to touch the client in hashed form.
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
set search_path = public
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

-- Resets/changes an employee's PIN. Caller must own the store the employee
-- belongs to (enforced explicitly, since employee_credentials has no RLS
-- policies of its own to fall back on).
create or replace function update_employee_pin(p_user_id text, p_new_pin text)
returns void
language plpgsql
security definer
set search_path = public
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

-- Verifies a PIN against every active employee of the CALLING store (never
-- a store_id supplied by the client — that would let one store probe
-- another's PINs by passing an arbitrary id). Returns the matching employee
-- row, or no rows if the PIN doesn't match anyone.
create or replace function verify_employee_pin(p_pin text)
returns users
language plpgsql
security definer
set search_path = public
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

-- =============================================================================
-- 7. SEED DATA — default subscription plans (editable later from the
-- Developer Console with zero redeploy needed).
-- =============================================================================

insert into subscription_plans (id, name, max_employees, max_branches, max_products, max_users, max_warehouses, max_storage_mb, max_daily_transactions) values
  ('starter',      'Starter',      5,  1,  200,   5,  1,  250,   100),
  ('standard',     'Standard',     15, 3,  2000,  15, 3,  1000,  500),
  ('professional', 'Professional', 50, 10, 20000, 50, 10, 5000,  5000),
  ('enterprise',   'Enterprise',   999999, 999999, 999999, 999999, 999999, 999999, 999999);
