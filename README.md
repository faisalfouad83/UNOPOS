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

## Multi-tenant SaaS backend (Supabase) — in progress

UNOPOS is being migrated to run many stores off one shared Supabase backend
instead of one local SQLite file per install. This is a phased migration;
**Phase H1 (foundation) is done**, later phases are not:

- `supabase/migrations/0001_multi_tenant_schema.sql` — the full schema: every
  store's data isolated by Row-Level Security (`store_id` scoped, join-based
  policies), PIN hashes locked in a table with zero client policies (only
  reachable through `SECURITY DEFINER` functions), store registration,
  activation-code redemption, and employee PIN verify/create/update all as
  server-side functions. Run this against a fresh Supabase project's SQL
  editor before enabling Supabase mode.
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
- **What's cut over so far**: store registration/login and employee PIN
  sign-in (`AuthRepository`, `LicensingRepository`) run fully on Supabase in
  this mode. The Developer gate (`1313`) now requires a real Supabase Auth
  sign-in checked against a `developer_admins` table server-side, instead of
  just a local passcode.
- **What's still local-only even in Supabase mode** (until Phase H2):
  inventory, POS/sales, debts, suppliers, accounting, shifts, settings,
  audit — these still read/write the local Drift database. Don't run
  Supabase mode in production until that phase lands; it's here so the
  foundation can be reviewed and iterated on early.
- Nothing about this touches the default local build — the local Drift
  schema, its tables, and its repositories are untouched and still fully
  functional as their own standalone mode.

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
