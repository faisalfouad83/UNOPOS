import 'home_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/permissions.dart';
import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/routing/route_paths.dart';
import '../../../core/utils/formatters.dart';
import '../../auth/domain/session_controller.dart';
import '../../debts/domain/debts_models.dart';
import '../../inventory/domain/inventory_models.dart';
import '../../inventory/domain/product_expiry.dart';
import '../../inventory/presentation/expiry_screen.dart';
import '../../pos/domain/pos_models.dart';
import '../../shifts/domain/shifts_models.dart';
import '../../shifts/presentation/shift_providers.dart';
import '../../../core/offline/connectivity.dart';
import '../../../core/offline/sync_service.dart';
import '../../../core/supabase/supabase_config.dart';
import 'expenses_overview_card.dart';

typedef _BranchKey = ({String storeId, String branchId});

final _todaysSalesForDashboardProvider = StreamProvider.autoDispose.family<List<SaleRecord>, String>((ref, storeId) {
  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);
  return ref.watch(posRepositoryProvider).watchCompletedSales(storeId, from: startOfDay);
});

final _dashboardOpenDebtsProvider = StreamProvider.autoDispose.family<List<DebtLedgerEntryRecord>, String>((
  ref,
  storeId,
) {
  return ref.watch(debtsRepositoryProvider).watchOpenDebts(storeId);
});

final _dashboardProductsProvider = StreamProvider.autoDispose.family<List<ProductRecord>, String>((ref, storeId) {
  return ref.watch(inventoryRepositoryProvider).watchProducts(storeId);
});

final _dashboardLowStockProvider = StreamProvider.autoDispose.family<List<ProductRecord>, _BranchKey>((ref, key) {
  return ref.watch(inventoryRepositoryProvider).watchLowStock(key.storeId, key.branchId);
});

/// The home screen, built around what a cashier and a manager do first:
/// a large "new sale" button, whether the till is offline or has changes
/// waiting, today's figures, the open shift, and one-tap shortcuts to every
/// section this employee may open.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final session = ref.watch(sessionControllerProvider);
    final storeId = session.store?.id;
    final branchId = session.currentBranchId;
    final employee = session.employee;
    final canSell = employee?.can(AppPermission.sell) ?? false;

    final salesAsync = storeId == null
        ? const AsyncValue<List<SaleRecord>>.data([])
        : ref.watch(_todaysSalesForDashboardProvider(storeId));
    final debtsAsync = storeId == null ? null : ref.watch(_dashboardOpenDebtsProvider(storeId));
    final lowStockAsync = (storeId == null || branchId == null)
        ? null
        : ref.watch(_dashboardLowStockProvider((storeId: storeId, branchId: branchId)));

    // Today's sales in the branch being worked in (not all branches mixed).
    final todaysSales = (salesAsync.value ?? const <SaleRecord>[])
        .where((s) => s.status != SaleStatus.refunded && (branchId == null || s.branchId == branchId))
        .toList();
    final todaysTotal = todaysSales.fold<int>(0, (s, sale) => s + sale.netTotalMinorUnits);
    final debtsTotal = (debtsAsync?.value ?? const <DebtLedgerEntryRecord>[]).fold<int>(
      0,
      (s, d) => s + d.balanceRemainingMinorUnits,
    );
    final lowStockCount = lowStockAsync?.value?.length ?? 0;
    final products =
        storeId == null ? const <ProductRecord>[] : ref.watch(_dashboardProductsProvider(storeId)).value ?? const [];
    final nearExpiry = productsNearExpiry(products);
    final expiredCount = nearExpiry.where((p) => expiryStatusOf(p) == ExpiryStatus.expired).length;
    final shift = (storeId == null || employee == null || !canSell)
        ? null
        : ref.watch(openShiftProvider((storeId: storeId, cashierId: employee.id))).valueOrNull;

    final stats = [
      _StatCard(
        icon: Icons.point_of_sale_outlined,
        label: l10n.homeTodaySales,
        value: Money.format(todaysTotal),
        subtitle: l10n.dashboardSalesToday(todaysSales.length),
        accent: scheme.primary,
        onAccent: scheme.onPrimary,
        onTap: () => context.go(RoutePaths.invoices),
      ),
      _StatCard(
        icon: Icons.receipt_long_outlined,
        label: l10n.debtsTitle,
        value: Money.format(debtsTotal),
        subtitle: l10n.debtsBalanceOwed,
        accent: scheme.tertiary,
        onAccent: scheme.onTertiary,
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
      _StatCard(
        icon: Icons.event_busy_outlined,
        label: l10n.expiryTitle,
        value: '${nearExpiry.length}',
        subtitle: expiredCount > 0 ? l10n.expiryExpiredCount(expiredCount) : l10n.expiryWithinDays(30),
        accent: scheme.secondary,
        onAccent: scheme.onSecondary,
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ExpiryScreen())),
      ),
    ];
    final sections = homeSectionsFor(session);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navDashboard)),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final pad = width < 600 ? 12.0 : 20.0;
          final statColumns = width >= 1000 ? 4 : 2;
          final statWidth = (width - pad * 2 - 12 * (statColumns - 1)) / statColumns;
          return ListView(
            padding: EdgeInsets.fromLTRB(pad, pad, pad, pad + 16),
            children: [
              _HomeHeader(
                storeName: session.store?.displayName ?? '',
                who: '${employee?.name ?? ''} · ${roleLabel(l10n, session.role)}',
                onNewSale: canSell ? () => context.go(RoutePaths.pos) : null,
                compact: width < 600,
              ),
              if (kUseSupabaseBackend) const _SyncBanner(),
              const SizedBox(height: 16),
              Text(l10n.homeToday, style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [for (final c in stats) SizedBox(width: statWidth, child: c)],
              ),
              if (shift != null) ...[
                const SizedBox(height: 12),
                _ShiftCard(shift: shift),
              ],
              if (sections.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(l10n.homeShortcuts, style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                GridView.extent(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  maxCrossAxisExtent: width < 600 ? 120 : 160,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.15,
                  children: [
                    for (final s in sections)
                      _ShortcutTile(icon: s.icon, label: s.label(l10n), onTap: () => context.go(s.path)),
                  ],
                ),
              ],
              if (storeId != null && (employee?.can(AppPermission.expenses) ?? false)) ...[
                const SizedBox(height: 20),
                ExpensesOverviewCard(storeId: storeId),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.storeName, required this.who, required this.onNewSale, required this.compact});
  final String storeName;
  final String who;
  final VoidCallback? onNewSale;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(storeName, style: compact ? theme.textTheme.titleLarge : theme.textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(
          '$who · ${AppDateFormat.shortDate(DateTime.now())}',
          style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurface.withValues(alpha: 0.65)),
        ),
      ],
    );
    final button = onNewSale == null
        ? null
        : FilledButton.icon(
            onPressed: onNewSale,
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 56),
              padding: const EdgeInsets.symmetric(horizontal: 28),
              textStyle: theme.textTheme.titleMedium,
            ),
            icon: const Icon(Icons.point_of_sale, size: 26),
            label: Text(l10n.homeNewSale),
          );
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: compact
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  title,
                  if (button != null) ...[const SizedBox(height: 12), button]
                ],
              )
            : Row(children: [Expanded(child: title), if (button != null) button]),
      ),
    );
  }
}

