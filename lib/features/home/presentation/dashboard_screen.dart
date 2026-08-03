import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/routing/route_paths.dart';
import '../../../core/theming/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../auth/domain/session_controller.dart';
import '../../debts/domain/debts_models.dart';
import '../../inventory/domain/inventory_models.dart';
import '../../pos/domain/pos_models.dart';

typedef _BranchKey = ({String storeId, String branchId});

final _todaysSalesForDashboardProvider = StreamProvider.autoDispose.family<List<SaleRecord>, String>((ref, storeId) {
  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);
  return ref.watch(posRepositoryProvider).watchCompletedSales(storeId, from: startOfDay);
});

final _dashboardOpenDebtsProvider =
    StreamProvider.autoDispose.family<List<DebtLedgerEntryRecord>, String>((ref, storeId) {
  return ref.watch(debtsRepositoryProvider).watchOpenDebts(storeId);
});

final _dashboardLowStockProvider = StreamProvider.autoDispose.family<List<ProductRecord>, _BranchKey>((ref, key) {
  return ref.watch(inventoryRepositoryProvider).watchLowStock(key.storeId, key.branchId);
});

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final session = ref.watch(sessionControllerProvider);
    final storeId = session.store?.id;
    final branchId = session.currentBranchId;

    final salesAsync = storeId == null
        ? const AsyncValue<List<SaleRecord>>.data([])
        : ref.watch(_todaysSalesForDashboardProvider(storeId));
    final debtsAsync = storeId == null ? null : ref.watch(_dashboardOpenDebtsProvider(storeId));
    final lowStockAsync =
        (storeId == null || branchId == null) ? null : ref.watch(_dashboardLowStockProvider((storeId: storeId, branchId: branchId)));

    final todaysSales = salesAsync.value ?? const [];
    final todaysTotal = todaysSales.fold<int>(0, (s, sale) => s + sale.grandTotalMinorUnits);
    final debtsTotal =
        (debtsAsync?.value ?? const <DebtLedgerEntryRecord>[]).fold<int>(0, (s, d) => s + d.balanceRemainingMinorUnits);
    final lowStockCount = lowStockAsync?.value?.length ?? 0;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navDashboard)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              session.store?.displayName ?? '',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 4),
            Text(
              '${session.employee?.name ?? ''} · ${session.role?.name ?? ''}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurface.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 720;
                final cards = [
                  _StatCard(
                    icon: Icons.point_of_sale_outlined,
                    label: l10n.navSales,
                    value: Money.format(todaysTotal, currencySymbol: r'$'),
                    subtitle: '${todaysSales.length} sale(s) today',
                    accent: scheme.primary,
                    onAccent: scheme.onPrimary,
                    onTap: () => context.go(RoutePaths.pos),
                  ),
                  _StatCard(
                    icon: Icons.receipt_long_outlined,
                    label: l10n.debtsTitle,
                    value: Money.format(debtsTotal, currencySymbol: r'$'),
                    subtitle: l10n.debtsBalanceOwed,
                    accent: BrandColors.silver,
                    onAccent: BrandColors.paper,
                    onTap: () => context.go(RoutePaths.debts),
                  ),
                  _StatCard(
                    icon: Icons.warning_amber_rounded,
                    label: l10n.inventoryLowStock,
                    value: '$lowStockCount',
                    subtitle: l10n.inventoryProducts,
                    accent: scheme.error,
                    onAccent: scheme.onError,
                    onTap: () => context.go(RoutePaths.inventory),
                  ),
                ];

                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final c in cards) ...[Expanded(child: c), const SizedBox(width: 16)],
                    ]..removeLast(),
                  );
                }
                return Column(
                  children: [for (final c in cards) ...[c, const SizedBox(height: 16)]]..removeLast(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.subtitle,
    required this.accent,
    required this.onAccent,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final String subtitle;
  final Color accent;
  final Color onAccent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(12)),
                    child: Icon(icon, color: onAccent, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(label, style: Theme.of(context).textTheme.titleMedium),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(value, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
