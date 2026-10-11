import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_paths.dart';
import '../../../core/widgets/numeric_pin_pad.dart';
import '../../auth/domain/session_controller.dart';
import '../../auth/presentation/developer_signin_dialog.dart';

/// The hidden developer entry (long-press the logo, then 1313), reachable
/// before any store exists and from the license-expired lock screen, so a
/// new code can always be generated.
Future<void> showDeveloperGate(BuildContext context, WidgetRef ref) async {
  var pin = '';
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setDialogState) => AlertDialog(
        content: SizedBox(
          width: 320,
          child: NumericPinPad(
            value: pin,
            onChanged: (v) => setDialogState(() => pin = v),
            onSubmit: () async {
              // Must go through SessionController so session.developerMode
              // actually flips to true — RouteGuard only lets the Developer
              // console through once that flag is set.
              final result = await ref.read(sessionControllerProvider.notifier).submitPin(pin);
              if (dialogContext.mounted) Navigator.of(dialogContext).pop();
              if (result == PinResult.developerGate && context.mounted) {
                context.go(RoutePaths.developerHome);
              } else if (result == PinResult.developerGateNeedsAuth && context.mounted) {
                // On the shared backend, 1313 only reveals the real sign-in
                // form — it never grants access by itself.
                final signedIn = await showDeveloperSignInDialog(context, ref);
                if (signedIn && context.mounted) context.go(RoutePaths.developerHome);
              }
            },
          ),
        ),
      ),
    ),
  );
}
