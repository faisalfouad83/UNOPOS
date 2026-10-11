import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unopos/core/offline/offline_cache.dart';
import 'package:unopos/features/pos/data/offline_sale_queue.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('queued sales survive a reload and can be removed', () async {
    final queue = OfflineSaleQueue();
    await queue.add(QueuedSale(clientSaleId: 'a', params: const {'p_branch_id': 'b1'}, queuedAt: DateTime(2026)));
    await queue.add(QueuedSale(clientSaleId: 'b', params: const {'p_branch_id': 'b1'}, queuedAt: DateTime(2026)));

    final reloaded = await OfflineSaleQueue().all();
    expect(reloaded.map((s) => s.clientSaleId), ['a', 'b']);
    expect(reloaded.first.params['p_branch_id'], 'b1');

    await queue.remove('a');
    expect((await queue.all()).map((s) => s.clientSaleId), ['b']);
  });

  test('network failures are told apart from server rejections', () {
    expect(isNetworkError(const SocketException('Failed host lookup')), isTrue);
    expect(isNetworkError(TimeoutException('slow')), isTrue);
    expect(isNetworkError(Exception('Insufficient stock')), isFalse);
  });

  test('resilientRows keeps the last data when the connection drops', () async {
    final live = StreamController<List<Map<String, dynamic>>>();
    final values = <List<Map<String, dynamic>>>[];
    final errors = <Object>[];
    final sub = resilientRows('t', () => live.stream, retryDelay: const Duration(hours: 1))
        .listen(values.add, onError: errors.add);

    await Future<void>.delayed(Duration.zero);
    live.add([
      {'id': '1'}
    ]);
    await Future<void>.delayed(Duration.zero);
    live.addError(const SocketException('offline'));
    await Future<void>.delayed(Duration.zero);

    expect(values.single.single['id'], '1');
    expect(errors, isEmpty);
    expect(await OfflineCache.readRows('t'), [
      {'id': '1'}
    ]);
    await sub.cancel();
  });

  test('resilientRows serves the cached copy first when starting offline', () async {
    await OfflineCache.write('t2', [
      {'id': 'cached'}
    ]);
    final first = await resilientRows('t2', () => Stream.error(const SocketException('offline'))).first;
    expect(first.single['id'], 'cached');
  });
}
