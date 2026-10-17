import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../supabase/supabase_config.dart';
import 'connectivity.dart';
import 'offline_cache.dart';
import 'sync_service.dart';

/// Goes up by one on every manual refresh. Figures worked out once (not
/// live lists) watch it, so a refresh works them out again.
final dataRefreshEpochProvider = StateProvider<int>((ref) => 0);

class DataRefreshState {
  const DataRefreshState({this.running = false, this.lastAt});
  final bool running;
  final DateTime? lastAt;
}

/// The status bar's refresh: checks the connection, sends what is waiting
/// (online), then has every screen show its data again — from this device
/// at once, and from the server when there is a connection. Nothing waiting
/// to be sent is dropped or sent twice (sending goes through the usual
/// queue). A refresh asked for while one runs is ignored.
class DataRefreshController extends StateNotifier<DataRefreshState> {
  DataRefreshController(this._ref) : super(const DataRefreshState());

  final Ref _ref;

  Future<void> refresh() async {
    if (state.running) return;
    state = DataRefreshState(running: true, lastAt: state.lastAt);
    try {
      var online = false;
      if (kUseSupabaseBackend) {
        try {
          await _ref.read(connectivityProvider.notifier).check();
          online = _ref.read(connectivityProvider);
          if (online) await _ref.read(syncServiceProvider.notifier).syncNow();
        } catch (_) {
          // Refreshing from this device's own data still works.
        }
      }
      refreshAllData(fromServer: online);
      _ref.read(dataRefreshEpochProvider.notifier).state++;
    } finally {
      if (mounted) state = DataRefreshState(lastAt: DateTime.now());
    }
  }
}

final dataRefreshProvider =
    StateNotifierProvider<DataRefreshController, DataRefreshState>((ref) => DataRefreshController(ref));
