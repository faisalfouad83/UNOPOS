import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/domain/session_controller.dart';
import '../store_settings_provider.dart';
import 'app_theme.dart';
import 'theme_assignment_repository.dart';
import 'theme_resolution.dart';

/// What this device remembers about themes, so a launch without a
/// connection shows the same theme as last time:
/// - the theme last in effect (also used before a store is loaded), and
/// - per store, the developer's assignments as last synced, and when.
class ThemeLocalStore {
  const ThemeLocalStore._();

  static const _effectiveKey = 'theme.v1.effective';
  static String _syncKey(String storeId) => 'theme.v1.sync.$storeId';

  /// The theme last in effect, read by [preload] before the app starts.
  static String? lastEffective;

  /// Reads [lastEffective]. Call once at start-up; never throws.
  static Future<void> preload() async {
    try {
      lastEffective = (await SharedPreferences.getInstance()).getString(_effectiveKey);
    } catch (_) {
      lastEffective = null;
    }
  }

  static Future<void> saveEffective(ResolvedTheme resolved) async {
    lastEffective = resolved.storageValue;
    try {
      await (await SharedPreferences.getInstance()).setString(_effectiveKey, resolved.storageValue);
    } catch (_) {
      // Not remembered this time; the next sync tries again.
    }
  }

  static Future<void> saveSync(String storeId, ThemeSyncSnapshot snapshot) async {
    try {
      await (await SharedPreferences.getInstance()).setString(_syncKey(storeId), jsonEncode(snapshot.toJson()));
    } catch (_) {}
  }

  static Future<ThemeSyncSnapshot?> loadSync(String storeId) async {
    try {
      final raw = (await SharedPreferences.getInstance()).getString(_syncKey(storeId));
      if (raw == null) return null;
      return ThemeSyncSnapshot.fromJson((jsonDecode(raw) as Map).cast<String, dynamic>());
    } catch (_) {
      return null;
    }
  }
}

/// The developer's assignments for one store as last fetched from the
/// server.
class ThemeSyncSnapshot {
  const ThemeSyncSnapshot({this.storeAssignment, this.globalAssignment, required this.syncedAt});

  final ThemeAssignment? storeAssignment;
  final ThemeAssignment? globalAssignment;
  final DateTime syncedAt;

  /// Picks this store's and the global row out of [rows].
  factory ThemeSyncSnapshot.fromAssignments(String storeId, List<ThemeAssignment> rows, DateTime syncedAt) =>
      ThemeSyncSnapshot(
        storeAssignment: rows.where((a) => a.scope == storeId).firstOrNull,
        globalAssignment: rows.where((a) => a.isGlobal).firstOrNull,
        syncedAt: syncedAt,
      );

  Map<String, dynamic> toJson() => {
        'store': storeAssignment?.toJson(),
        'global': globalAssignment?.toJson(),
        'synced_at': syncedAt.toIso8601String(),
      };

