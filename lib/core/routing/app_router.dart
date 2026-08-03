import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'app_bootstrap.dart';
import 'route_guard.dart';
import 'route_paths.dart';
import '../../features/auth/domain/auth_models.dart';
import '../../features/auth/domain/session_controller.dart';
import '../../features/auth/presentation/pin_pad_screen.dart';
import '../../features/auth/presentation/store_login_screen.dart';
import '../../features/auth/presentation/tile_picker_screen.dart';
import '../../features/home/presentation/dashboard_screen.dart';
import '../../features/home/presentation/home_shell.dart';
import '../../features/licensing/presentation/activation_screen.dart';
import '../../features/licensing/presentation/developer_home_screen.dart';
import '../../features/onboarding/presentation/create_manager_screen.dart';
import '../../features/onboarding/presentation/create_store_screen.dart';
import '../../features/pos/presentation/pos_screen.dart';
import '../../features/inventory/presentation/inventory_screen.dart';
import '../../features/debts/presentation/debts_screen.dart';
import '../../features/suppliers/presentation/suppliers_screen.dart';
import '../../features/accounting/presentation/accounting_screen.dart';
import '../../features/shifts/presentation/expenses_cash_screen.dart';
import '../../features/hr/presentation/hr_screen.dart';
import '../../features/reports/presentation/reports_dashboard_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';

class _GoRouterRefreshNotifier extends ChangeNotifier {
  _GoRouterRefreshNotifier(Ref ref) {
    ref.listen(sessionControllerProvider, (_, __) => notifyListeners());
    ref.listen(licenseValidProvider, (_, __) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _GoRouterRefreshNotifier(ref);

  return GoRouter(
    initialLocation: RoutePaths.activation,
    refreshListenable: refresh,
    redirect: (context, state) {
      final bootstrap = ref.read(appBootstrapProvider);
      if (!bootstrap.hasValue) return null; // wait for bootstrap to resolve
      final session = ref.read(sessionControllerProvider);
      final hasValidLicense = ref.read(licenseValidProvider);
      return RouteGuard.redirect(
        location: state.matchedLocation,
        hasValidLicense: hasValidLicense,
        hasStoreOnDisk: session.hasStore,
        hasEmployees: bootstrap.value?.hasEmployees ?? false,
        session: session,
      );
    },
    routes: [
      GoRoute(path: RoutePaths.activation, builder: (context, state) => const ActivationScreen()),
      GoRoute(path: RoutePaths.onboardingStore, builder: (context, state) => const CreateStoreScreen()),
      GoRoute(
        path: RoutePaths.onboardingManager,
        // extra is only passed when navigated to directly from
        // CreateStoreScreen; when RouteGuard redirects here instead (store
        // exists but onboarding never finished), extra is null and
        // CreateManagerScreen falls back to the store already loaded into
        // the session by AppBootstrap.
        builder: (context, state) => CreateManagerScreen(store: state.extra as StoreRecord?),
      ),
      GoRoute(path: RoutePaths.storeLogin, builder: (context, state) => const StoreLoginScreen()),
      GoRoute(path: RoutePaths.tilePicker, builder: (context, state) => const TilePickerScreen()),
      GoRoute(path: RoutePaths.pinPad, builder: (context, state) => const PinPadScreen()),
      GoRoute(path: RoutePaths.developerHome, builder: (context, state) => const DeveloperHomeScreen()),
      ShellRoute(
        builder: (context, state, child) => HomeShell(currentPath: state.matchedLocation, child: child),
        routes: [
          GoRoute(path: RoutePaths.home, builder: (context, state) => const DashboardScreen()),
          GoRoute(path: RoutePaths.pos, builder: (context, state) => const PosScreen()),
          GoRoute(path: RoutePaths.inventory, builder: (context, state) => const InventoryScreen()),
          GoRoute(path: RoutePaths.debts, builder: (context, state) => const DebtsScreen()),
          GoRoute(path: RoutePaths.suppliers, builder: (context, state) => const SuppliersScreen()),
          GoRoute(path: RoutePaths.accounting, builder: (context, state) => const AccountingScreen()),
          GoRoute(path: RoutePaths.expensesCash, builder: (context, state) => const ExpensesCashScreen()),
          GoRoute(path: RoutePaths.hr, builder: (context, state) => const HrScreen()),
          GoRoute(path: RoutePaths.reports, builder: (context, state) => const ReportsDashboardScreen()),
          GoRoute(path: RoutePaths.settings, builder: (context, state) => const SettingsScreen()),
        ],
      ),
    ],
  );
});
