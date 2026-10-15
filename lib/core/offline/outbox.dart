import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// What a queued change does on the server.
enum OutboxKind {
  /// Add a row (sent as an upsert that ignores a row already there, so a
  /// repeat is harmless). The row always carries its own id.
  insert,

  /// Change the rows where [OutboxOp.matchColumn] = [OutboxOp.matchValue].
  update,

  /// Run a server function once (through `run_client_op`, keyed by the op id).
  rpc,

  /// A sale (`checkout_sale_once`, keyed by its own client sale id).
  checkout,
}

/// One change made on this device that the server hasn't confirmed yet.
class OutboxOp {
  const OutboxOp({
    required this.id,
    required this.kind,
    required this.createdAt,
    this.table,
    this.row,
    this.matchColumn,
    this.matchValue,
    this.rpc,
    this.params,
    this.lastError,
    this.failed = false,
    this.increments = const [],
    this.storeId,
    this.attemptedAt,
  });

  /// Unique; for an RPC it is also the id the server dedupes on, for a sale
  /// its client sale id.
  final String id;
  final OutboxKind kind;
  final DateTime createdAt;
  final String? table;

  /// The row to add, or the fields to change.
  final Map<String, dynamic>? row;
  final String? matchColumn;
  final Object? matchValue;
  final String? rpc;
  final Map<String, dynamic>? params;
  final String? lastError;

  /// The server refused it (not a connection problem). Kept so nothing is
  /// lost silently; it can be retried or discarded from the status bar.
  final bool failed;

  /// What a server function will do to existing rows, shown until it has
  /// run: each `{table, id, column, by}` (adds) or `{table, id, set: {..}}`.
  /// Stock a function moves is `{table: 'stock_items', product_id,
  /// branch_id, column, by}` (see `stockIncrement`).
  final List<Map<String, dynamic>> increments;

  /// The store signed in when the change was made: it is only sent while
  /// that store is signed in (the server applies it to the signed-in
  /// store). Null for changes queued by earlier versions; they belong to
  /// the next store signed in.
  final String? storeId;

  /// When an earlier send of it was cut off after it may already have
  /// reached the server (e.g. no reply in time). The server runs it only
  /// once either way; until it is confirmed, data fetched after this time
  /// may already include it.
  final DateTime? attemptedAt;

  OutboxOp copyWith({String? lastError, bool? failed, String? storeId, DateTime? attemptedAt}) => OutboxOp(
        id: id,
        kind: kind,
        createdAt: createdAt,
        table: table,
        row: row,
        matchColumn: matchColumn,
        matchValue: matchValue,
        rpc: rpc,
        params: params,
        lastError: lastError ?? this.lastError,
        failed: failed ?? this.failed,
        increments: increments,
        storeId: storeId ?? this.storeId,
        attemptedAt: attemptedAt ?? this.attemptedAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': kind.name,
        'createdAt': createdAt.toUtc().toIso8601String(),
        if (table != null) 'table': table,
        if (row != null) 'row': row,
        if (matchColumn != null) 'matchColumn': matchColumn,
        if (matchValue != null) 'matchValue': matchValue,
        if (rpc != null) 'rpc': rpc,
        if (params != null) 'params': params,
        if (lastError != null) 'lastError': lastError,
        if (failed) 'failed': true,
        if (increments.isNotEmpty) 'increments': increments,
        if (storeId != null) 'storeId': storeId,
        if (attemptedAt != null) 'attemptedAt': attemptedAt!.toUtc().toIso8601String(),
      };

  factory OutboxOp.fromJson(Map<String, dynamic> json) => OutboxOp(
        id: json['id'] as String,
        kind: OutboxKind.values.byName(json['kind'] as String),
        createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
        table: json['table'] as String?,
        row: (json['row'] as Map?)?.cast<String, dynamic>(),
        matchColumn: json['matchColumn'] as String?,
        matchValue: json['matchValue'],
        rpc: json['rpc'] as String?,
        params: (json['params'] as Map?)?.cast<String, dynamic>(),
        lastError: json['lastError'] as String?,
        failed: json['failed'] == true,
        increments: ((json['increments'] as List?) ?? const []).cast<Map<String, dynamic>>(),
        storeId: json['storeId'] as String?,
        attemptedAt: json['attemptedAt'] == null ? null : DateTime.parse(json['attemptedAt'] as String).toLocal(),
      );
}

