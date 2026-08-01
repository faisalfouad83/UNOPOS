import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../auth/domain/session_controller.dart';
import '../domain/pos_models.dart';
import '../domain/process_sale_return_use_case.dart';

Future<void> showProcessReturnDialog(BuildContext context, WidgetRef ref, SaleRecord sale) async {
  final l10n = AppLocalizations.of(context);
  final session = ref.read(sessionControllerProvider);
  if (session.employee == null || session.store == null) return;

  final products = await ref.read(inventoryRepositoryProvider).watchProducts(session.store!.id).first;
  final namesById = {for (final p in products) p.id: p.name};
  if (!context.mounted) return;

  final quantities = {for (final line in sale.lines) line.id: 0};
  bool refundToCash = sale.paymentMethod == SalePaymentMethod.cash || sale.paymentMethod == null;

  await showDialog<void>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text('${l10n.posProcessReturn}: ${sale.saleNumber}'),
        content: SizedBox(
          width: 440,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...sale.lines.map((line) {
                  final selected = quantities[line.id] ?? 0;
                  return Row(
                    children: [
                      Expanded(child: Text(namesById[line.productId] ?? line.productId)),
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: selected > 0 ? () => setState(() => quantities[line.id] = selected - 1) : null,
                      ),
                      Text('$selected / ${line.quantity}'),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: selected < line.quantity ? () => setState(() => quantities[line.id] = selected + 1) : null,
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 12),
                if (sale.paymentMethod != SalePaymentMethod.payLater)
                  SegmentedButton<bool>(
                    segments: [
                      ButtonSegment(value: true, label: Text(l10n.posPayCash)),
                      ButtonSegment(value: false, label: Text(l10n.posPayCard)),
                    ],
                    selected: {refundToCash},
                    onSelectionChanged: (s) => setState(() => refundToCash = s.first),
                  )
                else
                  Text(l10n.posReturnReducesBalance),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.actionCancel)),
          FilledButton(
            onPressed: quantities.values.every((q) => q == 0)
                ? null
                : () async {
                    await ref.read(processSaleReturnUseCaseProvider).processReturn(
                          originalSale: sale,
                          processedByUserId: session.employee!.id,
                          refundToCash: refundToCash,
                          returnLines: sale.lines
                              .map((line) => ReturnLineInput(saleLine: line, quantityReturned: quantities[line.id] ?? 0))
                              .toList(),
                        );
                    if (context.mounted) Navigator.of(context).pop();
                  },
            child: Text(l10n.actionConfirm),
          ),
        ],
      ),
    ),
  );
}
