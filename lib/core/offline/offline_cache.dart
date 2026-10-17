import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'outbox.dart';

/// Last-known copies of the shared-backend data the till needs to keep
/// working when the internet drops. Stored as the raw JSON rows the
/// backend returned, so any repository can cache what it reads without a
/// per-type serializer.
///
/// Each copy is its own file in the app's data folder (copies can be large
/// — thousands of invoices — and are refreshed often), written shortly
/// after the last change and read from memory once loaded. Where there is
/// no data folder (tests), the app's preferences are used instead.
///
/// The day each copy was last used (read or written) is noted, and copies
/// not used for [maxUnusedAge] are dropped ([prune]) — e.g. one product or
/// break looked up once, long ago. What the till needs is used every time
/// a store opens, so it is never dropped.
class OfflineCache {
  OfflineCache._();

  static const String _prefix = 'offline_cache.';

  /// Set while the app knows it has no connection: one-off reads go
  /// straight to the copy instead of waiting for a request to fail.
  static bool knownOffline = false;
  static final _memory = <String, Object?>{};
  static final _timers = <String, Timer>{};
  static Future<Directory?>? _dir;

  /// How long a copy is kept without being used.
  static const Duration maxUnusedAge = Duration(days: 60);
  static const String _indexKey = 'offline_cache_index.v1';

  /// The day (since 1970) each copy was last used, by file name.
  static Map<String, int>? _index;
  static Future<void>? _indexSave;
  static bool _pruned = false;

  static int _today() => DateTime.now().millisecondsSinceEpoch ~/ Duration.millisecondsPerDay;

  static Future<Map<String, int>> _loadIndex() async {
    final existing = _index;
    if (existing != null) return existing;
    final raw = (await SharedPreferences.getInstance()).getString(_indexKey);
    final loaded = raw == null ? <String, int>{} : (jsonDecode(raw) as Map).map((k, v) => MapEntry('$k', v as int));
    return _index ??= loaded;
  }

  /// Notes that [key] was used today (saved at most once a day per copy).
  static Future<void> _touch(String key) async {
    try {
      final index = await _loadIndex();
      final name = _fileName(key);
      final today = _today();
      if (index[name] == today) return;
      index[name] = today;
      _saveIndex();
    } catch (_) {}
  }

  static void _saveIndex() {
    _indexSave ??= Future.microtask(() async {
      _indexSave = null;
      final index = _index;
      if (index == null) return;
      await (await SharedPreferences.getInstance()).setString(_indexKey, jsonEncode(index));
    });
  }

  /// Drops copies not used for [maxAge] (once per run; best effort). A copy
  /// kept from before uses were noted counts as used today.
  static Future<void> prune({Duration maxAge = maxUnusedAge}) async {
    if (_pruned) return;
    _pruned = true;
    try {
      final index = await _loadIndex();
      final today = _today();
      final oldest = today - maxAge.inDays;
      final kept = <String>{};
      final dropped = <String>{};
      bool keep(String name) {
        final used = index.putIfAbsent(name, () => today);
        if (used >= oldest) {
          kept.add(name);
          return true;
        }
        dropped.add(name);
        return false;
      }

      final dir = await _folder();
      if (dir != null) {
        await for (final entry in dir.list()) {
          if (entry is! File || !entry.path.endsWith('.json')) continue;
          if (!keep(p.basename(entry.path))) await entry.delete();
        }
      }
      final prefs = await SharedPreferences.getInstance();
      for (final k in prefs.getKeys().where((k) => k.startsWith(_prefix)).toList()) {
        final name = _fileName(k.substring(_prefix.length));
        if (kept.contains(name)) continue;
        if (dropped.contains(name) || !keep(name)) await prefs.remove(k);
      }
      _memory.removeWhere((key, _) => dropped.contains(_fileName(key)));
      // Notes about copies that no longer exist.
      index.removeWhere((name, _) => !kept.contains(name));
      _saveIndex();
    } catch (_) {}
  }

