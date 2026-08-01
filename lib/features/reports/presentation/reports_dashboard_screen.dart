import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/utils/formatters.dart';
import '../../auth/domain/session_controller.dart';
import '../../inventory/domain/inventory_models.dart';
import '../../pos/domain/pos_models.dart';

typedef _BranchKey = ({String storeId, String branchId});

final _last30DaysSalesProvider = StreamProvider.autoDispose.family<List<SaleRecord>, String>((ref, storeId) {
  final from = DateTime.now().subtract(const Duration(days: 30));
  return ref.watch(posRepositoryProvider).watchCompletedSales(storeId, from: from);
});

final _lowStockProvider = StreamProvider.autoDispose.family<List<ProductRecord>, _BranchKey>((ref, key) {
  return ref.watch(inventoryRepositoryProvider).watchLowStock(key.storeId, key.branchId);
});

final _allProductsProvider = StreamProvider.autoDispose.family<List<ProductRecord>, String>((ref, storeId) {
  return ref.watch(inventoryRepositoryProvider).watchProducts(storeId);
});

class ReportsDashboardScreen extends ConsumerWidget {
  const ReportsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(sessionControllerProvider);
    final storeId = session.store?.id;
    final branchId = session.currentBranchId;
    if (storeId == null || branchId == null) return const Scaffold(body: SizedBox.shrink());

    final salesAsync = ref.watch(_last30DaysSalesProvider(storeId));
    final lowStockAsync = ref.watch(_lowStockProvider((storeId: storeId, branchId: branchId)));
    final productsAsync = ref.watch(_allProductsProvider(storeId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navReports)),
      body: salesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text(l10n.errorGeneric)),
        data: (sales) {
          final productNames = {for (final p in (productsAsync.value ?? const <ProductRecord>[])) p.id: p.name};
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SalesTrendCard(sales: sales),
              const SizedBox(height: 16),
              _TopProductsCard(sales: sales, productNames: productNames),
              const SizedBox(height: 16),
              _LowStockCard(lowStockAsync: lowStockAsync),
            ],
          );
        },
      ),
    );
  }
}

class _SalesTrendCard extends StatelessWidget {
  const _SalesTrendCard({required this.sales});
  final List<SaleRecord> sales;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = List.generate(7, (i) => DateTime(now.year, now.month, now.day).subtract(Duration(days: 6 - i)));
    final totalsByDay = <DateTime, int>{for (final d in days) d: 0};

    for (final sale in sales) {
      final date = sale.completedAt ?? sale.createdAt;
      final day = DateTime(date.year, date.month, date.day);
      if (totalsByDay.containsKey(day)) {
        totalsByDay[day] = totalsByDay[day]! + sale.grandTotalMinorUnits;
      }
    }

    final maxValue = totalsByDay.values.fold<int>(0, (m, v) => v > m ? v : m);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sales — last 7 days', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: maxValue == 0
                  ? Center(child: Text(AppLocalizations.of(context).errorGeneric))
                  : BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: maxValue * 1.2,
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index < 0 || index >= days.length) return const SizedBox.shrink();
                                final day = days[index];
                                return Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text('${day.month}/${day.day}', style: const TextStyle(fontSize: 10)),
                                );
                              },
                            ),
                          ),
                        ),
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        barGroups: [
                          for (var i = 0; i < days.length; i++)
                            BarChartGroupData(
                              x: i,
                              barRods: [
                                BarChartRodData(
                                  toY: (totalsByDay[days[i]] ?? 0).toDouble(),
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 18,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopProductsCard extends StatelessWidget {
  const _TopProductsCard({required this.sales, required this.productNames});
  final List<SaleRecord> sales;
  final Map<String, String> productNames;

  @override
  Widget build(BuildContext context) {
    final revenueByProduct = <String, int>{};
    for (final sale in sales) {
      for (final line in sale.lines) {
        revenueByProduct[line.productId] = (revenueByProduct[line.productId] ?? 0) + line.lineTotalMinorUnits;
      }
    }
    final ranked = revenueByProduct.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final top = ranked.take(5).toList();
    final maxValue = top.isEmpty ? 1 : top.first.value;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Top products — last 30 days', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            if (top.isEmpty) Text(AppLocalizations.of(context).errorGeneric),
            ...top.map((entry) {
              final fraction = maxValue == 0 ? 0.0 : entry.value / maxValue;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(productNames[entry.key] ?? entry.key, overflow: TextOverflow.ellipsis)),
                        Text(Money.format(entry.value, currencySymbol: r'$')),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: fraction,
                        minHeight: 6,
                        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _LowStockCard extends StatelessWidget {
  const _LowStockCard({required this.lowStockAsync});
  final AsyncValue<List<ProductRecord>> lowStockAsync;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.inventoryLowStock, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            lowStockAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, st) => Text(l10n.errorGeneric),
              data: (products) {
                if (products.isEmpty) return const Text('Nothing below reorder level');
                return Column(
                  children: products
                      .map((p) => ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.warning_amber_rounded, color: Theme.of(context).colorScheme.error),
                            title: Text(p.name),
                            trailing: Text('Reorder: ${p.reorderLevel}'),
                          ))
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
