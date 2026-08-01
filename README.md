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
