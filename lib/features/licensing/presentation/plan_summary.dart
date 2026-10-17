import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/utils/formatters.dart';
import '../domain/entitlement.dart';
import '../domain/license_watch.dart';

/// The store's plan in Settings: its name, whether it is active, when it
/// ends, how much of each limit is used, the sections it leaves out, and
/// when the server last confirmed it. Nothing on the local build.
class PlanSummary extends ConsumerWidget {
  const PlanSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final e = ref.watch(entitlementProvider);
    if (e == null) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final status = e.status();
    final statusColor = switch (status) {
      'active' || 'trial' => Colors.green.shade700,
      _ => theme.colorScheme.error,
    };
    final excluded = PlanModules.all.where((m) => !e.includes(m)).toList();
    final limits = [
      for (final key in const ['employees', 'branches', 'products', 'devices', 'daily_transactions'])
        if (e.limits.containsKey(key)) (key, e.usage[key] ?? 0, e.limits[key]),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(l10n.planCurrent(e.planName), style: theme.textTheme.titleSmall),
            Chip(
              visualDensity: VisualDensity.compact,
              label: Text(planStatusLabel(l10n, status), style: TextStyle(color: statusColor)),
              side: BorderSide(color: statusColor),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          e.expiresAt == null ? l10n.planNoEndDate : l10n.planEndsOn(AppDateFormat.shortDate(e.expiresAt!)),
          style: theme.textTheme.bodyMedium,
        ),
        if (limits.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final (key, used, limit) in limits)
                Chip(
                  visualDensity: VisualDensity.compact,
                  label: Text(
                    '${planLimitLabel(l10n, key)}: ${limit == null || limit >= 999999 ? '$used / ${l10n.planUnlimited}' : '$used / $limit'}',
                  ),
                ),
            ],
          ),
        ],
        if (excluded.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            l10n.planExcludedSections(excluded.map((m) => planModuleLabel(l10n, m)).join(', ')),
            style: theme.textTheme.bodySmall,
          ),
        ],
        const SizedBox(height: 4),
        Text(
          e.fromCache
              ? l10n.planVerifiedOffline(AppDateFormat.dateTime(e.verifiedAt))
              : l10n.planVerifiedAt(AppDateFormat.dateTime(e.verifiedAt)),
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

String planStatusLabel(AppLocalizations l10n, String status) => switch (status) {
      'trial' => l10n.planStatusTrial,
      'expired' => l10n.planStatusExpired,
      'suspended' => l10n.planStatusSuspended,
      'disabled' => l10n.planStatusDisabled,
      _ => l10n.planStatusActive,
    };

String planLimitLabel(AppLocalizations l10n, String key) => switch (key) {
      'employees' => l10n.planLimitEmployees,
      'branches' => l10n.planLimitBranches,
      'products' => l10n.planLimitProducts,
      'devices' => l10n.planLimitDevices,
      'daily_transactions' => l10n.planLimitDailySales,
      _ => key,
    };

String planModuleLabel(AppLocalizations l10n, String module) => switch (module) {
      PlanModules.pos => l10n.planModulePos,
      PlanModules.invoices => l10n.planModuleInvoices,
      PlanModules.inventory => l10n.planModuleInventory,
      PlanModules.debts => l10n.planModuleDebts,
      PlanModules.customers => l10n.planModuleCustomers,
      PlanModules.suppliers => l10n.planModuleSuppliers,
      PlanModules.accounting => l10n.planModuleAccounting,
      PlanModules.expenses => l10n.planModuleExpenses,
      PlanModules.hr => l10n.planModuleHr,
      PlanModules.reports => l10n.planModuleReports,
      _ => module,
    };
