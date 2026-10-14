import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../supabase/supabase_client_provider.dart';
import '../supabase/supabase_config.dart';
import 'offline_cache.dart';

/// Whether the app can reach the server right now. Checked with a tiny
/// request every [onlineInterval] while online and every [offlineInterval]
/// while offline (so the till notices the connection is back within
/// seconds), at once when asked, and updated by every real request
/// ([markOnline] / [markOffline]). When the connection comes back,
/// listeners of this notifier see it flip to true and send what is waiting.
class ConnectivityMonitor extends StateNotifier<bool> {
  ConnectivityMonitor(
    this._client, {
    this.onlineInterval = const Duration(seconds: 15),
    this.offlineInterval = const Duration(seconds: 4),
  }) : super(true) {
    check();
    _schedule();
  }

  final SupabaseClient? _client;
  final Duration onlineInterval;
  final Duration offlineInterval;
  Timer? _timer;
  bool _checking = false;

  void _schedule() {
    _timer?.cancel();
    if (_client == null || !mounted) return;
    _timer = Timer(state ? onlineInterval : offlineInterval, () async {
      await check();
      _schedule();
    });
  }

  bool get isOnline => state;

  /// A request just got through.
  void markOnline() {
    OfflineCache.knownOffline = false;
    if (!mounted || state) return;
    state = true;
    _schedule();
  }

  /// A request just failed for lack of a connection.
  void markOffline() {
    OfflineCache.knownOffline = true;
    if (!mounted || !state) return;
    state = false;
    _schedule();
  }

  Future<void> check() async {
    final client = _client;
    if (client == null || _checking) return;
    _checking = true;
    bool online;
    try {
      await client.from('subscription_plans').select('id').limit(1).timeout(const Duration(seconds: 6));
      online = true;
    } catch (e) {
      // Only a failure to reach the server means offline; a refusal (e.g.
      // signed out) still means the server answered.
      online = !isNetworkError(e);
    } finally {
      _checking = false;
    }
    if (!mounted) return;
    online ? markOnline() : markOffline();
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
