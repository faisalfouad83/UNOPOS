import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/offline/offline_cache.dart';
import '../../../../core/offline/outbox.dart';
import '../../../../core/utils/id_generator.dart';
import 'reset_archive.dart';
import 'reset_scope.dart';

/// Where a reset's data lives and how it is reset: the shared server
/// (`reset_store_data`, migration 0029) or this device's own database
/// (the single-device build).
abstract class StoreResetBackend {
  /// Whether the data is on the server (then the reset needs a connection,
  /// and this device's queued changes and saved copies are cleaned up).
  bool get isServer;

  /// Rows each table would lose to a reset of [scopes] (nothing changes).
  Future<Map<String, int>> preview(List<ResetScope> scopes);

  /// Every row of [table] for this store, for the backup.
  Future<List<Map<String, dynamic>>> rows(String table);

  /// Resets [scopes] once for [resetId] (asking again returns the first
  /// result). [actorId] is the owner doing it.
  Future<StoreResetResult> apply(String resetId, List<ResetScope> scopes, String actorId);

  /// The finished reset [resetId], or null when it never happened.
  Future<StoreResetResult?> status(String resetId);

  /// Resets of this store numbered after [generation], oldest first.
  Future<List<StoreResetResult>> resetsSince(int generation);
}

/// A finished reset.
class StoreResetResult {
  const StoreResetResult({
    required this.resetId,
    required this.generation,
    required this.scopes,
    required this.counts,
    required this.createdAt,
  });

  factory StoreResetResult.fromJson(Map<String, dynamic> json) => StoreResetResult(
        resetId: (json['reset_id'] ?? json['id']) as String,
        generation: (json['generation'] as num?)?.toInt() ?? 0,
        scopes: [for (final s in (json['scopes'] as List? ?? const [])) ResetScope.fromWire('$s')]
            .whereType<ResetScope>()
            .toList(),
        counts: {
          for (final e in ((json['counts'] as Map?) ?? const {}).entries) '${e.key}': (e.value as num).toInt(),
        },
        createdAt: DateTime.tryParse('${json['created_at']}')?.toLocal() ?? DateTime.now(),
      );

  final String resetId;

  /// The store's reset number (1 for its first).
  final int generation;
  final List<ResetScope> scopes;

  /// Rows removed (or changed) per table.
  final Map<String, int> counts;
  final DateTime createdAt;
}

/// Where a backup file was saved.
class SavedBackup {
  const SavedBackup({required this.location, this.copyPath});

  /// What to show the owner: the chosen file (a path, or the name the
  /// system's file picker reported).
  final String location;

  /// A second copy kept in the app's own folder, when one was written.
  final String? copyPath;
}

/// Saves the backup file where the owner chooses and reads it back to be
/// checked.
abstract class BackupSink {
  /// Saves [bytes] (suggested name [fileName]); null when the owner
  /// cancelled choosing a place.
  Future<SavedBackup?> save(String fileName, Uint8List bytes);

  /// The saved file's bytes as they now are on disk.
  Future<Uint8List> readBack(SavedBackup saved);
}

/// The steps of a reset, in order.
enum ResetStage { backup, verify, reset, cleanup }

/// The owner closed the save dialog: nothing was changed.
class StoreResetCancelled implements Exception {
  const StoreResetCancelled();
}

/// A step failed; [stage] says which. Nothing on the server changed unless
/// [stage] is [ResetStage.cleanup].
class StoreResetFailure implements Exception {
  const StoreResetFailure(this.stage, this.reason, [this.cause]);

  final ResetStage stage;
  final StoreResetFailureReason reason;
  final Object? cause;

  @override
  String toString() => 'Reset failed at ${stage.name}: ${reason.name}${cause == null ? '' : ' ($cause)'}';
}

enum StoreResetFailureReason {
  /// No connection: the server holds the data, so it can't be reset now.
  offline,

  /// Changes made on this device haven't reached the server yet.
  unsentChanges,

  /// The backup couldn't be made or saved.
  backupFailed,

  /// The saved backup didn't read back as written.
  verifyFailed,

  /// The server refused (e.g. not the owner).
  refused,

  /// The reply was lost: it may have run. Checked again on next start.
  unknown,
}

/// What a finished reset did.
class StoreResetOutcome {
  const StoreResetOutcome({
    required this.result,
    required this.backup,
    required this.backupCounts,
    required this.droppedChanges,
  });

  final StoreResetResult result;
  final SavedBackup? backup;
  final Map<String, int> backupCounts;

  /// Queued changes on this device that were dropped.
  final int droppedChanges;
}

