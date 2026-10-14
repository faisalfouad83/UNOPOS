import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../supabase/supabase_client_provider.dart';
import '../supabase/supabase_config.dart';
import '../utils/id_generator.dart';
import 'connectivity.dart';
import 'offline_cache.dart';
import 'outbox.dart';

class SyncState {
  const SyncState({this.pending = 0, this.failed = 0, this.syncing = false});

  /// Changes waiting to be sent.
  final int pending;

  /// Changes the server refused (kept; can be retried).
  final int failed;
  final bool syncing;
}

/// True when [error] means "try again later" rather than "the server said
/// no": no connection, a timeout, the server being unavailable, or the
/// sign-in token needing a refresh after a long time offline.
bool isTransientError(Object error) {
  if (isNetworkError(error)) return true;
  if (error is PostgrestException) {
    final code = error.code ?? '';
    if (code.startsWith('PGRST3')) return true; // JWT expired / invalid
    if (code == '503' || code == '502' || code == '504' || code == '500') return true;
    final msg = error.message.toLowerCase();
    if (msg.contains('jwt') || msg.contains('timeout') || msg.contains('fetch')) return true;
  }
  if (error is AuthException) return true;
  return false;
}

/// Sends the [Outbox] to the server, in order, whenever there is a
/// connection: straight after a change is queued, as soon as the
/// connection comes back, and every [interval] as a safety net.
class SyncService extends StateNotifier<SyncState> {
  SyncService(this._outbox, this._client, this._connectivity, {Duration interval = const Duration(seconds: 20)})
      : super(const SyncState()) {
    _sub = _outbox.changes.listen((_) {
      _publish();
      if (_outbox.hasPending) _kick();
    });
    _outbox.load().then((_) {
      _publish();
      syncNow();
    });
    _timer = Timer.periodic(interval, (_) {
      if (_outbox.hasPending) syncNow();
    });
  }

  final Outbox _outbox;
  final SupabaseClient? _client;
  final ConnectivityMonitor? _connectivity;
  late final StreamSubscription<void> _sub;
  Timer? _timer;
  Timer? _debounce;
  bool _running = false;

  void _publish() {
    if (!mounted) return;
    state = SyncState(pending: _outbox.pending.length, failed: _outbox.failed.length, syncing: _running);
  }

  void _kick() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), syncNow);
  }

  /// Back online: send everything now.
  void onBackOnline() => syncNow();

  Future<void> retryFailed() async {
    await _outbox.retryFailed();
    await syncNow();
  }

  Future<void> syncNow() async {
    final client = _client;
    if (client == null || _running || !_outbox.hasPending) return;
    _running = true;
    _publish();
    try {
      for (final op in _outbox.pending) {
        try {
          final result = await execute(client, op, _outbox);
          _outbox.recordResult(op.id, result);
          await _outbox.done(op.id);
          _connectivity?.markOnline();
        } catch (e) {
          if (isTransientError(e)) {
            if (isNetworkError(e)) _connectivity?.markOffline();
            break; // keep the order: try again later from here
          }
          await _outbox.replace(op.copyWith(failed: true, lastError: _describe(e)));
        }
      }
    } finally {
      _running = false;
      _publish();
    }
  }

  static String _describe(Object e) => e is PostgrestException ? e.message : '$e';

  @override
  void dispose() {
    _sub.cancel();
    _timer?.cancel();
    _debounce?.cancel();
    super.dispose();
  }
}

/// Sends one change. Every kind is safe to repeat. References to earlier
/// changes' server results ([Outbox.ref]) are filled in from [outbox].
Future<Object?> execute(SupabaseClient client, OutboxOp op, Outbox outbox) async {
  const timeout = Duration(seconds: 15);
  Map<String, dynamic>? resolved(Map<String, dynamic>? m) =>
      m == null ? null : (outbox.resolve(m) as Map).cast<String, dynamic>();
  switch (op.kind) {
    case OutboxKind.insert:
      final rows = await client
          .from(op.table!)
          .upsert(resolved(op.row)!, onConflict: op.matchColumn ?? 'id', ignoreDuplicates: true)
          .select()
          .timeout(timeout);
      return rows.isEmpty ? null : rows.first;
    case OutboxKind.update:
      await client
          .from(op.table!)
          .update(resolved(op.row)!)
          .eq(op.matchColumn!, outbox.resolve(op.matchValue)!)
          .timeout(timeout);
      return null;
    case OutboxKind.rpc:
      final json = await client.rpc(
        'run_client_op',
        params: {'p_op_id': op.id, 'p_rpc': op.rpc, 'p_params': resolved(op.params) ?? const {}},
      ).timeout(timeout);
      return (json as Map)['result'];
    case OutboxKind.checkout:
      try {
        return await client.rpc('checkout_sale_once', params: resolved(op.params)).timeout(timeout);
      } on PostgrestException catch (e) {
        // This sale is already recorded (an earlier send got through).
        if (e.code == '23505') return {'duplicate': true};
        rethrow;
      }
  }
}

/// Thrown for work that can only be done online (e.g. activating a code),
/// when there is no connection.
class NeedsConnectionException implements Exception {
  const NeedsConnectionException();
  @override
  String toString() => 'This needs an internet connection.';
}

