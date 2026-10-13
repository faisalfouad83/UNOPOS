import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/widgets/numeric_pin_pad.dart';
import '../../auth/domain/session_controller.dart';
import '../domain/break_models.dart';
import 'break_providers.dart';

/// Shown while an employee is on a break: the till is locked, the time left
/// counts down, and only that employee's own PIN brings them back.
class BreakLockScreen extends ConsumerStatefulWidget {
  const BreakLockScreen({super.key});

  @override
  ConsumerState<BreakLockScreen> createState() => _BreakLockScreenState();
}

class _BreakLockScreenState extends ConsumerState<BreakLockScreen> {
  Timer? _ticker;
  String _pin = '';
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _endBreak() async {
    final current = ref.read(activeBreakProvider);
    if (current == null || _busy) return;
    final l10n = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final ended = await ref.read(breaksRepositoryProvider).endBreak(breakId: current.id, pin: _pin);
      if (!mounted) return;
      if (ended.exceededMinutes > 0) {
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            icon: Icon(Icons.warning_amber_rounded, color: Theme.of(context).colorScheme.error),
            title: Text(l10n.breakExceededTitle),
            content: Text(l10n.breakExceededMessage(ended.exceededMinutes)),
            actions: [FilledButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.actionClose))],
          ),
        );
      }
      ref.read(activeBreakProvider.notifier).state = null;
    } on BreakException catch (e) {
      setState(() {
        _pin = '';
        _error = e.wrongPin ? l10n.breakWrongPin : l10n.errorGeneric;
      });
    } catch (_) {
      setState(() {
        _pin = '';
        _error = l10n.errorGeneric;
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final current = ref.watch(activeBreakProvider);
    final employee = ref.watch(sessionControllerProvider).employee;
    if (current == null) return const Scaffold(body: SizedBox.shrink());

    final left = current.allowedUntil.difference(DateTime.now());
    final over = left.isNegative;
    String mmss(Duration d) {
      final s = d.inSeconds.abs();
      return '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';
    }

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 380),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.free_breakfast_outlined, size: 56, color: theme.colorScheme.primary),
                    const SizedBox(height: 12),
                    Text(l10n.breakOnBreak(employee?.name ?? ''),
                        style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
                    const SizedBox(height: 4),
                    Text(l10n.breakTillLocked, style: theme.textTheme.bodySmall, textAlign: TextAlign.center),
                    const SizedBox(height: 20),
                    Text(
                      over ? '+${mmss(left)}' : mmss(left),
                      style: theme.textTheme.displayMedium?.copyWith(
                        color: over ? theme.colorScheme.error : null,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    Text(
                      over ? l10n.breakOverTime : l10n.breakTimeLeft,
                      style: theme.textTheme.labelLarge?.copyWith(color: over ? theme.colorScheme.error : null),
                    ),
                    const SizedBox(height: 24),
                    Text(l10n.breakEnterPinToReturn, style: theme.textTheme.titleSmall),
                    const SizedBox(height: 8),
                    Text('•' * _pin.length, style: theme.textTheme.headlineMedium),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
                      ),
                    const SizedBox(height: 8),
                    AbsorbPointer(
                      absorbing: _busy,
                      child: NumericPinPad(
                        value: _pin,
                        maxLength: 4,
                        onChanged: (v) => setState(() {
                          _pin = v;
                          _error = null;
                        }),
                        onSubmit: _endBreak,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
