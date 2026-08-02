# UNOPOS

A multi-tenant POS + business-management system for supermarkets and hypermarkets, built with Flutter for Windows and Android.

## What's included

- **Licensing**: developer-issued, HMAC-signed activation codes (1/3/6/12-month or lifetime), fully offline-verifiable.
- **Multi-tenant auth**: store ID + password login, employee tile picker with 4-digit PIN, hidden Developer console (passcode `1313`), factory reset (passcode `9090`).
- **POS**: product search, cart, hold/resume sales, cash/card/pay-later checkout, shift open/close with cash reconciliation, receipt printing.
- **Printing**: network (WiFi) ESC/POS thermal, Windows system printer (any installed printer); USB and Bluetooth thermal drivers are scaffolded but need a real device to finish (see below).
- **Inventory**: products, categories, QR code label generation + printing, camera/keyboard-wedge barcode scanning, stock adjustments, branch transfers, purchase orders.
- **Debt ledger**: customer debts tied to receipts, full/partial payment collection.
- **Suppliers**: contacts, purchase history, running balance owed, payments.
- **Accounting**: full double-entry engine (Chart of Accounts, Journal, General Ledger, Trial Balance, Profit & Loss, Balance Sheet), auto-posted from every sale/purchase/payment/expense.
- **HR**: staff directory (name, contact, salary, allowances, passcode) visible only to Owner/Manager/Developer.
- **Settings**: language (English/Arabic/Kurdish Sorani, RTL-aware), light/dark theme, printer config, activation status, backup/restore, factory reset.
- **Backup**: manual + automatic daily backup (zipped SQLite file) with restore.

