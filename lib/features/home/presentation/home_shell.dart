import 'refresh_data_button.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/app.dart';
import '../../../core/window/full_screen_button.dart';
import '../../../core/constants/roles.dart';
import '../../../core/providers.dart';
import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/theming/app_theme.dart';
import '../../../core/routing/route_guard.dart';
import '../../../core/routing/route_paths.dart';
import '../../../core/widgets/app_credits.dart';
import '../../breaks/presentation/break_button.dart';
import '../../support/presentation/contact_us_screen.dart';
import '../../../core/widgets/unopos_logo.dart';
import '../../auth/domain/auth_models.dart';
import '../../pos/presentation/cart_controller.dart';
import '../../pos/presentation/pos_screen.dart';
import '../../pos/presentation/offline_sync_indicator.dart';
import '../../auth/domain/session_controller.dart';
import '../../notifications/presentation/notification_bell.dart';

class _Destination {
  const _Destination(this.path, this.icon, this.labelBuilder);
  final String path;
  final IconData icon;
  final String Function(AppLocalizations) labelBuilder;
}

const _allDestinations = [
  _Destination(RoutePaths.home, Icons.dashboard_outlined, _navDashboard),
  _Destination(RoutePaths.pos, Icons.point_of_sale_outlined, _navSales),
  _Destination(RoutePaths.invoices, Icons.receipt_outlined, _navInvoices),
  _Destination(RoutePaths.inventory, Icons.inventory_2_outlined, _navInventory),
  _Destination(RoutePaths.debts, Icons.receipt_long_outlined, _navDebts),
  _Destination(RoutePaths.customers, Icons.people_alt_outlined, _navCustomers),
  _Destination(RoutePaths.suppliers, Icons.local_shipping_outlined, _navSuppliers),
  _Destination(RoutePaths.accounting, Icons.account_balance_outlined, _navAccounting),
  _Destination(RoutePaths.expensesCash, Icons.savings_outlined, _navExpensesCash),
  _Destination(RoutePaths.hr, Icons.badge_outlined, _navHr),
  _Destination(RoutePaths.reports, Icons.bar_chart_outlined, _navReports),
  _Destination(RoutePaths.settings, Icons.settings_outlined, _navSettings),
];

String _navDashboard(AppLocalizations l) => l.navDashboard;
String _navSales(AppLocalizations l) => l.navSales;
String _navInvoices(AppLocalizations l) => l.navInvoices;
String _navInventory(AppLocalizations l) => l.navInventory;
String _navDebts(AppLocalizations l) => l.navDebts;
String _navCustomers(AppLocalizations l) => l.navCustomers;
String _navSuppliers(AppLocalizations l) => l.navSuppliers;
String _navAccounting(AppLocalizations l) => l.navAccounting;
String _navExpensesCash(AppLocalizations l) => l.navExpensesCash;
String _navHr(AppLocalizations l) => l.navHr;
String _navReports(AppLocalizations l) => l.navReports;
String _navSettings(AppLocalizations l) => l.navSettings;

/// Sections this employee's permissions allow (the dashboard always).
List<_Destination> _destinationsFor(SessionState session) {
  if (session.employee == null) return const [];
  return _allDestinations.where((d) => RouteGuard.isAllowed(d.path, session)).toList();
}

/// Provides navigation chrome (rail/bottom bar) plus a thin persistent
/// account strip. Deliberately NOT a Scaffold itself — each destination
/// screen owns its own Scaffold/AppBar (so it can add screen-specific
/// actions), this just wraps it with navigation on the side or bottom.
class HomeShell extends ConsumerWidget {
  const HomeShell({super.key, required this.child, required this.currentPath});

  final Widget child;
  final String currentPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(sessionControllerProvider);
    final destinations = _destinationsFor(session);
    final selectedIndex = destinations
        .indexWhere((d) => currentPath.startsWith(d.path))
        .clamp(0, destinations.isEmpty ? 0 : destinations.length - 1);

