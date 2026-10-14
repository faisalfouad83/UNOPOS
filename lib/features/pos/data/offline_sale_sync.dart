import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/offline/connectivity.dart';
import '../../../core/offline/offline_cache.dart';
import '../../../core/providers.dart';
import '../../../core/supabase/supabase_client_provider.dart';
import '../../../core/supabase/supabase_config.dart';
import 'offline_sale_queue.dart';

class OfflineSyncState {
  const OfflineSyncState({this.pending = 0, this.syncing = false});
  final int pending;
  final bool syncing;
}

/// Sends sales queued while offline to the server: on start, every
/// [interval], and on demand (tapping the pending-sales indicator).
class OfflineSaleSync extends StateNotifier<OfflineSyncState> {
  OfflineSaleSync(this._queue, this._client, {Duration interval = const Duration(seconds: 30)})
      : super(const OfflineSyncState()) {
    refresh();
    _timer = Timer.periodic(interval, (_) => syncNow());
  }

  final OfflineSaleQueue _queue;
  final SupabaseClient? _client;
  Timer? _timer;

  Future<void> refresh() async {
    final count = (await _queue.all()).length;
    if (mounted) state = OfflineSyncState(pending: count, syncing: state.syncing);
  }

  Future<void> syncNow() async {
    final client = _client;
    if (client == null || state.syncing) return;
    final queued = await _queue.all();
    if (queued.isEmpty) {
      await refresh();
      return;
    }
    if (mounted) state = OfflineSyncState(pending: queued.length, syncing: true);
    try {
      for (final sale in queued) {
        try {
          await client.rpc('checkout_sale_once', params: sale.params);
          await _queue.remove(sale.clientSaleId);
        } on PostgrestException catch (e) {
          // 23505 = this client id is already recorded: the original
          // request got through before the connection dropped.
          if (e.code == '23505') {
            await _queue.remove(sale.clientSaleId);
          } else {
            await _queue.replace(sale.withError(e.message));
          }
        } catch (e) {
          if (isNetworkError(e)) break; // still offline — try again later
          await _queue.replace(sale.withError(e.toString()));
        }
      }
    } finally {
      final remaining = (await _queue.all()).length;
      if (mounted) state = OfflineSyncState(pending: remaining);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final offlineSaleSyncProvider = StateNotifierProvider<OfflineSaleSync, OfflineSyncState>((ref) {
  final sync = OfflineSaleSync(
    ref.watch(offlineSaleQueueProvider),
    kUseSupabaseBackend ? ref.watch(supabaseClientProvider) : null,
  );
  // Back online: send what was sold meanwhile straight away.
  ref.listen<bool>(connectivityProvider, (was, now) {
    if (now && was == false) sync.syncNow();
  });
  return sync;
});