  /// Where the copies are kept; null = use preferences.
  static Future<Directory?> _folder() => _dir ??= () async {
        try {
          final base = await getApplicationSupportDirectory();
          final dir = Directory(p.join(base.path, 'offline_cache'));
          await dir.create(recursive: true);
          return dir;
        } catch (_) {
          return null;
        }
      }();

  static String _fileName(String key) => '${key.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_')}.json';

  static Future<void> write(String key, Object? rows) async {
    final value = jsonDecode(jsonEncode(rows));
    _memory[key] = value;
    unawaited(_touch(key));
    final dir = await _folder();
    if (dir == null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_prefix$key', jsonEncode(value));
      return;
    }
    // Several updates in a row (a live stream) end in one write.
    _timers[key]?.cancel();
    _timers[key] = Timer(const Duration(milliseconds: 400), () async {
      _timers.remove(key);
      try {
        final file = File(p.join(dir.path, _fileName(key)));
        final tmp = File('${file.path}.tmp');
        await tmp.writeAsString(jsonEncode(_memory[key]), flush: true);
        await tmp.rename(file.path);
      } catch (_) {}
    });
  }

  static Future<Object?> read(String key) async {
    if (_memory.containsKey(key)) {
      unawaited(_touch(key));
      return _memory[key];
    }
    final dir = await _folder();
    Object? value;
    if (dir == null) {
      final raw = (await SharedPreferences.getInstance()).getString('$_prefix$key');
      value = raw == null ? null : jsonDecode(raw);
    } else {
      try {
        final file = File(p.join(dir.path, _fileName(key)));
        value = await file.exists() ? jsonDecode(await file.readAsString()) : null;
      } catch (_) {
        value = null;
      }
      if (value == null) {
        // Copies kept by earlier versions.
        final raw = (await SharedPreferences.getInstance()).getString('$_prefix$key');
        value = raw == null ? null : jsonDecode(raw);
      }
    }
    if (value != null) {
      _memory[key] = value;
      unawaited(_touch(key));
    }
    return value;
  }

  static Future<List<Map<String, dynamic>>?> readRows(String key) async {
    final value = await read(key);
    if (value is! List) return null;
    return value.cast<Map<String, dynamic>>();
  }

  /// Forgets what is held in memory (tests).
  static void resetMemory() {
    _memory.clear();
    _index = null;
    _pruned = false;
    for (final t in _timers.values) {
      t.cancel();
    }
    _timers.clear();
  }
}

/// True for failures that mean "couldn't reach the server" (as opposed to
/// the server rejecting the request), i.e. worth retrying later.
bool isNetworkError(Object error) {
  if (error is SocketException || error is TimeoutException) return true;
  final text = error.toString();
  return text.contains('SocketException') ||
      text.contains('Failed host lookup') ||
      text.contains('Connection refused') ||
      text.contains('Connection reset') ||
      text.contains('Network is unreachable') ||
      text.contains('ClientException') ||
      text.contains('AuthRetryableFetchException');
}

final _refreshRequests = StreamController<bool>.broadcast();

/// Asks every live list on screen to show its data again: at once from what
/// this device has (with its unsent changes laid over), and — when
/// [fromServer] — by fetching it afresh from the server.
void refreshAllData({bool fromServer = true}) => _refreshRequests.add(fromServer);

