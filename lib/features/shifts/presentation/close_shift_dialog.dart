import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/utils/formatters.dart';
import '../../auth/domain/session_controller.dart';
import '../domain/shifts_models.dart';
import 'shift_providers.dart';

/// Cash reconciliation at end of shift: expected = opening float + all cash
/// sales completed during the shift; discrepancy = counted - expected.
Future<void> showCloseShiftDialog(BuildContext context, WidgetRef ref, ShiftRecord shift) async {
  final l10n = AppLocalizations.of(context);
  final session = ref.read(sessionControllerProvider);
  if (session.store == null) return;

  final sales = await ref.read(posRepositoryProvider).watchCompletedSales(session.store!.id, from: shift.openedAt).first;
  final cashSalesTotal = sales
      .where((s) => s.shiftId == shift.id && s.paymentMethod?.name == 'cash')
      .fold<int>(0, (sum, s) => sum + s.grandTotalMinorUnits);
  final expected = shift.openingCashFloatMinorUnits + cashSalesTotal;

  final controller = TextEditingController(text: Money.toMajorUnits(expected).toStringAsFixed(2));

  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: Text(l10n.posShiftClose),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${l10n.commonAmount} (${l10n.commonStatus}: ${Money.format(expected, currencySymbol: r'$')})'),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
            decoration: const InputDecoration(labelText: 'Counted cash'),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.actionCancel)),
        FilledButton(
          onPressed: () async {
            final counted = Money.toMinorUnits(double.tryParse(controller.text) ?? 0);
            await ref.read(shiftsRepositoryProvider).closeShift(
                  shiftId: shift.id,
                  expectedCashAtCloseMinorUnits: expected,
                  countedCashAtCloseMinorUnits: counted,
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
