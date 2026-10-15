import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/utils/formatters.dart';
import '../../auth/domain/session_controller.dart';
import '../domain/suppliers_models.dart';
import 'add_supplier_dialog.dart';
import 'supplier_payment_dialog.dart';

final _suppliersProvider = StreamProvider.autoDispose.family<List<SupplierRecord>, String>((ref, storeId) {
  return ref.watch(suppliersRepositoryProvider).watchSuppliers(storeId);
});

final _supplierBalanceProvider = FutureProvider.autoDispose.family<int, String>((ref, supplierId) {
  return ref.watch(suppliersRepositoryProvider).balanceOwed(supplierId);
});

class SuppliersScreen extends ConsumerWidget {
  const SuppliersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final storeId = ref.watch(sessionControllerProvider).store?.id;
    if (storeId == null) return const Scaffold(body: SizedBox.shrink());

    final suppliersAsync = ref.watch(_suppliersProvider(storeId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.suppliersTitle)),
      body: suppliersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text(l10n.errorGeneric)),
        data: (suppliers) {
          if (suppliers.isEmpty) return Center(child: Text(l10n.suppliersAddSupplier));
          return ListView.builder(
            // Room for the add button over the last row.
            padding: const EdgeInsets.only(bottom: 88),
            itemCount: suppliers.length,
            itemBuilder: (context, index) {
              final supplier = suppliers[index];
              final balanceAsync = ref.watch(_supplierBalanceProvider(supplier.id));
              final contact = [
                if (supplier.contactPhone?.isNotEmpty ?? false) supplier.contactPhone!,
                if (supplier.contactPerson?.isNotEmpty ?? false) supplier.contactPerson!,
              ].join(' · ');
              final balance = balanceAsync.valueOrNull;
              return ListTile(
                leading: const Icon(Icons.local_shipping_outlined),
                title: Text(supplier.name, maxLines: 2, overflow: TextOverflow.ellipsis),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (contact.isNotEmpty) Text(contact, maxLines: 1, overflow: TextOverflow.ellipsis),
                    balanceAsync.when(
                      loading: () => const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                      ),
                      error: (e, st) => Text(l10n.errorGeneric),
                      data: (balance) => Text(
                        '${l10n.suppliersBalanceOwed}: ${Money.format(balance)}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
                trailing: balance == null || balance <= 0
                    ? null
                    : IconButton.filledTonal(
                        tooltip: l10n.suppliersRecordPayment,
                        icon: const Icon(Icons.payments_outlined),
                        onPressed: () async {
                          final recorded = await showSupplierPaymentDialog(context, ref, supplier, balance);
                          if (recorded) ref.invalidate(_supplierBalanceProvider(supplier.id));
                        },
                      ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showAddSupplierDialog(context, ref),
        icon: const Icon(Icons.add),
        label: Text(l10n.suppliersAddSupplier),
      ),
    );
  }
}
