import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/widgets/numeric_pin_pad.dart';
import '../application/price_checker_mode.dart';

/// Wrong exit codes allowed before the pad locks for a while, kept across
/// openings of the dialog (a brake on guessing at a customer kiosk).
class _ExitThrottle {
  static const int maxAttempts = 5;
  static const Duration lockFor = Duration(seconds: 30);
  static int failures = 0;
  static DateTime? lockedUntil;

  static int get secondsLeft {
    final until = lockedUntil;
    if (until == null) return 0;
    final left = until.difference(DateTime.now()).inSeconds + 1;
    return left > 0 ? left : 0;
  }

  static void fail() {
    failures++;
    if (failures >= maxAttempts) {
      lockedUntil = DateTime.now().add(lockFor);
      failures = 0;
    }
  }

  static void reset() {
    failures = 0;
    lockedUntil = null;
  }
}

/// Asks for the price-checker code; true once it was right and the mode
/// is off (the router then leaves the price checker by itself).
Future<bool> showPriceCheckerExitDialog(BuildContext context) async {
  final left = await showDialog<bool>(context: context, builder: (_) => const _ExitDialog());
  return left == true;
}

class _ExitDialog extends ConsumerStatefulWidget {
  const _ExitDialog();

  @override
  ConsumerState<_ExitDialog> createState() => _ExitDialogState();
}

class _ExitDialogState extends ConsumerState<_ExitDialog> {
  String _pin = '';
  bool _wrong = false;
  bool _checking = false;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _ExitThrottle.lockedUntil != null) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_checking || _ExitThrottle.secondsLeft > 0) return;
    _checking = true;
    final ok = await ref.read(priceCheckerModeProvider.notifier).tryExit(_pin);
    _checking = false;
    if (!mounted) return;
    if (ok) {
      _ExitThrottle.reset();
      Navigator.of(context).pop(true);
      return;
    }
    _ExitThrottle.fail();
    setState(() {
      _pin = '';
      _wrong = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final locked = _ExitThrottle.secondsLeft;
    return AlertDialog(
      title: Text(l10n.priceCheckerExitPrompt, textAlign: TextAlign.center),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 320,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 40,
                child: Center(
                  child: locked > 0
                      ? Text(l10n.priceCheckerExitLocked(locked),
                          textAlign: TextAlign.center, style: TextStyle(color: scheme.error))
                      : _wrong
                          ? Text(l10n.priceCheckerExitWrong,
                              textAlign: TextAlign.center, style: TextStyle(color: scheme.error))
                          : null,
                ),
              ),
              IgnorePointer(
                ignoring: locked > 0,
                child: Opacity(
                  opacity: locked > 0 ? 0.4 : 1,
                  child: NumericPinPad(
                    value: _pin,
                    onChanged: (v) => setState(() {
                      _pin = v;
                      if (v.isNotEmpty) _wrong = false;
                    }),
                    onSubmit: _submit,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.actionCancel)),
      ],
    );
  }
}
