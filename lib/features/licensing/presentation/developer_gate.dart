import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/magic_passcodes.dart';
import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/routing/route_paths.dart';
import '../../../core/supabase/supabase_config.dart';
import '../../../core/widgets/numeric_pin_pad.dart';
import '../../auth/domain/session_controller.dart';
import '../../auth/presentation/developer_signin_dialog.dart';
import '../../support/presentation/support_signin_dialog.dart';

/// Wrong entry codes allowed before the prompt locks for a while — a
/// brake on guessing (the codes only open sign-in forms; access itself is
/// always checked by the server).
class _GateThrottle {
  static int _failures = 0;
  static DateTime? _lockedUntil;

  static bool get locked => _lockedUntil != null && DateTime.now().isBefore(_lockedUntil!);

  static void fail() {
    _failures++;
    if (_failures >= 5) {
      _lockedUntil = DateTime.now().add(const Duration(minutes: 5));
      _failures = 0;
    }
  }

  static void reset() => _failures = 0;
}

/// The hidden entry (hold the logo, then a code): 1313 opens the developer
/// sign-in, 1414 the support staff sign-in. Reachable before any store
/// exists and from the license-expired lock screen.
Future<void> showDeveloperGate(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  if (_GateThrottle.locked) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.gateLocked)));
    return;
  }
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
              if (pin == MagicPasscodes.supportGate && kUseSupabaseBackend) {
                _GateThrottle.reset();
                Navigator.of(dialogContext).pop();
                final signedIn = await showSupportSignInDialog(context, ref);
                if (signedIn && context.mounted) context.go(RoutePaths.support);
                return;
              }
              // Must go through SessionController so session.developerMode
              // actually flips to true — RouteGuard only lets the Developer
              // console through once that flag is set.
              final result = await ref.read(sessionControllerProvider.notifier).submitPin(pin);
              if (dialogContext.mounted) Navigator.of(dialogContext).pop();
              if (result == PinResult.developerGate && context.mounted) {
                _GateThrottle.reset();
                context.go(RoutePaths.developerHome);
              } else if (result == PinResult.developerGateNeedsAuth && context.mounted) {
                _GateThrottle.reset();
                // On the shared backend, 1313 only reveals the real sign-in
                // form — it never grants access by itself.
                final signedIn = await showDeveloperSignInDialog(context, ref);
                if (signedIn && context.mounted) context.go(RoutePaths.developerHome);
              } else {
                _GateThrottle.fail();
              }
            },
          ),
        ),
      ),
    ),
  );
}

/// Opens [onHeld] only after the child has been pressed and held for
/// [duration] — a tap, a short press or a drag never does.
class HoldToOpen extends StatefulWidget {
  const HoldToOpen({super.key, required this.child, required this.onHeld, this.duration = MagicPasscodes.gateHold});

  final Widget child;
  final VoidCallback onHeld;
  final Duration duration;

  @override
  State<HoldToOpen> createState() => _HoldToOpenState();
}

class _HoldToOpenState extends State<HoldToOpen> {
  Timer? _timer;
  Offset? _downPos;

  void _cancel() {
    _timer?.cancel();
    _timer = null;
    _downPos = null;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (e) {
        _cancel();
        _downPos = e.position;
        _timer = Timer(widget.duration, () {
          _timer = null;
          if (mounted) widget.onHeld();
        });
      },
      // Moving away (a scroll or drag) is not a hold.
      onPointerMove: (e) {
        if (_downPos != null && (e.position - _downPos!).distance > 24) _cancel();
      },
      onPointerUp: (_) => _cancel(),
      onPointerCancel: (_) => _cancel(),
      child: widget.child,
    );
  }
}