/// Shown only when it matters: offline, changes waiting, or refused.
class _SyncBanner extends ConsumerWidget {
  const _SyncBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final online = ref.watch(connectivityProvider);
    final sync = ref.watch(syncServiceProvider);
    if (online && sync.pending == 0 && sync.failed == 0) return const SizedBox.shrink();
    final (icon, text, color) = sync.failed > 0
        ? (Icons.sync_problem, l10n.syncFailedCount(sync.failed), scheme.error)
        : !online
            ? (
                Icons.cloud_off,
                sync.pending > 0 ? l10n.offlineWithPending(sync.pending) : l10n.homeOfflineWorking,
                scheme.error
              )
            : (Icons.cloud_upload_outlined, l10n.offlinePendingSales(sync.pending), scheme.primary);
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Material(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          leading: Icon(icon, color: color),
          title: Text(text),
          trailing: online ? const Icon(Icons.sync) : null,
          onTap: online ? () => ref.read(syncServiceProvider.notifier).syncNow() : null,
        ),
      ),
    );
  }
}

class _ShiftCard extends ConsumerWidget {
  const _ShiftCard({required this.shift});
  final ShiftRecord shift;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final expected = ref.watch(shiftCashSummaryProvider(shift)).valueOrNull?.expectedMinorUnits;
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: const Icon(Icons.savings_outlined),
        title: Text(l10n.homeShiftOpenSince(AppDateFormat.time(shift.openedAt))),
        subtitle: expected == null ? null : Text('${l10n.expensesCashExpected}: ${Money.format(expected)}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.go(RoutePaths.expensesCash),
      ),
    );
  }
}

class _ShortcutTile extends StatelessWidget {
  const _ShortcutTile({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30, color: theme.colorScheme.primary),
              const SizedBox(height: 8),
              Text(label, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          ),
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
                  Expanded(child: Text(label, style: Theme.of(context).textTheme.titleMedium)),
                ],
              ),
              const SizedBox(height: 16),
              Text(value, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
