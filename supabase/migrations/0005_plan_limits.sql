-- =============================================================================
-- UNOPOS — Phase H4: Subscription plan limit enforcement
-- =============================================================================
-- subscription_plans (table + 4 seeded defaults) and stores.plan_id already
-- exist from 0001. What was missing: actually stopping a store from
-- exceeding its plan once assigned — "no client should be able to bypass
-- this by changing an ID" only holds if the check is server-side.
--
-- Enforced here via BEFORE INSERT triggers on the 4 tables where a limit is
-- both meaningful and cheaply checkable with a COUNT: employees (users),
-- branches, products, and a daily sales count (max_daily_transactions).
--
-- Two of subscription_plans' 7 limit columns are NOT enforced by a trigger,
-- deliberately:
--   - max_storage_mb: nothing in this schema stores binary data in Postgres
--     (product images are a path/URL, not bytea) — there's no cheap,
--     accurate "storage used" figure to check against here. Left as an
--     informational limit only for now.
--   - max_warehouses: this schema has no entity distinct from `branches` to
--     represent a warehouse — a branch IS the physical-location unit.
--     max_users is a separate limit column from max_employees but this
--     schema also has only one `users` table serving every staff role, so
--     max_employees is the one actually enforced; max_users is reserved
--     for a possible future distinction (e.g. admin seats) that doesn't
--     exist yet.
-- =============================================================================

create or replace function enforce_plan_limit()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_plan subscription_plans;
  v_count bigint;
  v_limit bigint;
begin
  select sp.* into v_plan from stores s join subscription_plans sp on sp.id = s.plan_id where s.id = new.store_id;
  if v_plan.id is null then
    -- No plan resolved (shouldn't happen — plan_id is a required FK) —
    -- fail open rather than block an otherwise-valid insert on a data
    -- integrity issue unrelated to what the caller is doing.
    return new;
  end if;

  if TG_TABLE_NAME = 'users' then
    select count(*) into v_count from users where store_id = new.store_id;
    v_limit := v_plan.max_employees;
  elsif TG_TABLE_NAME = 'branches' then
    select count(*) into v_count from branches where store_id = new.store_id;
    v_limit := v_plan.max_branches;
  elsif TG_TABLE_NAME = 'products' then
    select count(*) into v_count from products where store_id = new.store_id;
    v_limit := v_plan.max_products;
  elsif TG_TABLE_NAME = 'sales' then
    select count(*) into v_count from sales where store_id = new.store_id and created_at >= date_trunc('day', now());
    v_limit := v_plan.max_daily_transactions;
  else
    return new;
  end if;

  if v_count >= v_limit then
    raise exception 'plan limit reached: this store''s % plan allows at most % %, and % already exist', v_plan.name, v_limit, TG_TABLE_NAME, v_count;
  end if;

  return new;
end;
$$;

create trigger users_plan_limit before insert on users for each row execute function enforce_plan_limit();
create trigger branches_plan_limit before insert on branches for each row execute function enforce_plan_limit();
create trigger products_plan_limit before insert on products for each row execute function enforce_plan_limit();
create trigger sales_plan_limit before insert on sales for each row execute function enforce_plan_limit();

-- Lets a developer_admin change the limits on a plan definition without a
-- redeploy — subscription_plans already has a developer-only write policy
-- from 0001, so this is really just documenting that plain
-- `.from('subscription_plans').update(...)` from the Developer Console is
-- the intended path; no new function needed for that part.
