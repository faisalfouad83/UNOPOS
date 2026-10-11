import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/utils/formatters.dart';
import '../../auth/domain/session_controller.dart';
import '../../inventory/domain/inventory_models.dart';
import '../../pos/domain/pos_models.dart';
import '../domain/sales_summary.dart';

typedef _BranchKey = ({String storeId, String branchId});

final _last30DaysSalesProvider = StreamProvider.autoDispose.family<List<SaleRecord>, String>((ref, storeId) {
  final from = SalesSummary.periodStart(ReportPeriod.month, DateTime.now());
  return ref.watch(posRepositoryProvider).watchCompletedSales(storeId, from: from);
});

final _lowStockProvider = StreamProvider.autoDispose.family<List<ProductRecord>, _BranchKey>((ref, key) {
  return ref.watch(inventoryRepositoryProvider).watchLowStock(key.storeId, key.branchId);
});

final _allProductsProvider = StreamProvider.autoDispose.family<List<ProductRecord>, String>((ref, storeId) {
  return ref.watch(inventoryRepositoryProvider).watchProducts(storeId);
});

final _periodProvider = StateProvider.autoDispose<ReportPeriod>((ref) => ReportPeriod.today);

/// Sales dashboard: headline figures for today / 7 / 30 days, sales over
/// time, how customers paid, best sellers, and low stock.
class ReportsDashboardScreen extends ConsumerWidget {
  const ReportsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(sessionControllerProvider);
    final storeId = session.store?.id;
    final branchId = session.currentBranchId;
    if (storeId == null || branchId == null) return const Scaffold(body: SizedBox.shrink());

    final period = ref.watch(_periodProvider);
    final salesAsync = ref.watch(_last30DaysSalesProvider(storeId));
    final lowStockAsync = ref.watch(_lowStockProvider((storeId: storeId, branchId: branchId)));
    final productsAsync = ref.watch(_allProductsProvider(storeId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navReports)),
      body: salesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text(l10n.errorGeneric)),
        data: (sales) {
          final summary = SalesSummary.of(sales, period);
          final productNames = {for (final p in (productsAsync.value ?? const <ProductRecord>[])) p.id: p.name};
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Filters sit in one row above everything they affect.
              SegmentedButton<ReportPeriod>(
                segments: [
                  ButtonSegment(value: ReportPeriod.today, label: Text(l10n.reportsToday)),
                  ButtonSegment(value: ReportPeriod.week, label: Text(l10n.reportsLast7Days)),
                  ButtonSegment(value: ReportPeriod.month, label: Text(l10n.reportsLast30Days)),
                ],
                selected: {period},
                onSelectionChanged: (s) => ref.read(_periodProvider.notifier).state = s.first,
              ),
              const SizedBox(height: 16),
              _KpiRow(summary: summary),
              const SizedBox(height: 16),
              _SalesOverTimeCard(summary: summary, period: period),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final payments = _PaymentMethodsCard(summary: summary);
                  final top = _TopProductsCard(summary: summary, productNames: productNames);
                  if (constraints.maxWidth < 720) {
                    return Column(children: [payments, const SizedBox(height: 16), top]);
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Expanded(child: payments), const SizedBox(width: 16), Expanded(child: top)],
                  );
                },
              ),
              const SizedBox(height: 16),
              _LowStockCard(lowStockAsync: lowStockAsync),
            ],
          );
        },
      ),
    );
  }
}

class _KpiRow extends StatelessWidget {
  const _KpiRow({required this.summary});
  final SalesSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final margin = summary.margin;
    final tiles = [
      _Kpi(label: l10n.reportsRevenue, value: Money.format(summary.revenueMinorUnits)),
      _Kpi(
        label: l10n.reportsProfit,
        value: Money.format(summary.profitMinorUnits),
        caption: margin == null ? null : l10n.reportsMargin((margin * 100).round()),
      ),
      _Kpi(label: l10n.reportsSalesCount, value: '${summary.salesCount}'),
      _Kpi(label: l10n.reportsAverageSale, value: Money.format(summary.averageSaleMinorUnits)),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final perRow = constraints.maxWidth >= 720 ? 4 : 2;
        const gap = 12.0;
        final width = (constraints.maxWidth - gap * (perRow - 1)) / perRow;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [for (final t in tiles) SizedBox(width: width, child: t)],
        );
      },
    );
  }
}

class _Kpi extends StatelessWidget {
  const _Kpi({required this.label, required this.value, this.caption});
  final String label;
  final String value;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.labelLarge?.copyWith(color: muted)),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Text(value, style: theme.textTheme.headlineSmall),
            ),
            if (caption != null) Text(caption!, style: theme.textTheme.bodySmall?.copyWith(color: muted)),
          ],
        ),
      ),
    );
  }
}

