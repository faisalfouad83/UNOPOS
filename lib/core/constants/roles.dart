/// Roles available to employees within a single store.
///
/// The Developer identity is intentionally NOT part of this enum — it is not
/// stored as an employee row at all. It is a special session mode entered
/// only by typing the developer passcode on the PIN pad. See
/// `SessionController` in features/auth.
enum StoreRole {
  owner,
  manager,
  cashier,
  warehouseManager;

  bool get isStoreAdmin => this == StoreRole.owner || this == StoreRole.manager;

  static StoreRole fromName(String name) =>
      StoreRole.values.firstWhere((r) => r.name == name);
}

/// A session-level role that additionally includes the hidden Developer
/// identity, which never corresponds to an [StoreRole] employee row.
enum SessionRole {
  owner,
  manager,
  cashier,
  warehouseManager,
  developer;

  bool get isStoreAdmin => this == SessionRole.owner || this == SessionRole.manager;

  static SessionRole fromStoreRole(StoreRole role) => switch (role) {
        StoreRole.owner => SessionRole.owner,
        StoreRole.manager => SessionRole.manager,
        StoreRole.cashier => SessionRole.cashier,
        StoreRole.warehouseManager => SessionRole.warehouseManager,
      };
}