  factory ThemeSyncSnapshot.fromJson(Map<String, dynamic> json) {
    ThemeAssignment? read(Object? v) => v is Map ? ThemeAssignment.fromRow(v.cast<String, dynamic>()) : null;
    return ThemeSyncSnapshot(
      storeAssignment: read(json['store']),
      globalAssignment: read(json['global']),
      syncedAt: DateTime.tryParse('${json['synced_at']}') ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

/// The theme in effect on this device and everything it was worked out from.
class ThemeState {
  const ThemeState({
    required this.resolved,
    this.storeId,
    this.storeChoice,
    this.storeAssignment,
    this.globalAssignment,
    this.lastSyncedAt,
  });

  final ResolvedTheme resolved;
  final String? storeId;

  /// The store's own choice (see AppSettingsRecord.themeChoice).
  final String? storeChoice;
  final ThemeAssignment? storeAssignment;
  final ThemeAssignment? globalAssignment;

  /// When the developer's assignments were last fetched from the server
  /// (null: never on this device).
  final DateTime? lastSyncedAt;

  ThemeAssignment? get developerAssignment => effectiveDeveloperAssignment(storeAssignment, globalAssignment);

  /// The developer locked the theme: Settings shows the choice as read-only.
  bool get lockedByDeveloper => resolved.source == ThemeSource.developerLocked;

  ThemeData get theme => resolved.key == null ? AppTheme.light() : AppTheme.forKey(resolved.key!);
  ThemeData get darkTheme => resolved.key == null ? AppTheme.dark() : theme;

  /// Following the device: Light or Dark by the system setting. Otherwise
  /// the one chosen theme, whatever the device's setting.
  ThemeMode get themeMode => resolved.key == null ? ThemeMode.system : ThemeMode.light;

  ThemeState copyWith({
    String? storeChoice,
    bool clearStoreChoice = false,
    ThemeAssignment? storeAssignment,
    ThemeAssignment? globalAssignment,
    bool replaceAssignments = false,
    DateTime? lastSyncedAt,
  }) {
    final choice = clearStoreChoice ? null : (storeChoice ?? this.storeChoice);
    final store = replaceAssignments ? storeAssignment : (storeAssignment ?? this.storeAssignment);
    final global = replaceAssignments ? globalAssignment : (globalAssignment ?? this.globalAssignment);
    return ThemeState(
      resolved: resolveStoreTheme(storeAssignment: store, globalAssignment: global, storeChoice: choice),
      storeId: storeId,
      storeChoice: choice,
      storeAssignment: store,
      globalAssignment: global,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }
}

/// Keeps the theme of the store this device is signed into up to date:
/// the store's own choice comes from its settings, the developer's
/// assignments from the server — live over realtime, with a poll every
/// [pollInterval] in case the realtime channel drops — and both are
/// remembered on the device for offline launches. Changes apply at once,
/// without a restart.
class StoreThemeController extends Notifier<ThemeState> {
  static const pollInterval = Duration(minutes: 5);

  StreamSubscription<List<ThemeAssignment>>? _subscription;
  Timer? _poll;

  /// False until the store's settings (its own choice) have been read; until
  /// then the theme last in effect stays on screen.
  bool _choiceKnown = false;

  @override
  ThemeState build() {
    final storeId = ref.watch(sessionControllerProvider.select((s) => s.store?.id));
    ref.onDispose(_stop);

    final initial = ResolvedTheme.fromStorage(ThemeLocalStore.lastEffective);
    if (storeId == null) return ThemeState(resolved: initial);

    final settings = ref.read(currentStoreSettingsProvider).valueOrNull;
    final known = settings != null && settings.storeId == storeId;
    _choiceKnown = known;
    ref.listen(currentStoreSettingsProvider, (_, next) {
      final s = next.valueOrNull;
      if (s == null || s.storeId != storeId) return;
      _choiceKnown = true;
      _update(state.copyWith(storeChoice: s.themeChoice, clearStoreChoice: s.themeChoice == null));
    });

    unawaited(_start(storeId));
    // Until the remembered assignments are read, keep showing what was in
    // effect last time instead of flashing to another theme.
    return ThemeState(resolved: initial, storeId: storeId, storeChoice: known ? settings.themeChoice : null);
  }

  Future<void> _start(String storeId) async {
    final snapshot = await ThemeLocalStore.loadSync(storeId);
    if (state.storeId != storeId) return;
    _update(state.copyWith(
      storeAssignment: snapshot?.storeAssignment,
      globalAssignment: snapshot?.globalAssignment,
      replaceAssignments: true,
      lastSyncedAt: snapshot?.syncedAt,
    ));

    final repo = ref.read(themeAssignmentRepositoryProvider);
    if (repo == null) return;
    _subscription = repo.watchForStore(storeId).listen(
          (rows) => _applySynced(storeId, rows),
          // Offline or the channel dropped: keep the last synced theme; the
          // poll below picks changes up once the server answers again.
          onError: (Object _) {},
        );
    _poll = Timer.periodic(pollInterval, (_) => refresh());
  }

  /// Reads the developer's assignments from the server now (no-op offline
  /// or on the local build).
  Future<void> refresh() async {
    final storeId = state.storeId;
    final repo = ref.read(themeAssignmentRepositoryProvider);
    if (storeId == null || repo == null) return;
    try {
      _applySynced(storeId, await repo.fetchForStore(storeId));
    } catch (_) {
      // Offline: the remembered assignments stay in effect.
    }
  }

  void _applySynced(String storeId, List<ThemeAssignment> rows) {
    if (state.storeId != storeId) return;
    final snapshot = ThemeSyncSnapshot.fromAssignments(storeId, rows, DateTime.now());
    unawaited(ThemeLocalStore.saveSync(storeId, snapshot));
    _update(state.copyWith(
      storeAssignment: snapshot.storeAssignment,
      globalAssignment: snapshot.globalAssignment,
      replaceAssignments: true,
      lastSyncedAt: snapshot.syncedAt,
    ));
  }

  /// Applies the store's new choice at once (Settings also saves it to the
  /// store's settings, which reach the other devices).
  void setStoreChoice(String? choice) {
    _choiceKnown = true;
    _update(state.copyWith(storeChoice: choice, clearStoreChoice: choice == null));
  }

  void _update(ThemeState next) {
    final before = state.resolved;
    if (!_choiceKnown) {
      next = ThemeState(
        resolved: before,
        storeId: next.storeId,
        storeChoice: next.storeChoice,
        storeAssignment: next.storeAssignment,
        globalAssignment: next.globalAssignment,
        lastSyncedAt: next.lastSyncedAt,
      );
    }
    state = next;
    if (next.resolved.storageValue != before.storageValue || ThemeLocalStore.lastEffective == null) {
      unawaited(ThemeLocalStore.saveEffective(next.resolved));
    }
  }

  void _stop() {
    _subscription?.cancel();
    _subscription = null;
    _poll?.cancel();
    _poll = null;
  }
}

final storeThemeControllerProvider = NotifierProvider<StoreThemeController, ThemeState>(StoreThemeController.new);