/// Runs a store reset: back up, check the backup, reset, clean up this
/// device — reporting each stage — and finishes one the app was closed in
/// the middle of.
///
/// Queued changes policy: right before the reset every change waiting on
/// this device is sent (the reset is refused while any can't be); after it
/// the changes left for the reset parts (refused or held ones) are
/// dropped. On every start ([reconcile]) a device looks for resets made
/// since the last one it saw (the store's reset number, "generation") and
/// drops its queued changes for those parts made before that reset — so an
/// old offline change from another till can't bring erased data back. Its
/// saved copies of those parts are dropped too.
class StoreResetService {
  StoreResetService({
    required this.backend,
    required this.storeId,
    this.outbox,
    this.isOnline,
    this.flush,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final StoreResetBackend backend;
  final String storeId;

  /// This device's queued changes (server backend only).
  final Outbox? outbox;

  /// Whether there is a connection now (server backend only).
  final bool Function()? isOnline;

  /// Sends the queued changes now (server backend only).
  final Future<void> Function()? flush;
  final DateTime Function() _now;

  static const _pendingKey = 'store_reset.pending.v1';
  static String _generationKey(String storeId) => 'store_reset.generation.$storeId';

  bool get _online => !backend.isServer || (isOnline?.call() ?? true);

  /// Rows each table would lose (nothing changes).
  Future<Map<String, int>> preview(List<ResetScope> scopes) {
    if (!_online) throw const StoreResetFailure(ResetStage.reset, StoreResetFailureReason.offline);
    return backend.preview(ResetPlan.expand(scopes));
  }

  /// Backs up, checks the backup, resets [chosen] and cleans up, calling
  /// [onStage] as each stage starts. Throws [StoreResetCancelled] or
  /// [StoreResetFailure].
  Future<StoreResetOutcome> run({
    required List<ResetScope> chosen,
    required String actorId,
    required BackupSink sink,
    void Function(ResetStage stage)? onStage,
  }) async {
    final scopes = ResetPlan.expand(chosen);
    if (scopes.isEmpty) throw ArgumentError('nothing chosen');
    if (!_online) throw const StoreResetFailure(ResetStage.backup, StoreResetFailureReason.offline);
    final resetId = IdGenerator.newId();

    // 1. Backup.
    onStage?.call(ResetStage.backup);
    final ResetArchiveFile file;
    final SavedBackup? saved;
    try {
      file = await _buildBackup(resetId, scopes);
      saved = await sink.save(_fileName(), file.bytes);
    } on StoreResetFailure {
      rethrow;
    } catch (e) {
      throw StoreResetFailure(ResetStage.backup, StoreResetFailureReason.backupFailed, e);
    }
    if (saved == null) throw const StoreResetCancelled();

    // 2. Read it back and check it.
    onStage?.call(ResetStage.verify);
    try {
      ResetArchive.verify(await sink.readBack(saved), file, storeId: storeId);
    } catch (e) {
      throw StoreResetFailure(ResetStage.verify, StoreResetFailureReason.verifyFailed, e);
    }

    // 3. Reset.
    onStage?.call(ResetStage.reset);
    if (backend.isServer) {
      if (!_online) throw const StoreResetFailure(ResetStage.reset, StoreResetFailureReason.offline);
      await flush?.call();
      final box = outbox;
      if (box != null && box.pending.isNotEmpty) {
        throw const StoreResetFailure(ResetStage.reset, StoreResetFailureReason.unsentChanges);
      }
    }
    await _savePending(_PendingReset(resetId: resetId, storeId: storeId, scopes: scopes));
    final StoreResetResult result;
    try {
      result = await backend.apply(resetId, scopes, actorId);
    } catch (e) {
      if (_mayHaveRun(e)) {
        // Kept: the next start asks the server whether it ran.
        throw StoreResetFailure(ResetStage.reset, StoreResetFailureReason.unknown, e);
      }
      await _clearPending();
      throw StoreResetFailure(ResetStage.reset, StoreResetFailureReason.refused, e);
    }

    // 4. This device.
    onStage?.call(ResetStage.cleanup);
    final dropped = await _cleanUp(result, before: null);
    await _clearPending();
    return StoreResetOutcome(result: result, backup: saved, backupCounts: file.counts, droppedChanges: dropped);
  }

  /// Finishes a reset the app was closed (or lost its connection) in the
  /// middle of: when it ran, this device is cleaned up and the result
  /// returned; when it never ran, it is forgotten (nothing was erased).
  /// Null when there was none, or it can't be checked yet (offline).
  Future<StoreResetResult?> resumePending() async {
    final pending = await _loadPending();
    if (pending == null || pending.storeId != storeId) return null;
    if (!_online) return null;
    final StoreResetResult? done;
    try {
      done = await backend.status(pending.resetId);
    } catch (_) {
      return null; // try again next time
    }
    if (done != null) await _cleanUp(done, before: null);
    await _clearPending();
    return done;
  }

  /// Applies resets made on other devices since the last one this device
  /// saw (see the class notes). Returns how many queued changes were
  /// dropped.
  Future<int> reconcile() async {
    if (!backend.isServer || !_online) return 0;
    final prefs = await SharedPreferences.getInstance();
    final known = prefs.getInt(_generationKey(storeId)) ?? 0;
    final List<StoreResetResult> newer;
    try {
      newer = await backend.resetsSince(known);
    } catch (_) {
      return 0;
    }
    var dropped = 0;
    for (final r in newer) {
      dropped += await _cleanUp(r, before: r.createdAt);
    }
    return dropped;
  }

  /// Drops this device's queued changes and saved copies for [result]'s
  /// parts (only changes made before [before], when given) and notes its
  /// reset number. Safe to repeat.
  Future<int> _cleanUp(StoreResetResult result, {DateTime? before}) async {
    var dropped = 0;
    if (backend.isServer) {
      final box = outbox;
      if (box != null) {
        final gone = await box.purge(
          (op) => (before == null || op.createdAt.isBefore(before)) && ResetPlan.affectsOp(op, result.scopes),
          storeId: storeId,
        );
        dropped = gone.length;
      }
      await OfflineCache.removeByPrefixes(ResetPlan.cachePrefixesOf(result.scopes));
    }
    final prefs = await SharedPreferences.getInstance();
    final known = prefs.getInt(_generationKey(storeId)) ?? 0;
    if (result.generation > known) await prefs.setInt(_generationKey(storeId), result.generation);
    return dropped;
  }

  Future<ResetArchiveFile> _buildBackup(String resetId, List<ResetScope> scopes) async {
    final tables = <String, List<Map<String, dynamic>>>{};
    for (final table in ResetPlan.tablesOf(scopes)) {
      tables[table] = await backend.rows(table);
    }
    final box = outbox;
    final device = <String, dynamic>{
      'outbox': [
        if (box != null)
          for (final op in box.ops)
            if ((op.storeId ?? storeId) == storeId) op.toJson(),
      ],
      if (box != null)
        'sync': {
          'pending': box.pending.length,
          'failed': box.failed.length,
          'held': box.held.length,
          'store': box.store,
        },
    };
    return ResetArchive.build(
      storeId: storeId,
      resetId: resetId,
      scopes: [for (final s in scopes) s.wire],
      tables: tables,
      device: device,
      exportedAt: _now(),
    );
  }

  String _fileName() {
    final t = _now();
    String two(int n) => n.toString().padLeft(2, '0');
    return 'unopos_reset_backup_${t.year}${two(t.month)}${two(t.day)}_${two(t.hour)}${two(t.minute)}${two(t.second)}.json';
  }

  /// Whether a failed request may still have reached the server and run.
  static bool _mayHaveRun(Object e) {
    if (e is TimeoutException) return true;
    return isNetworkError(e);
  }

  Future<void> _savePending(_PendingReset p) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pendingKey, jsonEncode(p.toJson()));
  }

