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
  final l10n = AppLocalizations.of(context);
  final controller = TextEditingController(text: '0');
  final session = ref.read(sessionControllerProvider);
  if (session.store == null || session.employee == null || session.currentBranchId == null) return;

  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: Text(l10n.posShiftOpen),
      content: TextField(
        controller: controller,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
        decoration: InputDecoration(labelText: l10n.posOpeningFloat),
      ),
      actions: [
        FilledButton(
          onPressed: () async {
            final amount = Money.toMinorUnits(double.tryParse(controller.text) ?? 0);
            await ref.read(shiftsRepositoryProvider).openShift(
                  storeId: session.store!.id,
                  branchId: session.currentBranchId!,
                  cashierId: session.employee!.id,
                  openingCashFloatMinorUnits: amount,
                );
            ref.invalidate(openShiftProvider((storeId: session.store!.id, cashierId: session.employee!.id)));
            if (context.mounted) Navigator.of(context).pop();
          },
          child: Text(l10n.actionConfirm),
        ),
      ],
    ),
  );
}
