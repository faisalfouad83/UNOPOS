import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/utils/formatters.dart';
import '../../auth/domain/session_controller.dart';
import '../domain/inventory_models.dart';
import '../domain/product_expiry.dart';
import 'product_edit_dialog.dart';

final _productsForExpiryProvider = StreamProvider.autoDispose.family<List<ProductRecord>, String>((ref, storeId) {
  return ref.watch(inventoryRepositoryProvider).watchProducts(storeId);
});

/// Products that are expired or about to expire, soonest first.
class ExpiryScreen extends ConsumerStatefulWidget {
  const ExpiryScreen({super.key});

  @override
  ConsumerState<ExpiryScreen> createState() => _ExpiryScreenState();
}

class _ExpiryScreenState extends ConsumerState<ExpiryScreen> {
  int _warnDays = 30;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final storeId = ref.watch(sessionControllerProvider).store?.id;
    if (storeId == null) return const Scaffold(body: SizedBox.shrink());
    final productsAsync = ref.watch(_productsForExpiryProvider(storeId));
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.expiryTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: SegmentedButton<int>(
              segments: [
                for (final d in const [30, 60, 90]) ButtonSegment(value: d, label: Text(l10n.expiryWithinDays(d))),
              ],
              selected: {_warnDays},
              onSelectionChanged: (s) => setState(() => _warnDays = s.first),
            ),
          ),
          Expanded(
            child: productsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text(l10n.errorGeneric)),
              data: (products) {
                final near = productsNearExpiry(products, warnDays: _warnDays);
                if (near.isEmpty) return Center(child: Text(l10n.expiryNone));
                return ListView.builder(
                  itemCount: near.length,
                  itemBuilder: (context, i) {
                    final p = near[i];
                    final days = daysUntilExpiry(p)!;
                    final expired = days < 0;
                    final color = expired ? scheme.error : Colors.orange.shade800;
                    return ListTile(
                      leading: Icon(expired ? Icons.dangerous_outlined : Icons.schedule, color: color),
                      title: Text(p.name),
                      subtitle: Text('${AppDateFormat.shortDate(p.expiryDate!)} · ${p.barcode ?? p.sku}'),
                      trailing: Text(
                        expired ? l10n.expiryExpiredDaysAgo(-days) : l10n.expiryInDays(days),
                        style: TextStyle(color: color, fontWeight: FontWeight.w600),
                      ),
                      onTap: () => showProductEditDialog(context, ref, existing: p),
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