/// Every change made on this device that hasn't reached the server yet, in
/// the order it was made, kept on the device (survives restarts). Reads
/// lay these over the server's last data ([applyTo]) so the screen shows
/// the change straight away, online or not.
///
/// Changes belong to the store signed in when they were made ([store]):
/// another store's changes wait, untouched, until it signs in again. A
/// change the server refused stays apart ([failed]), and so do the changes
/// that build on it ([held]: e.g. an edit to a row whose adding was
/// refused) until it is retried or discarded.
class Outbox {
  Outbox({
    Duration settle = const Duration(seconds: 20),
    Duration stockSettle = const Duration(seconds: 10),
    Duration keepResults = const Duration(days: 7),
  })  : _settle = settle,
        _stockSettle = stockSettle,
        _keepResults = keepResults;

  /// The app's one outbox (reads lay it over server data without needing
  /// to be handed it).
  static final Outbox shared = Outbox();

  static const String _key = 'outbox.v1';
  static const String _legacySalesKey = 'offline_sale_queue.v1';

  final Duration _settle;
  final Duration _stockSettle;
  final Duration _keepResults;
  final _ops = <OutboxOp>[];

  /// What the server returned for changes sent from the queue, by op id,
  /// for later changes that refer to them ([ref]), and when it came back.
  /// Kept for [_keepResults] (a change made later, or a screen still
  /// showing the first copy, may refer to it after the queue has emptied).
  final _results = <String, Object?>{};
  final _resultTimes = <String, DateTime>{};

  /// Sent a moment ago: still shown until the server's own copy arrives.
  final _settling = <(OutboxOp, DateTime)>[];
  final _changes = StreamController<void>.broadcast();
  Future<void>? _loading;
  String? _store;

  /// Ids of changes held back behind a refused one (worked out again after
  /// every change to the queue).
  Set<String>? _heldIds;

  /// Fires whenever the queue changes.
  Stream<void> get changes => _changes.stream;

