import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../supabase/supabase_client_provider.dart';
import '../supabase/supabase_config.dart';
import 'offline_cache.dart';

/// Whether the app can reach the server right now. Checked every
/// [interval] with a tiny request (and at once when asked); when the
/// connection comes back, [onBackOnline] runs (e.g. sending the sales
/// queued while offline).
class ConnectivityMonitor extends StateNotifier<bool> {
  ConnectivityMonitor(this._client, {Duration interval = const Duration(seconds: 15)}) : super(true) {
    check();
    _timer = Timer.periodic(interval, (_) => check());
  }

  final SupabaseClient? _client;
  Timer? _timer;
  final _backOnline = <void Function()>[];

  void onBackOnline(void Function() callback) => _backOnline.add(callback);

  Future<void> check() async {
    final client = _client;
    if (client == null) return;
    bool online;
    try {
      await client.from('subscription_plans').select('id').limit(1).timeout(const Duration(seconds: 6));
      online = true;
    } catch (e) {
      // Only a failure to reach the server means offline; a refusal (e.g.
      // signed out) still means the server answered.
      online = !isNetworkError(e);
    }
    if (!mounted) return;
    final wasOffline = !state;
    state = online;
    if (online && wasOffline) {
      for (final callback in _backOnline) {
        callback();
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// true = online. Always true on the local (single-device) build.
final connectivityProvider = StateNotifierProvider<ConnectivityMonitor, bool>((ref) {
  return ConnectivityMonitor(kUseSupabaseBackend ? ref.watch(supabaseClientProvider) : null);
});
