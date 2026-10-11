import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/permissions.dart';
import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/utils/formatters.dart';
import '../../auth/domain/session_controller.dart';
import '../../printing/presentation/sale_receipt.dart';
import '../../printing/presentation/whatsapp_receipt_dialog.dart';
import '../domain/pos_models.dart';
import 'process_return_dialog.dart';

final _todaysSalesProvider = StreamProvider.autoDispose.family<List<SaleRecord>, String>((ref, storeId) {
  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);
  return ref.watch(posRepositoryProvider).watchCompletedSales(storeId, from: startOfDay);
});

final _searchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

class SalesHistoryScreen extends ConsumerWidget {
  const SalesHistoryScreen({super.key, required this.storeId});
  final String storeId;

  Future<void> _reprint(BuildContext context, WidgetRef ref, SaleRecord sale) async {
    final l10n = AppLocalizations.of(context);
    try {
      final settings = await ref.read(settingsRepositoryProvider).ensureSettings(storeId);
      final doc = await buildSaleReceipt(
        inventory: ref.read(inventoryRepositoryProvider),
        session: ref.read(sessionControllerProvider),
        sale: sale,
        settings: settings,
        l10n: l10n,
      );
      await printReceiptDocument(doc, settings);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.posPrintReceipt)));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.errorGeneric)));
      }
    }
  }

  Future<void> _sendWhatsApp(BuildContext context, WidgetRef ref, SaleRecord sale) async {
    final l10n = AppLocalizations.of(context);
    try {
      final settings = await ref.read(settingsRepositoryProvider).ensureSettings(storeId);
      final doc = await buildSaleReceipt(
        inventory: ref.read(inventoryRepositoryProvider),
        session: ref.read(sessionControllerProvider),
        sale: sale,
        settings: settings,
        l10n: l10n,
      );
      if (context.mounted) await showWhatsAppReceiptDialog(context, doc);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.errorGeneric)));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final salesAsync = ref.watch(_todaysSalesProvider(storeId));
    final query = ref.watch(_searchQueryProvider).trim().toLowerCase();
    final canReturn = ref.watch(sessionControllerProvider).employee?.can(AppPermission.processReturns) ?? false;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.posSalesHistory)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: l10n.actionSearch),
              onChanged: (v) => ref.read(_searchQueryProvider.notifier).state = v,
            ),
          ),
          Expanded(
            child: salesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text(l10n.errorGeneric)),
              data: (sales) {
                final filtered =
                    query.isEmpty ? sales : sales.where((s) => s.saleNumber.toLowerCase().contains(query)).toList();
                if (filtered.isEmpty) return Center(child: Text(l10n.posEmptyCart));
                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final sale = filtered[index];
                    return ListTile(
                      title: Text('${sale.saleNumber} · ${Money.format(sale.grandTotalMinorUnits)}'),
                      subtitle: Text(
                        '${sale.paymentMethod?.name ?? ''} · ${AppDateFormat.dateTime(sale.completedAt ?? sale.createdAt)}',
                      ),
                      trailing: Wrap(
                        spacing: 4,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.print_outlined),
                            tooltip: l10n.posPrintReceipt,
                            onPressed: () => _reprint(context, ref, sale),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chat_outlined),
                            tooltip: l10n.whatsappSendReceipt,
                            onPressed: () => _sendWhatsApp(context, ref, sale),
                          ),
                          if (canReturn)
                            TextButton(
                              child: Text(l10n.posProcessReturn),
                              onPressed: () => showProcessReturnDialog(context, ref, sale),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