    final width = MediaQuery.sizeOf(context).width;
    final isCompact = AppBreakpoints.isCompact(width);

    void onSelect(int index) {
      if (index < 0 || index >= destinations.length) return;
      context.go(destinations[index].path);
    }

    if (isCompact) {
      return Column(
        children: [
          const _CompactStrip(),
          const Divider(height: 1),
          Expanded(child: child),
          if (destinations.length >= 2) _CompactNavBar(destinations: destinations, currentPath: currentPath),
        ],
      );
    }

    final accountStrip = Material(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: [
              const UnoposLogo(size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  session.store?.displayName ?? '',
                  style: Theme.of(context).textTheme.labelLarge,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const _BranchIndicator(),
              const SizedBox(width: 8),
              const OfflineSyncIndicator(),
              const RefreshDataButton(),
              // A tablet in portrait has room for the time but not the date.
              _LiveClock(showDate: AppBreakpoints.isExpanded(width)),
              const SizedBox(width: 8),
              const BreakButton(),
              const FullScreenButton(),
              const _LanguageMenu(),
              const NotificationBell(),
              const ContactUsButton(),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'signOut') _signOut(context, ref);
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    enabled: false,
                    child: Text('${session.employee?.name ?? ''} · ${roleLabel(l10n, session.role)}'),
                  ),
                  PopupMenuItem(value: 'signOut', child: Text(l10n.actionSignOut)),
                ],
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 14,
                      child: Text(
                        (session.employee?.name.isNotEmpty ?? false) ? session.employee!.name[0].toUpperCase() : '?',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (AppBreakpoints.isExpanded(width))
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(session.employee?.name ?? '', style: Theme.of(context).textTheme.labelMedium),
                          Text(
                            roleLabel(l10n, session.role),
                            style: Theme.of(
                              context,
                            ).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.primary),
                          ),
                        ],
                      ),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return Column(
      children: [
        accountStrip,
        const Divider(height: 1),
        Expanded(
          // A rail needs at least two items; right after signing out there
          // are none (no employee), so draw just the page for that moment.
          child: destinations.length < 2
              ? child
              : Row(
                  children: [
                    // Scrolls when the window is too short for every section.
                    LayoutBuilder(
                      builder: (context, constraints) => SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minHeight: constraints.maxHeight),
                          child: IntrinsicHeight(
                            child: NavigationRail(
                              selectedIndex: destinations.isEmpty ? 0 : selectedIndex,
                              onDestinationSelected: onSelect,
                              labelType: NavigationRailLabelType.all,
                              destinations: destinations
                                  .map(
                                    (d) => NavigationRailDestination(
                                        icon: Icon(d.icon), label: Text(d.labelBuilder(l10n))),
                                  )
                                  .toList(),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(child: child),
                  ],
                ),
        ),
        const Padding(
          padding: EdgeInsetsDirectional.fromSTEB(12, 2, 12, 2),
          child: AppCredits(alignment: AlignmentDirectional.centerEnd),
        ),
      ],
    );
  }
}

void _signOut(BuildContext context, WidgetRef ref) {
  ref.read(sessionControllerProvider.notifier).signOutToTilePicker();
  context.go(RoutePaths.tilePicker);
}

