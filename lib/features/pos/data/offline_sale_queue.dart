import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// A checkout made while the till was offline, waiting to be sent to the
/// server. [params] are the exact `checkout_sale_once` arguments, so a
/// replay is byte-for-byte the request that couldn't go through.
class QueuedSale {
  const QueuedSale({required this.clientSaleId, required this.params, required this.queuedAt, this.lastError});

  final String clientSaleId;
  final Map<String, dynamic> params;
  final DateTime queuedAt;
  final String? lastError;

  Map<String, dynamic> toJson() => {
        'clientSaleId': clientSaleId,
        'params': params,
        'queuedAt': queuedAt.toIso8601String(),
        'lastError': lastError,
      };

  factory QueuedSale.fromJson(Map<String, dynamic> json) => QueuedSale(
        clientSaleId: json['clientSaleId'] as String,
        params: (json['params'] as Map).cast<String, dynamic>(),
        queuedAt: DateTime.parse(json['queuedAt'] as String).toLocal(),
        lastError: json['lastError'] as String?,
      );

  QueuedSale withError(String error) =>
      QueuedSale(clientSaleId: clientSaleId, params: params, queuedAt: queuedAt, lastError: error);
}

/// Device-local, persistent list of [QueuedSale]s (survives app restarts).
class OfflineSaleQueue {
  static const String _key = 'offline_sale_queue.v1';

  Future<List<QueuedSale>> all() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return const [];
    return (jsonDecode(raw) as List).cast<Map<String, dynamic>>().map(QueuedSale.fromJson).toList();
  }

  Future<void> _save(List<QueuedSale> sales) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(sales.map((s) => s.toJson()).toList()));
  }

  Future<void> add(QueuedSale sale) async => _save([...await all(), sale]);

  Future<void> remove(String clientSaleId) async =>
      _save((await all()).where((s) => s.clientSaleId != clientSaleId).toList());

  Future<void> replace(QueuedSale sale) async =>
      _save((await all()).map((s) => s.clientSaleId == sale.clientSaleId ? sale : s).toList());
}
