import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../domain/session_controller.dart';

/// The real sign-in form behind the 1313 shortcut on the shared Supabase
/// backend (see [SessionController.signInDeveloper]). Shown from both the
/// activation screen's hidden long-press gate and the employee PIN pad,
/// since 1313 must stay reachable from either place. Returns true once
/// [SessionState.developerMode] is actually set.
Future<bool> showDeveloperSignInDialog(BuildContext context, WidgetRef ref) async {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  var submitting = false;
  String? error;

  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setDialogState) {
        final l10n = AppLocalizations.of(dialogContext);
        Future<void> submit() async {
          setDialogState(() {
            submitting = true;
            error = null;
          });
          final ok = await ref
              .read(sessionControllerProvider.notifier)
              .signInDeveloper(emailController.text.trim(), passwordController.text);
          if (!dialogContext.mounted) return;
          if (ok) {
            Navigator.of(dialogContext).pop(true);
          } else {
            setDialogState(() {
              submitting = false;
              error = l10n.loginInvalidCredentials;
            });
          }
        }

        return AlertDialog(
          title: Text(l10n.developerSignInTitle),
          content: SizedBox(
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: emailController,
                  autofocus: true,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(labelText: l10n.developerSignInEmail),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: l10n.developerSignInPassword, errorText: error),
                  onSubmitted: (_) => submitting ? null : submit(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: submitting ? null : () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.actionCancel),
            ),
            FilledButton(
              onPressed: submitting ? null : submit,
              child: submitting
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(l10n.loginButton),
            ),
          ],
        );
      },
    ),
  );

  emailController.dispose();
  passwordController.dispose();
  return result ?? false;
}