/// The phone's top bar: store and branch, the sync state, a break, the
/// notifications, and everything else in one menu.
class _CompactStrip extends ConsumerWidget {
  const _CompactStrip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(sessionControllerProvider);
    final storeId = session.store?.id;
    final unread = storeId == null ? 0 : ref.watch(storeSupportUnreadProvider(storeId)).valueOrNull ?? 0;
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerLow,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(12, 4, 4, 4),
          child: Row(
            children: [
              const UnoposLogo(size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      session.store?.displayName ?? '',
                      style: theme.textTheme.labelLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const _BranchIndicator(dense: true),
                  ],
                ),
              ),
              const OfflineSyncIndicator(compact: true),
              const RefreshDataButton(),
              const BreakButton(),
              const NotificationBell(),
              PopupMenuButton<String>(
                tooltip: '',
                icon: Badge(isLabelVisible: unread > 0, label: Text('$unread'), child: const Icon(Icons.more_vert)),
                onSelected: (value) async {
                  switch (value) {
                    case 'language':
                      final code = await showDialog<String>(
                        context: context,
                        builder: (context) => SimpleDialog(
                          title: Text(l10n.settingsLanguage),
                          children: [
                            for (final (code, name) in _LanguageMenu._languages)
                              SimpleDialogOption(
                                onPressed: () => Navigator.of(context).pop(code),
                                child: Text(name),
                              ),
                          ],
                        ),
                      );
                      if (code != null) await _setLanguage(ref, code);
                    case 'contact':
                      if (context.mounted) openContactUs(context, ref);
                    case 'signOut':
                      if (context.mounted) _signOut(context, ref);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    enabled: false,
                    child: Text('${session.employee?.name ?? ''} · ${roleLabel(l10n, session.role)}'),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'language',
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.translate),
                      title: Text(l10n.settingsLanguage),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'contact',
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Badge(
                        isLabelVisible: unread > 0,
                        label: Text('$unread'),
                        child: const Icon(Icons.support_agent),
                      ),
                      title: Text(l10n.contactUs),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'signOut',
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.logout),
                      title: Text(l10n.actionSignOut),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The phone's bottom bar: the first sections, and "More" for the rest
/// (a bar holds four or five comfortably, not twelve).
class _CompactNavBar extends StatelessWidget {
  const _CompactNavBar({required this.destinations, required this.currentPath});

  final List<_Destination> destinations;
  final String currentPath;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final fitsAll = destinations.length <= 5;
    final primary = fitsAll ? destinations : destinations.take(4).toList();
    final more = fitsAll ? const <_Destination>[] : destinations.skip(4).toList();
    var selected = primary.indexWhere((d) => currentPath.startsWith(d.path));
    if (selected < 0) selected = more.any((d) => currentPath.startsWith(d.path)) ? primary.length : 0;

    return NavigationBar(
      height: 64,
      selectedIndex: selected,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      onDestinationSelected: (i) {
        if (i < primary.length) {
          context.go(primary[i].path);
        } else {
          _showMore(context, more);
        }
      },
      destinations: [
        for (final d in primary) NavigationDestination(icon: Icon(d.icon), label: d.labelBuilder(l10n)),
        if (more.isNotEmpty) NavigationDestination(icon: const Icon(Icons.apps), label: l10n.navMore),
      ],
    );
  }

  void _showMore(BuildContext context, List<_Destination> more) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1.2,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  for (final d in more)
                    Material(
                      color: currentPath.startsWith(d.path)
                          ? Theme.of(context).colorScheme.secondaryContainer
                          : Theme.of(context).colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.of(sheetContext).pop();
                          context.go(d.path);
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(d.icon, size: 28),
                            const SizedBox(height: 6),
                            Text(
                              d.labelBuilder(l10n),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              const AppCredits(alignment: AlignmentDirectional.center),
            ],
          ),
        ),
      ),
    );
  }
}

/// The branch being worked in, always visible in the top bar. Accounts not
/// tied to one branch can switch here when the store has several; a cart in
/// progress is suspended first so it isn't lost.
class _BranchIndicator extends ConsumerWidget {
  const _BranchIndicator({this.dense = false});

  /// The phone's smaller form, under the store name.
  final bool dense;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(sessionControllerProvider);
    final store = session.store;
    if (store == null) return const SizedBox.shrink();
    final branches = ref.watch(storeBranchesProvider(store.id)).value ?? const <BranchRecord>[];
    final current = branches.where((b) => b.id == session.currentBranchId).firstOrNull;
    final active = branches.where((b) => b.isActive).toList();
    final canSwitch = session.employee?.branchId == null && active.length > 1;
    final theme = Theme.of(context);

