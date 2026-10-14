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
  /// lost silently; it can be retried from the status bar.
  final bool failed;

  /// What a server function will do to existing rows, shown until it has
  /// run: each `{table, id, column, by}` (adds) or `{table, id, set: {..}}`.
  final List<Map<String, dynamic>> increments;

  OutboxOp copyWith({String? lastError, bool? failed}) => OutboxOp(
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
      );
}

/// Every change made on this device that hasn't reached the server yet, in
/// the order it was made, kept on the device (survives restarts). Reads
/// lay these over the server's last data ([applyTo]) so the screen shows
/// the change straight away, online or not.
class Outbox {
  Outbox({Duration settle = const Duration(seconds: 20)}) : _settle = settle;

  /// The app's one outbox (reads lay it over server data without needing
  /// to be handed it).
  static final Outbox shared = Outbox();

  static const String _key = 'outbox.v1';
  static const String _legacySalesKey = 'offline_sale_queue.v1';

  final Duration _settle;
  final _ops = <OutboxOp>[];

  /// What the server returned for changes sent from the queue, by op id,
  /// for later changes that refer to them ([ref]).
  final _results = <String, Object?>{};

  /// Sent a moment ago: still shown until the server's own copy arrives.
  final _settling = <(OutboxOp, DateTime)>[];
  final _changes = StreamController<void>.broadcast();
  Future<void>? _loading;

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
      await _save();
      await prefs.remove(_legacySalesKey);
    }
    _changes.add(null);
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(_ops.map((o) => o.toJson()).toList()));
    // Results only matter while a waiting change may still refer to them.
    if (_ops.isEmpty) _results.clear();
    await prefs.setString('$_key.results', jsonEncode(_results));
  }

  /// A value that stands for [field] of what op [opId] returns from the
  /// server (`'.'` = the whole result), filled in when a later change is
  /// sent. E.g. an expense's details refer to the id of its journal entry,
  /// which only the server assigns.
  static String ref(String opId, [String field = 'id']) => '@@op:$opId:$field';

  static final _refPattern = RegExp(r'^@@op:([^:]+):(.+)$');

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
  void recordResult(String id, Object? result) => _results[id] = result;

  /// Everything still waiting, failed ones included, oldest first.
  List<OutboxOp> get ops => List.unmodifiable(_ops);

  /// Waiting to be sent (not refused).
  List<OutboxOp> get pending => _ops.where((o) => !o.failed).toList();
  List<OutboxOp> get failed => _ops.where((o) => o.failed).toList();
  bool get hasPending => _ops.any((o) => !o.failed);

  Future<void> add(OutboxOp op) async {
    await load();
    _ops.add(op);
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

  /// Sends the refused changes again (e.g. after fixing what blocked them).
  Future<void> retryFailed() async {
    for (var i = 0; i < _ops.length; i++) {
      if (_ops[i].failed) _ops[i] = _ops[i].copyWith(failed: false);
    }
    await _save();
    _changes.add(null);
  }

  /// [rows] as the server last sent them, with this device's own unsent
  /// changes to [table] laid over: added rows that match [where] are
  /// included (newest first), changed rows show their new values.
  List<Map<String, dynamic>> applyTo(
    String table,
    List<Map<String, dynamic>> rows, {
    bool Function(Map<String, dynamic> row)? where,
  }) {
    final now = DateTime.now();
    _settling.removeWhere((s) => now.difference(s.$2) > _settle);
    final ops = [
      // A function's preview row is replaced by a row with the server's own
      // id, so it isn't kept once sent.
      for (final s in _settling)
        if (s.$1.kind != OutboxKind.rpc) s.$1,
      ..._ops.where((o) => !o.failed),
    ].where((o) => o.table == table);
    // Only for changes not yet sent: once sent, the server's rows include them.
    final increments = [
      for (final o in _ops.where((o) => !o.failed))
        for (final inc in o.increments)
          if (inc['table'] == table) inc,
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
          r.addAll(set.cast<String, dynamic>());
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