/// The way every screen saves to the server: with a connection (and
/// nothing older still waiting) the change is sent now; otherwise — or if
/// the connection drops while sending — it is kept in the [Outbox] and the
/// caller gets the expected result straight away, so work carries on. The
/// server's refusals (bad input, not allowed) still reach the caller when
/// sent directly.
class OfflineWriter {
  OfflineWriter(this._client, this._outbox, this._connectivity);

  final SupabaseClient _client;
  final Outbox _outbox;
  final ConnectivityMonitor _connectivity;

  bool get _mustQueue => !_connectivity.isOnline || _outbox.hasPending;

  /// Adds [row] to [table]. The row gets an id here when it has none, so it
  /// can be shown and referred to before the server has it (columns the
  /// screens read, like a creation time, are the caller's to fill in).
  /// Returns the row (the server's copy when sent now).
  ///
  /// [key] is the table's primary key column when it isn't `id` (such a
  /// row gets no generated id).
  Future<Map<String, dynamic>> insert(String table, Map<String, dynamic> row, {String key = 'id'}) async {
    final full = {
      if (key == 'id') 'id': IdGenerator.newId(),
      ...row,
    };
    final op = OutboxOp(
      id: IdGenerator.newId(),
      kind: OutboxKind.insert,
      createdAt: DateTime.now(),
      table: table,
      row: full,
      matchColumn: key == 'id' ? null : key,
    );
    final result = await _send(op);
    return result is Map ? {...full, ...result.cast<String, dynamic>()} : full;
  }

  /// Changes [patch] on the rows of [table] where [column] = [value].
  Future<void> update(String table, Map<String, dynamic> patch, {String column = 'id', required Object value}) async {
    final op = OutboxOp(
      id: IdGenerator.newId(),
      kind: OutboxKind.update,
      createdAt: DateTime.now(),
      table: table,
      row: patch,
      matchColumn: column,
      matchValue: value,
    );
    await _send(op);
  }

  /// Runs server function [name] exactly once. [offline] gives the result
  /// to carry on with when it has to wait (null = it can't wait: throws
  /// [NeedsConnectionException] when offline).
  ///
  /// While it waits, [previewTable]/[preview] is shown as a row added to
  /// that table and [increments] (`{table, id, column, by}`) as amounts
  /// added to existing rows. [opId] fixes the id it runs once under.
  Future<Object?> rpc(
    String name,
    Map<String, dynamic> params, {
    Object? Function()? offline,
    String? previewTable,
    Map<String, dynamic>? preview,
    List<Map<String, dynamic>> increments = const [],
    String? opId,
  }) async {
    final op = OutboxOp(
      id: opId ?? IdGenerator.newId(),
      kind: OutboxKind.rpc,
      createdAt: DateTime.now(),
      rpc: name,
      params: params,
      table: previewTable,
      row: preview,
      increments: increments,
    );
    if (offline == null && !_connectivity.isOnline) throw const NeedsConnectionException();
    if (offline == null) {
      // Must run now (its result matters): send it directly, still once.
      try {
        return await execute(_client, op, _outbox);
      } catch (e) {
        if (isNetworkError(e)) {
          _connectivity.markOffline();
          throw const NeedsConnectionException();
        }
        rethrow;
      }
    }
    final result = await _send(op);
    return identical(result, _queued) ? offline() : result;
  }

  /// Whether a change made now goes straight to the server.
  bool get sendsNow => !_mustQueue;

  /// A sale; null when it was kept to send later. [preview] is the sale as
  /// a `sales` row (with its lines under `_lines`), shown until the server's
  /// copy arrives.
  Future<Map<String, dynamic>?> checkout(
    String clientSaleId,
    Map<String, dynamic> params, {
    Map<String, dynamic>? preview,
  }) async {
    final op = OutboxOp(
      id: clientSaleId,
      kind: OutboxKind.checkout,
      createdAt: DateTime.now(),
      params: params,
      table: preview == null ? null : 'sales',
      row: preview,
    );
    final result = await _send(op);
    return identical(result, _queued) ? null : (result as Map).cast<String, dynamic>();
  }

  static const Object _queued = Object();

  Future<Object?> _send(OutboxOp op) async {
    await _outbox.load();
    if (_mustQueue) {
      await _outbox.add(op);
      return _queued;
    }
    try {
      final result = await execute(_client, op, _outbox);
      _connectivity.markOnline();
      return result;
    } catch (e) {
      if (!isTransientError(e)) rethrow;
      if (isNetworkError(e)) _connectivity.markOffline();
      await _outbox.add(op);
      return _queued;
    }
  }
}

final outboxProvider = Provider<Outbox>((ref) => Outbox.shared);

final syncServiceProvider = StateNotifierProvider<SyncService, SyncState>((ref) {
  final connectivity = kUseSupabaseBackend ? ref.watch(connectivityProvider.notifier) : null;
  final sync = SyncService(
    ref.watch(outboxProvider),
    kUseSupabaseBackend ? ref.watch(supabaseClientProvider) : null,
    connectivity,
  );
  // Back online: send what was done meanwhile straight away.
  ref.listen<bool>(connectivityProvider, (was, now) {
    if (now && was == false) sync.onBackOnline();
  });
  return sync;
});

final offlineWriterProvider = Provider<OfflineWriter>((ref) {
  return OfflineWriter(
    ref.watch(supabaseClientProvider),
    ref.watch(outboxProvider),
    ref.watch(connectivityProvider.notifier),
  );
});
