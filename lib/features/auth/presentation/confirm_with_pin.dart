import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../domain/account_rules.dart';

/// Asks the signed-in employee to confirm a sensitive action with their own
/// PIN (checked by the server, not here). Returns the PIN, or null if they
/// cancelled.
Future<String?> confirmWithPin(BuildContext context, {required String title, required String message}) {
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (context) {
      final l10n = AppLocalizations.of(context);
      return AlertDialog(
        icon: const Icon(Icons.lock_outline),
        title: Text(title),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(message),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                autofocus: true,
                obscureText: true,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(8)],
                decoration: InputDecoration(labelText: l10n.confirmYourPin, prefixIcon: const Icon(Icons.pin_outlined)),
                onSubmitted: (v) => Navigator.of(context).pop(v.isEmpty ? null : v),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.actionCancel)),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.isEmpty ? null : controller.text),
            child: Text(l10n.actionConfirm),
          ),
        ],
      );
    },
  ).whenComplete(controller.dispose);
}

String accountRefusalMessage(AppLocalizations l10n, AccountChangeException e) {
  if (e.wrongPin) return l10n.pinPadIncorrect;
  return switch (e.refusal) {
    AccountChangeRefusal.ownerProtected => l10n.accountOwnerProtected,
    AccountChangeRefusal.onlyOwnerForManager => l10n.accountOnlyOwnerForManager,
    AccountChangeRefusal.notYourself => l10n.accountNotYourself,
    _ => l10n.accountNotAllowed,
  };
}
