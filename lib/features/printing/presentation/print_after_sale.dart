import 'package:flutter/material.dart';

import '../../../core/diagnostics/error_log.dart';
import '../../../core/l10n/gen/app_localizations.dart';
import '../../settings/domain/settings_models.dart';
import '../domain/receipt_models.dart';
import 'sale_receipt.dart';

/// Runs once a sale is saved (never before — a failed sale must not print
/// a receipt): prints it straight away, asks the cashier, or does nothing,
/// as set in Settings › Printer. A printing problem never undoes the sale;
/// the cashier gets the reason and can try again.
Future<void> printAfterSale(BuildContext context, ReceiptDocument receipt, AppSettingsRecord settings) async {
  final mode = settings.printerConfig.printMode;
  if (mode == ReceiptPrintMode.off) return;
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);

  if (mode == ReceiptPrintMode.ask) {
    final print = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.print_outlined),
        title: Text(l10n.printAskTitle),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.printSkip)),
          FilledButton.icon(
            autofocus: true,
            icon: const Icon(Icons.print),
            onPressed: () => Navigator.of(context).pop(true),
            label: Text(l10n.printAction),
          ),
        ],
      ),
    );
    if (print != true) return;
  }

  await printWithFeedback(messenger, l10n, receipt, settings);
}

/// Prints [receipt] and reports a failure (no printer, disconnected, out of
/// paper…) with a "try again" action instead of throwing.
Future<void> printWithFeedback(
  ScaffoldMessengerState messenger,
  AppLocalizations l10n,
  ReceiptDocument receipt,
  AppSettingsRecord settings,
) async {
  if (settings.printerConfig.driverType == 'none') {
    messenger.showSnackBar(SnackBar(content: Text(l10n.printNoPrinter)));
    return;
  }
  try {
    await printReceiptDocument(receipt, settings);
  } catch (e) {
    ErrorLog.write('print failed: $e');
    messenger.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 10),
        content: Text(l10n.printFailed(e.toString())),
        action: SnackBarAction(
          label: l10n.printRetry,
          onPressed: () => printWithFeedback(messenger, l10n, receipt, settings),
        ),
      ),
    );
  }
}
