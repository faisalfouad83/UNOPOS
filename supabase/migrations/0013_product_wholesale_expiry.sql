-- Two optional product fields: a wholesale price (a second, lower price
-- the till can switch to for wholesale customers) and a best-before date
-- (drives the near-expiry list on the dashboard).

alter table products add column if not exists wholesale_price_minor_units bigint;
alter table products add column if not exists expiry_date date;

create index if not exists idx_products_expiry on products (store_id, expiry_date) where expiry_date is not null;