  Future<void> load() => _loading ??= _load();

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      _ops.addAll((jsonDecode(raw) as List).cast<Map<String, dynamic>>().map(OutboxOp.fromJson));
    }
    final results = prefs.getString('$_key.results');
    if (results != null) _results.addAll((jsonDecode(results) as Map).cast<String, Object?>());
    final times = prefs.getString('$_key.resultTimes');
    if (times != null) {
      (jsonDecode(times) as Map).forEach((id, at) => _resultTimes['$id'] = DateTime.parse(at as String).toLocal());
    }
    // Results kept by earlier versions have no time: they count from now.
    final now = DateTime.now();
    for (final id in _results.keys) {
      _resultTimes.putIfAbsent(id, () => now);
    }
    // Sales queued by earlier versions (before everything went through here).
    final legacy = prefs.getString(_legacySalesKey);
    if (legacy != null) {
      for (final s in (jsonDecode(legacy) as List).cast<Map<String, dynamic>>()) {
        final id = s['clientSaleId'] as String;
        if (_ops.any((o) => o.id == id)) continue;
        _ops.add(
          OutboxOp(
            id: id,
            kind: OutboxKind.checkout,
            createdAt: DateTime.parse(s['queuedAt'] as String).toLocal(),
            params: (s['params'] as Map).cast<String, dynamic>(),
          ),
        );
      }
      await prefs.remove(_legacySalesKey);
    }
    if (_store != null) _adopt(_store!);
    _heldIds = null;
    await _save();
    _changes.add(null);
  }

  Future<void> _save() async {
    _heldIds = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(_ops.map((o) => o.toJson()).toList()));
    _pruneResults();
    await prefs.setString('$_key.results', jsonEncode(_results));
    await prefs.setString(
      '$_key.resultTimes',
      jsonEncode(_resultTimes.map((id, at) => MapEntry(id, at.toUtc().toIso8601String()))),
    );
  }

  /// Forgets results older than [_keepResults], unless a waiting change
  /// still refers to them.
  void _pruneResults() {
    final now = DateTime.now();
    final old = [
      for (final e in _resultTimes.entries)
        if (now.difference(e.value) > _keepResults) e.key,
    ];
    if (old.isEmpty) return;
    final referred = <String>{};
    void collect(Object? v) {
      if (v is String) {
        final m = _refPattern.firstMatch(v);
        if (m != null) referred.add(m.group(1)!);
      } else if (v is Map) {
        v.values.forEach(collect);
      } else if (v is List) {
        v.forEach(collect);
      }
    }

    for (final o in _ops) {
      collect(o.row);
      collect(o.params);
      collect(o.matchValue);
      collect(o.increments);
    }
    for (final id in old) {
      if (referred.contains(id)) continue;
      _results.remove(id);
      _resultTimes.remove(id);
    }
  }

  /// A value that stands for [field] of what op [opId] returns from the
  /// server (`'.'` = the whole result), filled in when a later change is
  /// sent. E.g. an expense's details refer to the id of its journal entry,
  /// which only the server assigns.
  static String ref(String opId, [String field = 'id']) => '@@op:$opId:$field';

  static final _refPattern = RegExp(r'^@@op:([^:]+):(.+)$');

  /// The op a [ref] refers to (null when [value] is no reference).
  static String? refOp(Object? value) => value is String ? _refPattern.firstMatch(value)?.group(1) : null;

  /// [value] with every [ref] replaced by the server's value, where known.
  Object? resolve(Object? value) {
    if (value is String) {
      final m = _refPattern.firstMatch(value);
      if (m == null || !_results.containsKey(m.group(1))) return value;
      final result = _results[m.group(1)];
      final field = m.group(2)!;
      if (field == '.') return result;
      return result is Map ? result[field] : value;
    }
    if (value is Map) return value.map((k, v) => MapEntry(k, resolve(v)));
    if (value is List) return value.map(resolve).toList();
    return value;
  }

  /// Records what the server returned for [id] (see [ref]).
  void recordResult(String id, Object? result) {
    _results[id] = result;
    _resultTimes[id] = DateTime.now();
  }

  /// The store signed in now (null: none); only its changes are sent.
  String? get store => _store;

  /// The store signed in has changed (null: signed out). Changes queued
  /// by earlier versions (no store on them) are taken to be this store's.
  Future<void> setStore(String? storeId) async {
    _store = storeId;
    _heldIds = null;
    if (storeId != null && _loading != null) {
      await load();
      if (_adopt(storeId)) await _save();
    }
    _changes.add(null);
  }

  bool _adopt(String storeId) {
    var changed = false;
    for (var i = 0; i < _ops.length; i++) {
      if (_ops[i].storeId == null) {
        _ops[i] = _ops[i].copyWith(storeId: storeId);
        changed = true;
      }
    }
    return changed;
  }

  bool _isCurrent(OutboxOp o) => o.storeId == null || o.storeId == _store;

  /// Ids a change adds (or stands for) that later changes can refer to.
  static Set<String> _idsOf(OutboxOp o) {
    final row = o.kind == OutboxKind.update ? null : o.row;
    final key = o.kind == OutboxKind.insert ? o.matchColumn : null;
    return {
      o.id,
      if (row?['id'] is String) row!['id'] as String,
      if (key != null && row?[key] is String) row![key] as String,
    };
  }

  /// Whether [o] refers to one of [ids], directly or through a [ref].
  static bool _refersTo(OutboxOp o, Set<String> ids) {
    bool mentions(Object? v) {
      if (v is String) {
        if (ids.contains(v)) return true;
        final m = _refPattern.firstMatch(v);
        return m != null && ids.contains(m.group(1));
      }
      if (v is Map) return v.values.any(mentions);
      if (v is List) return v.any(mentions);
      return false;
    }

    if (o.kind == OutboxKind.insert) {
      // Its own id is no reference; the rest of the row may be.
      final row = o.row;
      if (row != null && row.entries.any((e) => e.key != 'id' && mentions(e.value))) return true;
    } else if (mentions(o.row)) {
      return true;
    }
    return mentions(o.params) || mentions(o.matchValue) || mentions(o.increments);
  }

  Set<String> get _held => _heldIds ??= () {
        final stuck = <String>{};
        final held = <String>{};
        for (final o in _ops) {
          if (!_isCurrent(o)) continue;
          if (o.failed) {
            stuck.addAll(_idsOf(o));
          } else if (stuck.isNotEmpty && _refersTo(o, stuck)) {
            held.add(o.id);
            stuck.addAll(_idsOf(o));
          }
        }
        return held;
      }();

  /// Everything still waiting, failed ones and other stores' included,
  /// oldest first.
  List<OutboxOp> get ops => List.unmodifiable(_ops);

  /// This store's changes waiting to be sent (not refused, not held back).
  List<OutboxOp> get pending => _ops.where((o) => !o.failed && _isCurrent(o) && !_held.contains(o.id)).toList();

  /// This store's changes the server refused.
  List<OutboxOp> get failed => _ops.where((o) => o.failed && _isCurrent(o)).toList();

  /// This store's changes held back because they build on a refused one.
  List<OutboxOp> get held => _ops.where((o) => !o.failed && _isCurrent(o) && _held.contains(o.id)).toList();

  /// Changes made under another store, waiting for it to sign in again.
  List<OutboxOp> get otherStores => _ops.where((o) => !_isCurrent(o)).toList();

  bool get hasPending => _ops.any((o) => !o.failed && _isCurrent(o) && !_held.contains(o.id));

  /// The changes after [id] that build on it (directly or through each
  /// other), oldest first.
  List<OutboxOp> dependentsOf(String id) {
    final i = _ops.indexWhere((o) => o.id == id);
    if (i < 0) return const [];
    final stuck = _idsOf(_ops[i]);
    final result = <OutboxOp>[];
    for (final o in _ops.skip(i + 1)) {
      if (!_isCurrent(o) || !_refersTo(o, stuck)) continue;
      result.add(o);
      stuck.addAll(_idsOf(o));
    }
    return result;
  }

  /// Whether a new change [op] builds on one the server refused (or one
  /// held back behind it): such a change waits with them instead of being
  /// sent.
  bool buildsOnRefused(OutboxOp op) {
    final stuck = <String>{
      for (final o in _ops)
        if (_isCurrent(o) && (o.failed || _held.contains(o.id))) ..._idsOf(o),
    };
    return stuck.isNotEmpty && _refersTo(op, stuck);
  }

  Future<void> add(OutboxOp op) async {
    await load();
    _ops.add(op.storeId == null && _store != null ? op.copyWith(storeId: _store) : op);
    await _save();
    _changes.add(null);
  }

  /// The server has it.
  Future<void> done(String id) async {
    final i = _ops.indexWhere((o) => o.id == id);
    if (i < 0) return;
    final op = _ops.removeAt(i);
    final now = DateTime.now();
    _settling
      ..removeWhere((s) => now.difference(s.$2) > _settle)
      ..add((op, now));
    await _save();
    _changes.add(null);
  }

  Future<void> replace(OutboxOp op) async {
    final i = _ops.indexWhere((o) => o.id == op.id);
    if (i < 0) return;
    _ops[i] = op;
    await _save();
    _changes.add(null);
  }

  /// Sends this store's refused changes again (e.g. after fixing what
  /// blocked them); those held back behind them go with them.
  Future<void> retryFailed() async {
    for (var i = 0; i < _ops.length; i++) {
      if (_ops[i].failed && _isCurrent(_ops[i])) _ops[i] = _ops[i].copyWith(failed: false);
    }
    await _save();
    _changes.add(null);
  }

  /// Drops refused change [id] for good, with the changes that build on
  /// it ([dependentsOf]) — they could never be applied without it.
  Future<void> discard(String id) async {
    final i = _ops.indexWhere((o) => o.id == id);
    if (i < 0 || !_ops[i].failed) return;
    final gone = {id, for (final o in dependentsOf(id)) o.id};
    _ops.removeWhere((o) => gone.contains(o.id));
    for (final g in gone) {
      _results.remove(g);
      _resultTimes.remove(g);
    }
    await _save();
    _changes.add(null);
  }

  /// Whether an earlier send of [o] may already have run on the server and
  /// data fetched at [asOf] (null: unknown, e.g. a copy kept on the device)
  /// would then already include it.
  static bool _mayBeIn(OutboxOp o, DateTime? asOf) =>
      (o.kind == OutboxKind.rpc || o.kind == OutboxKind.checkout) &&
      o.attemptedAt != null &&
      asOf != null &&
      asOf.isAfter(o.attemptedAt!);

  /// The changes whose effect on stock is still to be added to stock
  /// figures fetched at [asOf] (null: an older copy): this store's
  /// changes not yet sent, and those sent in the last few seconds when the
  /// figures are from before they were sent (the server's new figures may
  /// not have arrived yet).
  List<OutboxOp> stockChanges({DateTime? asOf}) {
    final now = DateTime.now();
    return [
      for (final s in _settling)
        if (now.difference(s.$2) < _stockSettle && (asOf == null || asOf.isBefore(s.$2))) s.$1,
      for (final o in pending)
        if (!_mayBeIn(o, asOf)) o,
    ];
  }

  /// [rows] as the server last sent them (at [asOf], when known), with
  /// this device's own unsent changes to [table] laid over: added rows
  /// that match [where] are included (newest first), changed rows show
  /// their new values.
  List<Map<String, dynamic>> applyTo(
    String table,
    List<Map<String, dynamic>> rows, {
    bool Function(Map<String, dynamic> row)? where,
    DateTime? asOf,
  }) {
    final now = DateTime.now();
    _settling.removeWhere((s) => now.difference(s.$2) > _settle);
    // A function that may already have run (its reply was lost) is left
    // out once the rows are newer than that send: they include it if it ran.
    // (A sale is recognised by its client id instead.)
    final waiting = [
      for (final o in pending)
        if (o.kind != OutboxKind.rpc || !_mayBeIn(o, asOf)) o,
    ];
    final ops = [
      // A function's preview row is replaced by a row with the server's own
      // id, so it isn't kept once sent.
      for (final s in _settling)
        if (s.$1.kind != OutboxKind.rpc && _isCurrent(s.$1)) s.$1,
      ...waiting,
    ].where((o) => o.table == table);
    // Only for changes not yet sent: once sent, the server's rows include them.
    final increments = [
      for (final o in waiting)
        for (final inc in o.increments)
          if (inc['table'] == table && inc['id'] != null) inc,
    ];
    if (ops.isEmpty && increments.isEmpty) return rows;

    final result = [for (final r in rows) Map<String, dynamic>.of(r)];
    final ids = {for (final r in result) r['id']};
    // A sale made offline gets its server id when it arrives; it is
    // recognised by the id the till gave it.
    final clientIds = {
      for (final r in result)
        if (r['client_sale_id'] != null) r['client_sale_id']
    };
    final added = <Map<String, dynamic>>[];
    for (final op in ops) {
      switch (op.kind) {
        case OutboxKind.insert || OutboxKind.checkout || OutboxKind.rpc:
          if (op.row == null) continue;
          // References to results already back from the server are filled in.
          final row = (resolve(op.row) as Map).cast<String, dynamic>();
          if (op.kind == OutboxKind.checkout) {
            // Resuming a held sale closes it.
            final released = row['_releases'];
            if (released != null) {
              for (final r in [...result, ...added]) {
                if (r['id'] == released) r['status'] = 'voided';
              }
            }
          }
          final key = op.kind == OutboxKind.insert ? (op.matchColumn ?? 'id') : 'id';
          if (result.any((r) => r[key] == row[key]) ||
              added.any((r) => r[key] == row[key]) ||
              clientIds.contains(row['client_sale_id'] ?? '\u0000')) {
            continue;
          }
          if (where != null && !where(row)) continue;
          ids.add(row['id']);
          added.insert(0, Map<String, dynamic>.of(row));
        case OutboxKind.update:
          final match = resolve(op.matchValue);
          for (final r in [...result, ...added]) {
            if (r[op.matchColumn] == match) r.addAll((resolve(op.row) as Map).cast<String, dynamic>());
          }
      }
    }
    for (final inc in increments) {
      final incId = resolve(inc['id']);
      for (final r in [...result, ...added]) {
        if (r['id'] != incId) continue;
        final set = inc['set'];
        if (set is Map) {
          r.addAll((resolve(set) as Map).cast<String, dynamic>());
          continue;
        }
        final column = inc['column'] as String;
        r[column] = ((r[column] as num?) ?? 0) + (inc['by'] as num);
      }
    }
    final merged = [...added, ...result];
    return where == null ? merged : merged.where(where).toList();
  }
}