  Future<_PendingReset?> _loadPending() async {
    final raw = (await SharedPreferences.getInstance()).getString(_pendingKey);
    if (raw == null) return null;
    try {
      return _PendingReset.fromJson((jsonDecode(raw) as Map).cast<String, dynamic>());
    } catch (_) {
      return null;
    }
  }

  Future<void> _clearPending() async => (await SharedPreferences.getInstance()).remove(_pendingKey);

  /// Whether a reset started on this device hasn't been confirmed yet.
  static Future<bool> hasPending() async => (await SharedPreferences.getInstance()).getString(_pendingKey) != null;
}

/// A reset sent (or about to be sent) and not yet confirmed, kept on the
/// device until it is.
class _PendingReset {
  const _PendingReset({required this.resetId, required this.storeId, required this.scopes});

  factory _PendingReset.fromJson(Map<String, dynamic> json) => _PendingReset(
        resetId: json['reset_id'] as String,
        storeId: json['store_id'] as String,
        scopes: [for (final s in (json['scopes'] as List)) ResetScope.fromWire('$s')].whereType<ResetScope>().toList(),
      );

  final String resetId;
  final String storeId;
  final List<ResetScope> scopes;

  Map<String, dynamic> toJson() => {
        'reset_id': resetId,
        'store_id': storeId,
        'scopes': [for (final s in scopes) s.wire],
      };
}
