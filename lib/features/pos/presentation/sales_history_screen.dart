import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/utils/formatters.dart';
import '../domain/pos_models.dart';
import 'process_return_dialog.dart';

final _todaysSalesProvider = StreamProvider.autoDispose.family<List<SaleRecord>, String>((ref, storeId) {
  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);
  return ref.watch(posRepositoryProvider).watchCompletedSales(storeId, from: startOfDay);
});

class SalesHistoryScreen extends ConsumerWidget {
  const SalesHistoryScreen({super.key, required this.storeId});
  final String storeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final salesAsync = ref.watch(_todaysSalesProvider(storeId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.posSalesHistory)),
      body: salesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text(l10n.errorGeneric)),
        data: (sales) {
          if (sales.isEmpty) return Center(child: Text(l10n.posEmptyCart));
          return ListView.builder(
            itemCount: sales.length,
            itemBuilder: (context, index) {
              final sale = sales[index];
              return ListTile(
                title: Text('${sale.saleNumber} · ${Money.format(sale.grandTotalMinorUnits, currencySymbol: r'$')}'),
                subtitle: Text(
                  '${sale.paymentMethod?.name ?? ''} · ${AppDateFormat.dateTime(sale.completedAt ?? sale.createdAt)}',
                ),
                trailing: TextButton(
                  child: Text(l10n.posProcessReturn),
                  onPressed: () => showProcessReturnDialog(context, ref, sale),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
