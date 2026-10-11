import 'package:flutter/material.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/utils/whatsapp.dart';
import '../domain/receipt_models.dart';
import '../domain/receipt_text.dart';

/// Asks for the customer's number, then opens WhatsApp with [doc] as a
/// ready-to-send message.
Future<void> showWhatsAppReceiptDialog(BuildContext context, ReceiptDocument doc, {String? initialPhone}) async {
  final l10n = AppLocalizations.of(context);
  final controller = TextEditingController(text: initialPhone);
  String? error;
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setState) {
        Future<void> send() async {
          final ok = await WhatsApp.send(controller.text, receiptPlainText(doc));
          if (!dialogContext.mounted) return;
          if (ok) {
            Navigator.of(dialogContext).pop();
          } else {
            setState(() => error = l10n.whatsappInvalidPhone);
          }
        }

        return AlertDialog(
          title: Text(l10n.whatsappSendReceipt),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: l10n.whatsappPhone,
              hintText: '07XX XXX XXXX',
              prefixIcon: const Icon(Icons.phone),
              errorText: error,
            ),
            onSubmitted: (_) => send(),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: Text(l10n.actionCancel)),
            FilledButton.icon(icon: const Icon(Icons.send), label: Text(l10n.whatsappSend), onPressed: send),
          ],
        );
      },
    ),
  );
}
