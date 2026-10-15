import 'roles.dart';

/// What an employee is allowed to do. Each employee starts with their
/// role's defaults ([defaultPermissionsFor]) and the owner/manager can switch
/// any of them on or off per employee.
enum AppPermission {
  sell,
  giveDiscount,
  processReturns,
  debts,
  customers,
  inventory,
  editProducts,
  suppliers,
  expenses,
  accounting,
  reports,
  hr,
  settings,
}

Set<AppPermission> defaultPermissionsFor(StoreRole role) => switch (role) {
      StoreRole.owner || StoreRole.manager => AppPermission.values.toSet(),
      StoreRole.cashier => {
          AppPermission.sell,
          AppPermission.giveDiscount,
          AppPermission.processReturns,
          AppPermission.debts,
          AppPermission.customers,
          AppPermission.expenses,
        },
      StoreRole.warehouseManager => {AppPermission.inventory, AppPermission.editProducts},
    };

/// Stored as comma-separated names; null/empty text means "role defaults".
String encodePermissions(Set<AppPermission> permissions) => permissions.map((p) => p.name).join(',');

Set<AppPermission>? decodePermissions(String? text) {
  if (text == null) return null;
  // Saved with every permission taken away: none, not the role's defaults.
  if (text.trim().isEmpty) return <AppPermission>{};
  final names = text.split(',').map((s) => s.trim()).toSet();
  return AppPermission.values.where((p) => names.contains(p.name)).toSet();
}

/// The owner always keeps every permission so a store can never lock
/// itself out.
Set<AppPermission> effectivePermissions(StoreRole role, Set<AppPermission>? custom) =>
    role == StoreRole.owner ? AppPermission.values.toSet() : (custom ?? defaultPermissionsFor(role));