    final label = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.storefront_outlined, size: dense ? 14 : 18, color: theme.colorScheme.primary),
        const SizedBox(width: 4),
        Flexible(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: dense ? 220 : 160),
            child: Text(
              current?.name ?? '—',
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: dense
                  ? theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)
                  : theme.textTheme.labelLarge,
            ),
          ),
        ),
        if (canSwitch) Icon(Icons.arrow_drop_down, size: dense ? 14 : 18),
      ],
    );
    if (!canSwitch) return Tooltip(message: l10n.branchCurrent, child: label);

    return PopupMenuButton<String>(
      tooltip: l10n.pickBranchChange,
      onSelected: (branchId) async {
        if (branchId == session.currentBranchId) return;
        // The cart belongs to the branch it was rung up in.
        if (!ref.read(cartControllerProvider).isEmpty && !await holdCurrentCart(context, ref)) return;
        ref.read(sessionControllerProvider.notifier).setCurrentBranch(branchId);
      },
      itemBuilder: (context) => [
        for (final b in active)
          CheckedPopupMenuItem(value: b.id, checked: b.id == session.currentBranchId, child: Text(b.name)),
      ],
      child: label,
    );
  }
}

/// Live clock in the account strip. Deliberately not locale-formatted (no
/// `locale:` passed to DateFormat) — matching every other date/money
/// formatter in the app, none of which pass one either, since the `intl`
/// package's own locale data doesn't cover 'ckb' any more than Flutter's
/// bundled Material locales did (see kurdish_locale_fallback.dart) and
/// passing it here would risk the same class of crash for Kurdish users.
class _LiveClock extends StatefulWidget {
  const _LiveClock({this.showDate = true});

  final bool showDate;

  @override
  State<_LiveClock> createState() => _LiveClockState();
}

class _LiveClockState extends State<_LiveClock> {
  late DateTime _now;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(DateFormat('HH:mm:ss').format(_now), style: Theme.of(context).textTheme.labelLarge),
        if (widget.showDate)
          Text(
            DateFormat('EEE, MMM d').format(_now),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurface.withValues(alpha: 0.6)),
          ),
      ],
    );
  }
}

/// The account's role in the store's language (shown beside the account).
String roleLabel(AppLocalizations l10n, SessionRole? role) => switch (role) {
      SessionRole.owner => l10n.hrRoleOwner,
      SessionRole.manager => l10n.hrRoleManager,
      SessionRole.cashier => l10n.hrRoleCashier,
      SessionRole.warehouseManager => l10n.hrRoleWarehouseManager,
      SessionRole.developer => l10n.roleDeveloper,
      null => '',
    };

/// Switch the app language from the top bar; saved as the store's language.
class _LanguageMenu extends ConsumerWidget {
  const _LanguageMenu();

  static const _languages = [('ar', 'العربية'), ('en', 'English'), ('ckb', 'کوردی')];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final current = ref.watch(appLocaleProvider).languageCode;
    return PopupMenuButton<String>(
      tooltip: l10n.settingsLanguage,
      icon: const Icon(Icons.translate),
      onSelected: (code) => _setLanguage(ref, code),
      itemBuilder: (context) => [
        for (final (code, name) in _languages)
          CheckedPopupMenuItem(value: code, checked: code == current, child: Text(name)),
      ],
    );
  }
}

/// Switches the app language, saved as the store's language.
Future<void> _setLanguage(WidgetRef ref, String code) async {
  ref.read(appLocaleProvider.notifier).state = Locale(code);
  final storeId = ref.read(sessionControllerProvider).store?.id;
  if (storeId == null) return;
  final repo = ref.read(settingsRepositoryProvider);
  final settings = await repo.ensureSettings(storeId);
  await repo.updateSettings(settings.copyWith(defaultLanguage: code));
}