class _SalesOverTimeCard extends StatelessWidget {
  const _SalesOverTimeCard({required this.summary, required this.period});
  final SalesSummary summary;
  final ReportPeriod period;

  String _bucketLabel(SalesBucket b) =>
      period == ReportPeriod.today ? '${b.start.hour}:00' : '${b.start.day}/${b.start.month}';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final buckets = summary.buckets;
    final maxValue = buckets.fold<int>(0, (m, b) => b.totalMinorUnits > m ? b.totalMinorUnits : m);
    // Label every Nth bar so ticks never collide (24 hours / 30 days).
    final labelEvery = switch (period) {
      ReportPeriod.today => 3,
      ReportPeriod.week => 1,
      ReportPeriod.month => 5,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(period == ReportPeriod.today ? l10n.reportsSalesByHour : l10n.reportsSalesByDay,
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: maxValue == 0
                  ? Center(child: Text(l10n.reportsNoSales))
                  : BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: maxValue * 1.15,
                        barTouchData: BarTouchData(
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipColor: (_) => theme.colorScheme.inverseSurface,
                            getTooltipItem: (group, _, rod, __) {
                              final b = buckets[group.x];
                              return BarTooltipItem(
                                '${_bucketLabel(b)}\n${Money.format(b.totalMinorUnits)} · ${l10n.reportsSalesShort(b.count)}',
                                TextStyle(color: theme.colorScheme.onInverseSurface, fontSize: 12),
                              );
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 22,
                              getTitlesWidget: (value, meta) {
                                final i = value.toInt();
                                if (i < 0 || i >= buckets.length || i % labelEvery != 0) return const SizedBox.shrink();
                                return Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    _bucketLabel(buckets[i]),
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        gridData: FlGridData(
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (_) => FlLine(
                            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                            strokeWidth: 1,
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: [
                          for (var i = 0; i < buckets.length; i++)
                            BarChartGroupData(
                              x: i,
                              barRods: [
                                BarChartRodData(
                                  toY: buckets[i].totalMinorUnits.toDouble(),
                                  color: theme.colorScheme.primary,
                                  width: period == ReportPeriod.week ? 22 : 8,
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
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

/// Horizontal bars with the name and amount as text beside each — identity
/// is carried by the label, so a single color is enough.
class _RankedBars extends StatelessWidget {
  const _RankedBars({required this.rows});
  final List<(String label, int value, String valueText)> rows;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxValue = rows.fold<int>(0, (m, r) => r.$2 > m ? r.$2 : m);
    return Column(
      children: [
        for (final (label, value, valueText) in rows)
          Tooltip(
            message: '$label: $valueText',
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(label, overflow: TextOverflow.ellipsis)),
                      Text(valueText, style: theme.textTheme.labelLarge),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: maxValue == 0 ? 0 : value / maxValue,
                      minHeight: 8,
                      color: theme.colorScheme.primary,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _PaymentMethodsCard extends StatelessWidget {
  const _PaymentMethodsCard({required this.summary});
  final SalesSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final labels = {
      SalePaymentMethod.cash: l10n.receiptCash,
      SalePaymentMethod.card: l10n.receiptCard,
      SalePaymentMethod.payLater: l10n.posPayLater,
    };
    final total = summary.byPaymentMethod.values.fold(0, (a, b) => a + b);
    final rows = [
      for (final m in SalePaymentMethod.values)
        if ((summary.byPaymentMethod[m] ?? 0) > 0)
          (
            labels[m]!,
            summary.byPaymentMethod[m]!,
            '${Money.format(summary.byPaymentMethod[m]!)} · ${(summary.byPaymentMethod[m]! * 100 / total).round()}%',
          ),
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.reportsByPaymentMethod, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (rows.isEmpty) Text(l10n.reportsNoSales) else _RankedBars(rows: rows),
          ],
        ),
      ),
    );
  }
}

class _TopProductsCard extends StatelessWidget {
  const _TopProductsCard({required this.summary, required this.productNames});
  final SalesSummary summary;
  final Map<String, String> productNames;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final rows = [
      for (final p in summary.topProducts)
        (
          productNames[p.productId] ?? p.productId,
          p.revenueMinorUnits,
          '${Money.format(p.revenueMinorUnits)} · ×${p.quantity}',
        ),
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.reportsTopProducts, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (rows.isEmpty) Text(l10n.reportsNoSales) else _RankedBars(rows: rows),
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
                if (products.isEmpty) return Text(l10n.reportsNothingLow);
                return Column(
                  children: products
                      .map((p) => ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.warning_amber_rounded, color: Theme.of(context).colorScheme.error),
                            title: Text(p.name),
                            trailing: Text(l10n.reportsReorderAt(p.reorderLevel)),
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
