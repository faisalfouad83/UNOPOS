import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/utils/formatters.dart';
import '../../auth/domain/session_controller.dart';
import 'shift_providers.dart';

/// Shown whenever a cashier reaches the POS screen with no open shift.
/// Returns once a shift has been opened.
Future<void> showOpenShiftDialog(BuildContext context, WidgetRef ref) async {
  final session = ref.read(sessionControllerProvider);
  if (session.store == null || session.employee == null || session.currentBranchId == null) return;
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => const _OpenShiftDialog(),
  );
}

class _OpenShiftDialog extends ConsumerStatefulWidget {
  const _OpenShiftDialog();

  @override
  ConsumerState<_OpenShiftDialog> createState() => _OpenShiftDialogState();
}

class _OpenShiftDialogState extends ConsumerState<_OpenShiftDialog> {
  final _controller = TextEditingController(text: '0');

  /// Set before the first await, so a second tap can't open a second shift.
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _open() async {
    if (_submitting) return;
    final session = ref.read(sessionControllerProvider);
    final repo = ref.read(shiftsRepositoryProvider);
    final key = (storeId: session.store!.id, cashierId: session.employee!.id);
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await repo.openShift(
        storeId: session.store!.id,
        branchId: session.currentBranchId!,
        cashierId: session.employee!.id,
        openingCashFloatMinorUnits: Money.toMinorUnits(double.tryParse(_controller.text) ?? 0),
      );
      if (!mounted) return;
      ref.invalidate(openShiftProvider(key));
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = AppLocalizations.of(context).errorGeneric;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.posShiftOpen),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
        decoration: InputDecoration(labelText: l10n.posOpeningFloat, errorText: _error),
        onSubmitted: (_) => _open(),
      ),
      actions: [
        FilledButton(
          onPressed: _submitting ? null : _open,
          child: _submitting
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(l10n.actionConfirm),
        ),
      ],
    );
  }
}