/// Wraps a backend stream of rows so the till keeps working offline:
/// the last cached copy is shown immediately, every live update refreshes
/// the cache ([cacheRow] can drop fields that must not be kept on the
/// device), and a dropped connection keeps showing the last data while it
/// quietly resubscribes, instead of surfacing an error screen. With
/// [cache] off nothing is stored on the device (rows with personal data);
/// the stream still resubscribes after a dropped connection.
///
/// With [table], changes made on this device to that table and not yet
/// sent ([Outbox]) are laid over the rows (new rows that match [where]
/// included), and the stream updates as they are made and sent.
/// [cacheWhere] keeps only some rows on the device (e.g. debts still open).
Stream<List<Map<String, dynamic>>> resilientRows(
  String cacheKey,
  Stream<List<Map<String, dynamic>>> Function() subscribe, {
  Duration retryDelay = const Duration(seconds: 10),
  bool cache = true,
  Map<String, dynamic> Function(Map<String, dynamic> row)? cacheRow,
  String? table,
  bool Function(Map<String, dynamic> row)? where,
  Outbox? outbox,
  int? cacheTake,
  bool Function(Map<String, dynamic> row)? cacheWhere,
}) {
  late StreamController<List<Map<String, dynamic>>> controller;
  StreamSubscription<List<Map<String, dynamic>>>? subscription;
  StreamSubscription<void>? local;
  StreamSubscription<bool>? refresh;
  Timer? retry;
  var hasValue = false;
  var cancelled = false;
  List<Map<String, dynamic>>? last;
  // When the server sent [last] (null: the copy on the device).
  DateTime? lastAt;
  final box = table == null ? null : (outbox ?? Outbox.shared);

  void emit(List<Map<String, dynamic>> rows, DateTime? at) {
    last = rows;
    lastAt = at;
    controller.add(box == null ? rows : box.applyTo(table!, rows, where: where, asOf: at));
  }

  void listen() {
    if (cancelled) return;
    subscription = subscribe().listen(
      (rows) {
        hasValue = true;
        emit(rows, DateTime.now());
        if (cache) {
          final wanted = cacheWhere == null ? rows : rows.where(cacheWhere);
          final kept = cacheTake == null ? wanted : wanted.take(cacheTake);
          OfflineCache.write(cacheKey, cacheRow == null ? kept.toList() : kept.map(cacheRow).toList());
        }
      },
      onError: (Object error, StackTrace stack) {
        subscription?.cancel();
        if (!hasValue) controller.addError(error, stack);
        retry = Timer(retryDelay, listen);
      },
    );
  }

  controller = StreamController<List<Map<String, dynamic>>>(
    onListen: () async {
      if (box != null) {
        await box.load();
        local = box.changes.listen((_) {
          final rows = last;
          if (rows != null && !cancelled) emit(rows, lastAt);
        });
      }
      refresh = _refreshRequests.stream.listen((fromServer) {
        final rows = last;
        if (cancelled) return;
        if (rows != null) emit(rows, lastAt);
        if (fromServer && !OfflineCache.knownOffline) {
          retry?.cancel();
          subscription?.cancel();
          listen();
        }
      });
      final cached = cache ? await OfflineCache.readRows(cacheKey) : null;
      if (cached != null && !hasValue && !cancelled) {
        hasValue = true;
        emit(cached, null);
      } else if (box != null && !hasValue && !cancelled && box.pending.any((o) => o.table == table)) {
        // Nothing from the server yet (offline, first time): show at least
        // what was made on this device.
        emit(const [], null);
      }
      listen();
    },
    onCancel: () async {
      cancelled = true;
      retry?.cancel();
      await refresh?.cancel();
      await local?.cancel();
      await subscription?.cancel();
    },
  );
  return controller.stream;
}

/// Runs [fetch] and caches its rows under [key]; with no connection, the
/// last cached rows are returned instead (null when never cached). With
/// [table], this device's unsent changes to it are laid over (see
/// [resilientRows]).
Future<List<Map<String, dynamic>>?> fetchRowsOrCached(
  String key,
  Future<List<Map<String, dynamic>>> Function() fetch, {
  String? table,
  bool Function(Map<String, dynamic> row)? where,
  Outbox? outbox,
}) async {
  List<Map<String, dynamic>>? rows;
  DateTime? fetchedAt;
  if (OfflineCache.knownOffline) {
    rows = await OfflineCache.readRows(key);
  } else {
    try {
      final started = DateTime.now();
      rows = await fetch().timeout(const Duration(seconds: 10));
      fetchedAt = started;
      await OfflineCache.write(key, rows);
    } catch (e) {
      if (!isNetworkError(e)) rethrow;
      rows = await OfflineCache.readRows(key);
    }
  }
  if (table == null) return rows;
  final box = outbox ?? Outbox.shared;
  await box.load();
  if (rows == null && !box.pending.any((o) => o.table == table)) return null;
  return box.applyTo(table, rows ?? const [], where: where, asOf: fetchedAt);
}
