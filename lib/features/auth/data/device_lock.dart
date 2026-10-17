import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/offline/offline_cache.dart';
import '../../../core/supabase/supabase_client_provider.dart';
import '../../../core/supabase/supabase_config.dart';
import '../../../core/utils/id_generator.dart';

/// This installation's own id (made once, kept on the device) and a name
/// people recognise it by.
class DeviceIdentity {
  const DeviceIdentity._();

  static const _key = 'device_identity.id';

  static Future<String> id() async {
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(_key);
    if (id == null) {
      id = IdGenerator.newId();
      await prefs.setString(_key, id);
    }
    return id;
  }

  static String name() {
    try {
      if (Platform.isAndroid) return 'Android';
      if (Platform.isIOS) return 'iPhone/iPad';
      return Platform.localHostname;
    } catch (_) {
      return 'Device';
    }
  }
}

/// The outcome of claiming an account for this device.
class DeviceClaim {
  const DeviceClaim.ok()
      : allowed = true,
        otherDevice = null,
        planDeviceLimit = null;
  const DeviceClaim.refused(this.otherDevice)
      : allowed = false,
        planDeviceLimit = null;

  /// Refused because the store's plan allows no more tills at once.
  const DeviceClaim.planLimit(int this.planDeviceLimit)
      : allowed = false,
        otherDevice = null;

  final bool allowed;

  /// The device that already holds the account.
  final String? otherDevice;

  /// Set when refused for the plan's device limit: that limit.
  final int? planDeviceLimit;
}

/// A cashier account works on one device at a time (checked by the
/// server, which ignores other roles).
class DeviceLock {
  DeviceLock(this._client);
  final SupabaseClient _client;

  /// Claims [employeeId] for this device. With no connection the sign-in
  /// goes ahead — the server can't be asked, and the till must still work.
  Future<DeviceClaim> claim(String employeeId, String pin) async {
    try {
      final result = await _client.rpc(
        'claim_employee_device',
        params: {
          'p_employee_id': employeeId,
          'p_pin': pin,
          'p_device_id': await DeviceIdentity.id(),
          'p_device_name': DeviceIdentity.name(),
        },
      ).timeout(const Duration(seconds: 8));
      final map = (result as Map).cast<String, dynamic>();
      if (map['ok'] == true) return const DeviceClaim.ok();
      if (map['reason'] == 'plan_device_limit') return DeviceClaim.planLimit((map['limit'] as num?)?.toInt() ?? 0);
      return DeviceClaim.refused(map['device_name'] as String?);
    } catch (e) {
      if (isNetworkError(e)) return const DeviceClaim.ok();
      rethrow;
    }
  }

  /// Frees the account when it signs out here. Best effort.
  Future<void> release(String employeeId) async {
    try {
      await _client.rpc(
        'release_employee_device',
        params: {'p_employee_id': employeeId, 'p_device_id': await DeviceIdentity.id()},
      ).timeout(const Duration(seconds: 8));
    } catch (_) {}
  }

  /// The owner or a manager frees an account held by another device.
  Future<void> forceRelease({required String employeeId, required String actorId, required String actorPin}) =>
      _client.rpc(
        'force_release_employee_device',
        params: {'p_employee_id': employeeId, 'p_actor_id': actorId, 'p_actor_pin': actorPin},
      );

  /// Accounts currently held, by employee id → device name.
  Stream<Map<String, String>> watchHeld(String storeId) =>
      _client.from('employee_device_sessions').stream(primaryKey: ['user_id']).eq('store_id', storeId).map((rows) => {
            for (final r in rows)
              if (r['device_id'] != null) r['user_id'] as String: (r['device_name'] as String?) ?? '',
          });
}

final deviceLockProvider = Provider<DeviceLock?>((ref) {
  if (!kUseSupabaseBackend) return null;
  return DeviceLock(ref.watch(supabaseClientProvider));
});

final heldDevicesProvider = StreamProvider.autoDispose.family<Map<String, String>, String>((ref, storeId) {
  final lock = ref.watch(deviceLockProvider);
  if (lock == null) return Stream.value(const {});
  return lock.watchHeld(storeId);
});
