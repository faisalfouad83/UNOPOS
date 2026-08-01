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
            itemCount: suppliers.length,
            itemBuilder: (context, index) {
              final supplier = suppliers[index];
              final balanceAsync = ref.watch(_supplierBalanceProvider(supplier.id));
              return ListTile(
                leading: const Icon(Icons.local_shipping_outlined),
                title: Text(supplier.name),
                subtitle: Text([
                  if (supplier.contactPhone?.isNotEmpty ?? false) supplier.contactPhone!,
                  if (supplier.contactPerson?.isNotEmpty ?? false) supplier.contactPerson!,
                ].join(' · ')),
                trailing: balanceAsync.when(
                  loading: () => const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                  error: (e, st) => const Icon(Icons.error_outline),
                  data: (balance) => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${l10n.suppliersBalanceOwed}: ${Money.format(balance, currencySymbol: r'$')}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      if (balance > 0)
                        TextButton(
                          onPressed: () => showSupplierPaymentDialog(context, ref, supplier, balance),
                          child: Text(l10n.suppliersRecordPayment),
                        ),
                    ],
                  ),
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
