import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/roles.dart';
import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/theming/app_theme.dart';
import '../../../core/routing/route_paths.dart';
import '../../auth/domain/session_controller.dart';

class _Destination {
  const _Destination(this.path, this.icon, this.labelBuilder);
  final String path;
  final IconData icon;
  final String Function(AppLocalizations) labelBuilder;
}

const _allDestinations = [
  _Destination(RoutePaths.home, Icons.dashboard_outlined, _navDashboard),
  _Destination(RoutePaths.pos, Icons.point_of_sale_outlined, _navSales),
  _Destination(RoutePaths.inventory, Icons.inventory_2_outlined, _navInventory),
  _Destination(RoutePaths.debts, Icons.receipt_long_outlined, _navDebts),
  _Destination(RoutePaths.suppliers, Icons.local_shipping_outlined, _navSuppliers),
  _Destination(RoutePaths.accounting, Icons.account_balance_outlined, _navAccounting),
  _Destination(RoutePaths.hr, Icons.badge_outlined, _navHr),
  _Destination(RoutePaths.reports, Icons.bar_chart_outlined, _navReports),
  _Destination(RoutePaths.settings, Icons.settings_outlined, _navSettings),
];

String _navDashboard(AppLocalizations l) => l.navDashboard;
String _navSales(AppLocalizations l) => l.navSales;
String _navInventory(AppLocalizations l) => l.navInventory;
String _navDebts(AppLocalizations l) => l.navDebts;
String _navSuppliers(AppLocalizations l) => l.navSuppliers;
String _navAccounting(AppLocalizations l) => l.navAccounting;
String _navHr(AppLocalizations l) => l.navHr;
String _navReports(AppLocalizations l) => l.navReports;
String _navSettings(AppLocalizations l) => l.navSettings;

List<_Destination> _destinationsForRole(SessionRole? role) {
  switch (role) {
    case SessionRole.cashier:
      return _allDestinations.where((d) => [RoutePaths.pos, RoutePaths.debts].contains(d.path)).toList();
    case SessionRole.warehouseManager:
      return _allDestinations.where((d) => [RoutePaths.inventory].contains(d.path)).toList();
    case SessionRole.owner:
    case SessionRole.manager:
      return _allDestinations;
    case SessionRole.developer:
    case null:
      return const [];
  }
}

class HomeShell extends ConsumerWidget {
  const HomeShell({super.key, required this.child, required this.currentPath});

  final Widget child;
  final String currentPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(sessionControllerProvider);
    final destinations = _destinationsForRole(session.role);
    final selectedIndex = destinations.indexWhere((d) => currentPath.startsWith(d.path)).clamp(0, destinations.length - 1);

    final width = MediaQuery.sizeOf(context).width;
    final isCompact = AppBreakpoints.isCompact(width);

    void onSelect(int index) {
      if (index < 0 || index >= destinations.length) return;
      context.go(destinations[index].path);
    }

    final content = Scaffold(
      appBar: AppBar(
        title: Text(destinations.isEmpty ? '' : destinations[selectedIndex.clamp(0, destinations.length - 1)].labelBuilder(l10n)),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'signOut') {
                ref.read(sessionControllerProvider.notifier).signOutToTilePicker();
                context.go(RoutePaths.tilePicker);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                enabled: false,
                child: Text('${session.employee?.name ?? ''} · ${session.role?.name ?? ''}'),
              ),
              PopupMenuItem(value: 'signOut', child: Text(l10n.actionSignOut)),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: CircleAvatar(
                radius: 16,
                child: Text(
                  (session.employee?.name.isNotEmpty ?? false) ? session.employee!.name[0].toUpperCase() : '?',
                ),
              ),
            ),
          ),
        ],
      ),
      body: isCompact
          ? child
          : Row(
              children: [
                NavigationRail(
                  selectedIndex: destinations.isEmpty ? 0 : selectedIndex,
                  onDestinationSelected: onSelect,
                  labelType: NavigationRailLabelType.all,
                  destinations: destinations
                      .map((d) => NavigationRailDestination(icon: Icon(d.icon), label: Text(d.labelBuilder(l10n))))
                      .toList(),
                ),
                const VerticalDivider(width: 1),
                Expanded(child: child),
              ],
            ),
      bottomNavigationBar: isCompact && destinations.isNotEmpty
          ? NavigationBar(
              selectedIndex: selectedIndex,
              onDestinationSelected: onSelect,
              destinations: destinations
                  .map((d) => NavigationDestination(icon: Icon(d.icon), label: d.labelBuilder(l10n)))
                  .toList(),
            )
          : null,
    );

    return content;
  }
}
