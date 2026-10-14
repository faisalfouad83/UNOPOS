import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unopos/core/offline/offline_cache.dart';
import 'package:unopos/core/offline/offline_pins.dart';
import 'package:unopos/core/offline/offline_warmup.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    OfflineCache.resetMemory();
  });

  test('an account that signed in online can sign in offline, with that PIN only', () async {
    expect(await OfflinePins.matches('e1', '1234'), isFalse);
    await OfflinePins.remember('e1', '1234');
    expect(await OfflinePins.matches('e1', '1234'), isTrue);
    expect(await OfflinePins.matches('e1', '9999'), isFalse);
    expect(await OfflinePins.matches('e2', '1234'), isFalse);
    // Only a hash is kept, never the PIN.
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('offline_pin.e1'), isNot(contains('1234')));
  });

  test('the device copy drops fields that must not be stored', () async {
    final live = StreamController<List<Map<String, dynamic>>>();
    final stream = resilientRows(
      'employees.s',
      () => live.stream,
      cacheRow: (r) => {'id': r['id'], 'name': r['name']},
    );
    final first = stream.first;
    live.add([
      {'id': 'e1', 'name': 'Ali', 'salary_minor_units': 900000, 'phone': '0770'},
    ]);
    expect((await first).single['salary_minor_units'], 900000); // the app still gets it live
    await Future<void>.delayed(const Duration(milliseconds: 20));
    final cached = await OfflineCache.readRows('employees.s');
    expect(cached!.single.keys, unorderedEquals(['id', 'name']));
    await live.close();
  });

  test('offline, the last copy is used; online, a fresh copy replaces it', () async {
    final online = await fetchRowsOrCached(
        'branches.s',
        () async => [
              {'id': 'b1'},
            ]);
    expect(online!.single['id'], 'b1');
    final offline = await fetchRowsOrCached('branches.s', () async => throw const SocketExceptionLike());
    expect(offline!.single['id'], 'b1');
  });

  test('warming waits for the live value after the device copy', () async {
    final c = StreamController<int>();
    var finished = false;
    final f = liveValue(c.stream).then((_) => finished = true);
    c.add(1); // cached copy
    await Future<void>.delayed(Duration.zero);
    expect(finished, isFalse);
    c.add(2); // live
    await f;
    expect(finished, isTrue);
    await c.close();
  });
}

/// Looks like a dropped connection to isNetworkError.
class SocketExceptionLike implements Exception {
  const SocketExceptionLike();
  @override
  String toString() => 'SocketException: Network is unreachable';
}