## Getting started

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # regenerate Drift/Riverpod/Freezed code after any model change
flutter run -d windows   # or -d <android-device-id>
```

The database is a local SQLite file (via Drift) stored in the app's support directory — no server needed for now. The repository layer is written behind interfaces specifically so it can be swapped for a Supabase/Firebase-backed implementation later without touching business logic or UI.

## Multi-tenant SaaS backend (Supabase)

UNOPOS can now run many stores off one shared Supabase backend instead of
one local SQLite file per install. **All 5 migration phases (H1–H5) are
done.** See `supabase/TENANT_ISOLATION_CHECKLIST.md` before putting this in
front of real customers — nothing here could be verified against a live
Supabase project from the sandbox this was built in, only reasoned through
carefully; that checklist is how you close that gap on your own project.

- `supabase/migrations/0001_multi_tenant_schema.sql` — the full schema: every
  store's data isolated by Row-Level Security (`store_id` scoped, join-based
  policies), PIN hashes locked in a table with zero client policies (only
  reachable through `SECURITY DEFINER` functions), store registration,
  activation-code redemption, and employee PIN verify/create/update all as
  server-side functions.
- `supabase/migrations/0002_business_operations.sql` — a per-store sale-number
  counter (replacing a racy client-side count), indexes on FK columns that
  now cross the network, a `low_stock_items` view, a corrected 19-account
  Chart-of-Accounts seed (0001's `register_store` only seeded 9 — fixed here
  via `create or replace function` rather than editing 0001), and every
  atomic-operation RPC (stock movements, receiving transfers/purchase
  orders, journal posting, trial balance, debt payments, supplier balance).
- `supabase/migrations/0003_checkout_rpcs.sql` — `checkout_sale` and
  `process_sale_return`: the entire checkout/return flow (sale + stock +
  accounting + debt entry) as ONE Postgres transaction each — genuinely more
  atomic than the original Dart orchestration ever was, since Postgres
  offers it for free and this is the money/stock-critical path.
- `supabase/migrations/0004_developer_console.sql` — two functions the
  Developer Console needs beyond plain table access (RLS already gives a
  developer_admin full read/write on every store row): resetting a store's
  login password (writes `auth.users.encrypted_password` directly via
  pgcrypto, since the Admin API/Edge Functions aren't reachable from this
  sandbox — verify this actually works against your real project before
  relying on it in production), and assigning a license to a store on the
  developer's initiative instead of the store's own self-service redemption.
- `supabase/migrations/0005_plan_limits.sql` — actually enforces the 4
  subscription plans' limits server-side instead of just storing numbers
  nobody checks: `BEFORE INSERT` triggers on `users`/`branches`/`products`/
  `sales` raise an exception once a store's plan limit is reached (employee
  count, branch count, product count, daily sale count). Storage-MB and
  warehouse limits are intentionally not enforced this way — see the
  migration file's header comment for why.
- `supabase/migrations/0006_notification_inbox.sql` — one additional read
  policy so a store can actually read the title/body of a platform
  notification addressed to it (0001 made `platform_notifications`
  developer-only for every operation including select, which silently
  broke the inbox before it existed — caught while building the inbox
  itself, fixed here rather than by loosening 0001).
  Run all six migration files, in order, against a fresh Supabase
  project's SQL editor before enabling Supabase mode.
- The app defaults to the local Drift database exactly as before — nothing
  changes unless you opt in. To run against Supabase instead:
  ```bash
  flutter run -d windows \
    --dart-define=UNOPOS_USE_SUPABASE=true \
    --dart-define=SUPABASE_URL=https://your-project.supabase.co \
    --dart-define=SUPABASE_ANON_KEY=your-anon-key
  ```
  Also disable "Confirm email" in the Supabase project's Auth settings —
  store accounts use a synthetic, never-emailed address under the hood, so
  there's no inbox to confirm from.
- **What's cut over so far**: all 10 repositories (Auth, Licensing,
  Accounting, Inventory, POS, Debts, Suppliers, Shifts, Settings, Audit) run
  fully on Supabase in this mode, plus checkout/sale-return as atomic RPCs.
  The Developer gate (`1313`) requires a real Supabase Auth sign-in checked
  against a `developer_admins` table server-side, instead of just a local
  passcode. Once signed in, the Developer Console becomes a full multi-tab
  admin surface (Dashboard/Stores/Plans/Licenses/Notifications) instead of
  just a license generator: per-store view/edit/activate/deactivate/
  suspend/delete/reset-password/extend-subscription/change-plan/
  generate-license, editing the 4 plans' limits with no redeploy needed,
  plus sending a platform notification to one store or all of them.
  `BackupRepository` stays Drift-backed in both modes (local file backups
  are inherently a local-device concept).
- Store login now also checks the Developer Console's "Disable" flag after
  a successful password check — a disabled store's session is signed back
  out immediately rather than left live.
- Nothing about this touches the default local build — the local Drift
  schema, its tables, and its repositories are untouched and still fully
  functional as their own standalone mode; the local build's Developer
  Console also stays exactly the simple license generator it always was
  (there's no concept of "other stores" to manage from a single install).
- **Notification inbox**: a bell icon in the store's account strip (top
  right, next to the sign-out menu) shows an unread badge and opens the
  inbox — notifications sent from the Developer Console land here in
  real time.
- **Developer audit log**: every mutating Developer Console action
  (activate/deactivate/suspend/delete/reset-password/extend/change-plan/
  generate-license/edit-plan-limits/send-notification) is logged to
  `platform_audit_logs`, visible in the console's "Audit Log" tab.
- See `supabase/TENANT_ISOLATION_CHECKLIST.md` for the manual + SQL-script
  verification to run against your real project before going live —
  confirms RLS, the PIN-hash lockdown, the privileged-column trigger, and
  the sale-number/stock-movement concurrency fixes actually hold.

## Known limitations (by design, for this first pass)

- **Security of `1313`/`9090`**: these are static codes baked into every install. Fine for this local MVP; before selling commercially, make them per-store configurable or server-issued.
- **Activation codes**: signed with an app-embedded secret (`lib/core/security/app_secrets.dart`) — rotate that value before any real release, and treat it as "resistant to casual tampering," not tamper-proof against a determined attacker. Real tamper-resistance needs server-side validation (planned for the Supabase/Firebase phase).
- **USB/Bluetooth printing**: not implemented (see `lib/features/printing/data/drivers/usb_printer_driver.dart` and `bluetooth_printer_driver.dart`) — needs a platform package plus real hardware to finish, which wasn't available in the environment this was built in. Network and Windows-system-printer drivers are fully functional.
- **Auto-backup**: checked on app launch/resume, not a true OS-level scheduler — it only runs while the app is actually open around the configured time.
- **Balance Sheet**: shows posted account balances as-is; period-close entries (rolling net income into Retained Earnings) aren't automated yet.

## Verification performed

- `flutter analyze`: clean.
- `flutter test`: 25 tests covering the double-entry accounting invariants (balanced/unbalanced entries, unknown accounts, business posting rules), the activation code codec (round-trip + tamper detection), password/PIN hashing, tenant-scoping (no cross-store data leakage), and the PIN pad widget.
- **Not verified in the build environment**: an actual Windows `.exe` (needs a Windows host with Visual Studio Build Tools) or Android `.apk` (the sandboxed build environment's network policy blocks both `sqlite.org`, needed by the Linux/Windows native SQLite build, and `dl.google.com`, needed to install the Android SDK) — build those on your own Windows/Android machine with `flutter build windows` / `flutter build apk`. Real printer/scanner hardware and the native Windows print dialog also couldn't be exercised here.
