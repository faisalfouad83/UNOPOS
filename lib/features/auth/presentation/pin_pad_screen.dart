import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/routing/route_paths.dart';
import '../../../core/widgets/numeric_pin_pad.dart';
import '../domain/session_controller.dart';
import 'developer_signin_dialog.dart';

class PinPadScreen extends ConsumerStatefulWidget {
  const PinPadScreen({super.key});

  @override
  ConsumerState<PinPadScreen> createState() => _PinPadScreenState();
}

class _PinPadScreenState extends ConsumerState<PinPadScreen> {
  String _pin = '';
  int _wrongAttempts = 0;
  int _lockedSeconds = 0;
  Timer? _lockTimer;
  bool _checking = false;
  String? _error;

  static const _maxAttemptsBeforeLock = 5;
  static const _lockDurationSeconds = 30;

  @override
  void dispose() {
    _lockTimer?.cancel();
    super.dispose();
  }

  void _startLock() {
    setState(() => _lockedSeconds = _lockDurationSeconds);
    _lockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() => _lockedSeconds--);
      if (_lockedSeconds <= 0) {
        timer.cancel();
        setState(() => _wrongAttempts = 0);
      }
    });
  }

  Future<void> _onComplete() async {
    if (_checking || _lockedSeconds > 0) return;
    setState(() {
      _checking = true;
      _error = null;
    });
    final selectedEmployee = ref.read(selectedEmployeeForPinProvider);
    final PinResult result;
    try {
      result = await ref.read(sessionControllerProvider.notifier).submitPin(_pin, selectedEmployee: selectedEmployee);
    } catch (e) {
      // Without this, any server-side failure (e.g. a stale/mismatched auth
      // session) left _checking stuck true forever — the pad looked frozen
      // with no feedback at all, indistinguishable from a real app hang.
      if (mounted) {
        setState(() {
          _pin = '';
          _checking = false;
          _error = '$e';
        });
      }
      return;
    }

    if (!mounted) return;
    switch (result) {
      case PinResult.success:
        ref.read(selectedEmployeeForPinProvider.notifier).state = null;
        context.go(RoutePaths.home);
      case PinResult.developerGate:
        context.go(RoutePaths.developerHome);
      case PinResult.developerGateNeedsAuth:
        setState(() {
          _pin = '';
          _checking = false;
        });
        final signedIn = await showDeveloperSignInDialog(context, ref);
        if (signedIn && mounted) context.go(RoutePaths.developerHome);
      case PinResult.incorrect:
        _wrongAttempts++;
        setState(() {
          _pin = '';
          _checking = false;
        });
        if (_wrongAttempts >= _maxAttemptsBeforeLock) {
          _startLock();
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final employee = ref.watch(selectedEmployeeForPinProvider);
    final locked = _lockedSeconds > 0;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ref.read(selectedEmployeeForPinProvider.notifier).state = null;
            context.go(RoutePaths.tilePicker);
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (employee != null) ...[
              Text(employee.name, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
            ],
            Text(l10n.pinPadTitle, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 24),
            if (locked)
              Text(
                l10n.pinPadLocked(_lockedSeconds),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              )
            else if (_wrongAttempts > 0)
              Text(
                l10n.pinPadIncorrect,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              )
            else if (_error != null)
              Text(
                '${l10n.errorGeneric}\n$_error',
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            const SizedBox(height: 16),
            IgnorePointer(
              ignoring: locked || _checking,
              child: Opacity(
                opacity: locked ? 0.4 : 1,
                child: NumericPinPad(
                  value: _pin,
                  maxLength: 4,
                  onChanged: (v) => setState(() => _pin = v),
                  onSubmit: _onComplete,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
