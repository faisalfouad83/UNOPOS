import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../auth/domain/session_controller.dart';

/// Support staff sign-in with their own account. Returns true once signed
/// in (the server confirmed an active support account).
Future<bool> showSupportSignInDialog(BuildContext context, WidgetRef ref) async {
  final email = TextEditingController();
  final password = TextEditingController();
  var submitting = false;
  String? error;
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setState) {
        final l10n = AppLocalizations.of(dialogContext);
        Future<void> submit() async {
          if (submitting) return;
          setState(() {
            submitting = true;
            error = null;
          });
          final ok = await ref.read(sessionControllerProvider.notifier).signInSupport(email.text.trim(), password.text);
          if (!dialogContext.mounted) return;
          if (ok) {
            Navigator.of(dialogContext).pop(true);
          } else {
            setState(() {
              submitting = false;
              error = l10n.loginInvalidCredentials;
            });
          }
        }

        return AlertDialog(
          icon: const Icon(Icons.support_agent),
          title: Text(l10n.supportSignInTitle),
          content: SizedBox(
            width: 340,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: email,
                  autofocus: true,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(labelText: l10n.developerSignInEmail),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: password,
                  obscureText: true,
                  decoration: InputDecoration(labelText: l10n.developerSignInPassword, errorText: error),
                  onSubmitted: (_) => submit(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: Text(l10n.actionCancel)),
            FilledButton(
              onPressed: submitting ? null : submit,
              child: submitting
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(l10n.loginButton),
            ),
          ],
        );
      },
    ),
  );
  email.dispose();
  password.dispose();
  return result ?? false;
}
