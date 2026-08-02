# UNOPOS — Tenant Isolation Verification Checklist

Run this against your own real Supabase project before putting UNOPOS in
front of real customers. Nothing in this repo's sandbox environment could
run these checks live (no reachable Supabase project) — every RLS policy,
trigger, and RPC in `supabase/migrations/` was written and reviewed
carefully, but "carefully reviewed" is not the same as "verified against a
live Postgres instance." Treat this checklist as mandatory, not optional.

The core promise this verifies: **Store A can never see, modify, or delete
Store B's data, through the app or directly against the database** —
"the MOST IMPORTANT RULE" from the original spec.

## Part 1 — App-level walkthrough (10–15 minutes)

1. **Create two stores.** Run the app in Supabase mode (see
   `SETUP_GUIDE.md` section 6) and register two separate stores — different
   `store_login_id`s, e.g. `store-a` and `store-b`. Give each a branch, a
   product, a customer, and complete one sale.
2. **Log into Store A.** Confirm you see only Store A's:
   - Products (Inventory tab)
   - Sales history (POS → completed sales)
   - Customers and debts (Debts tab)
   - Suppliers, accounting entries, shifts, staff (HR tab)
   - Settings (currency, printer config, etc.)
   None of Store B's data should appear anywhere.
3. **Log out, log into Store B.** Repeat the same check — confirm you see
   only Store B's data, and *zero* trace of Store A's.
4. **Cross-ID probe (the important one).** While logged into Store A, open
   the browser/Flutter DevTools network inspector (or add a temporary debug
   print) and copy a real record ID from Store B (e.g. a product id, sale
   id, customer id — get these from Part 2's SQL queries, run as the
   `postgres` role, not through the app). Try to fetch that record through
   Store A's session — e.g. call `InventoryRepository.getProduct(storeBsProductId)`
   from Store A's session. It must return `null`/nothing, never Store B's
   actual row. This is the literal test of "no client should ever modify
   another store's data by changing an ID."
5. **Employee PIN isolation.** Create an employee in Store A with PIN
   `1234`. Create a *different* employee in Store B, also with PIN `1234`
   (same PIN, different store). Confirm Store A's tile picker + PIN pad
   only ever matches Store A's employee, never Store B's, even though the
   PINs are identical. (This exact scenario has an automated test already —
   see `test/features/auth_repository_tenant_scoping_test.dart` — this step
   just re-confirms it end-to-end against the real backend.)
6. **Developer Console isolation.** Sign in as the developer (1313 → real
   sign-in). Confirm the Stores tab shows *both* Store A and Store B (this
   is correct — developers see everything by design), but confirm a
   non-developer account can never reach that screen (try signing into the
   developer gate with a store's own credentials — it must fail).

## Part 2 — Direct SQL verification (run in the Supabase SQL Editor)

These queries run as the `postgres`/service role by default in the SQL
Editor, which **bypasses RLS** — useful for confirming what data actually
exists, but NOT a test of isolation by itself. The real test is emulating
each store's own restricted role.

### 2a. Confirm RLS is actually enabled on every tenant table

```sql
select relname, relrowsecurity, relforcerowsecurity
from pg_class
where relname in (
  'branches','users','employee_credentials','categories','tax_rates','products',
  'customers','suppliers','chart_of_accounts','journal_entries','journal_lines',
  'shifts','sales','sale_lines','sale_returns','sale_return_lines',
  'debt_ledger_entries','debt_payments','stock_items','stock_movements',
  'stock_transfers','stock_transfer_lines','purchase_orders','purchase_order_lines',
  'supplier_transactions','discounts','app_settings','audit_logs'
)
order by relname;
```
Every row must show `relrowsecurity = true`. If any table shows `false`,
RLS was never turned on for it — a critical bug to fix before going live.

### 2b. Confirm employee_credentials has zero policies for `authenticated`

```sql
select * from pg_policies where tablename = 'employee_credentials';
```
This should return **zero rows** for the `authenticated` role (the table
should have RLS enabled with no policies at all, per
`0001_multi_tenant_schema.sql` — PIN hashes are only reachable through the
`verify_employee_pin`/`create_employee`/`update_employee_pin` functions).

### 2c. Emulate Store A's session and try to read Store B's data

Get Store A's `auth_user_id` and a Store B record id first (as the service
role, bypassing RLS, purely to find test data):
```sql
select id, store_login_id, auth_user_id from stores order by created_at desc limit 5;
select id, name from products where store_id = 'STORE_B_ID_HERE';
```

Then, in a **fresh SQL Editor query using "Run as" set to the `authenticated`
role with Store A's JWT** (Supabase SQL Editor supports impersonating a
specific user — look for the role/user switcher in the editor toolbar; if
your Supabase Studio version doesn't support this, instead sign into the
app as Store A, open DevTools, and copy the `Authorization: Bearer <jwt>`
header from any API call, then use that JWT with `curl` against
`{SUPABASE_URL}/rest/v1/products?id=eq.STORE_B_PRODUCT_ID` with header
`apikey: {anon_key}`):

```sql
select * from products where id = 'STORE_B_PRODUCT_ID_HERE';
```
**Expected result: zero rows.** If this returns Store B's product while
impersonating Store A, RLS has a hole — stop and fix it before doing
anything else.

Repeat this same "try to select store B's row while impersonating store A"
check for at least: `sales`, `customers`, `debt_ledger_entries`,
`journal_entries`, `stock_items`. All must return zero rows.

### 2d. Confirm a store cannot escalate its own plan/license

While impersonating Store A's JWT:
```sql
update stores set plan_id = 'enterprise', is_disabled = false, activation_status = 'active'
where id = 'STORE_A_ID_HERE';

select plan_id, activation_status from stores where id = 'STORE_A_ID_HERE';
```
The `plan_id`/`activation_status` must be **unchanged** from before the
UPDATE — the `protect_store_privileged_columns` trigger should have
silently pinned them back. If they changed, the trigger isn't working.

### 2e. Confirm developer-only tables reject a store session

While impersonating Store A's JWT:
```sql
select * from activation_codes limit 1;
select * from developer_admins limit 1;
insert into platform_notifications (title, body) values ('test', 'test');
```
All three must fail or return zero rows — a store session has no access to
these at all.

## Part 3 — Concurrency sanity check (optional but recommended)

Since this schema moved from SQLite's single-writer model to Postgres
(multiple concurrent connections are now possible), it's worth confirming
the atomicity fixes actually hold:
1. From two different sessions/devices logged into the *same* store,
   complete two sales at nearly the same instant. Confirm both get unique
   sale numbers (no duplicates) — this exercises `next_sale_number()`'s
   row-locking.
2. From two sessions, record two stock movements for the same product/branch
   at nearly the same instant (e.g. two purchase receipts). Confirm the
   final `quantity_on_hand` reflects both movements (no lost update) — this
   exercises `record_stock_movement`'s `ON CONFLICT ... DO UPDATE`.

## If something fails

Do not ship. Every check above maps to a specific policy/trigger/function in
`supabase/migrations/0001_multi_tenant_schema.sql` through `0006_notification_inbox.sql`
— find the matching one, fix it, and re-run this whole checklist from the
top (a fix to one policy can have side effects on another).
