import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

/// Last-known copies of the shared-backend data the till needs to keep
/// selling when the internet drops (products, tax rates, settings, the open
/// shift). Stored as the raw JSON rows the backend returned, so any
/// repository can cache what it reads without a per-type serializer.
class OfflineCache {
  OfflineCache._();

  static const String _prefix = 'offline_cache.';

  static Future<void> write(String key, Object? rows) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_prefix$key', jsonEncode(rows));
  }

  static Future<Object?> read(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_prefix$key');
    return raw == null ? null : jsonDecode(raw);
  }

  static Future<List<Map<String, dynamic>>?> readRows(String key) async {
    final value = await read(key);
    if (value is! List) return null;
    return value.cast<Map<String, dynamic>>();
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

/// Wraps a backend stream of rows so the till keeps working offline:
/// the last cached copy is shown immediately, every live update refreshes
/// the cache, and a dropped connection keeps showing the last data while it
/// quietly resubscribes, instead of surfacing an error screen. With
/// [cache] off nothing is stored on the device (rows with personal data);
/// the stream still resubscribes after a dropped connection.
Stream<List<Map<String, dynamic>>> resilientRows(
  String cacheKey,
  Stream<List<Map<String, dynamic>>> Function() subscribe, {
  Duration retryDelay = const Duration(seconds: 10),
  bool cache = true,
}) {
  late StreamController<List<Map<String, dynamic>>> controller;
  StreamSubscription<List<Map<String, dynamic>>>? subscription;
  Timer? retry;
  var hasValue = false;
  var cancelled = false;

  void listen() {
    if (cancelled) return;
    subscription = subscribe().listen(
      (rows) {
        hasValue = true;
        controller.add(rows);
        if (cache) OfflineCache.write(cacheKey, rows);
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
      final cached = cache ? await OfflineCache.readRows(cacheKey) : null;
      if (cached != null && !hasValue && !cancelled) {
        hasValue = true;
        controller.add(cached);
      }
      listen();
    },
    onCancel: () async {
      cancelled = true;
      retry?.cancel();
      await subscription?.cancel();
    },
  );
  return controller.stream;
}
