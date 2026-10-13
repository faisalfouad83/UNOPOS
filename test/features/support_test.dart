import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unopos/core/constants/magic_passcodes.dart';
import 'package:unopos/core/routing/route_guard.dart';
import 'package:unopos/core/routing/route_paths.dart';
import 'package:unopos/features/auth/domain/session_controller.dart';
import 'package:unopos/features/licensing/presentation/developer_gate.dart';
import 'package:unopos/features/support/domain/support_models.dart';

SupportAgentRecord _agent(
        {String presence = 'online', DateTime? lastSeen, SupportEmployment e = SupportEmployment.active}) =>
    SupportAgentRecord(
      id: 'a',
      fullName: 'Sara',
      email: 's@x',
      reportedPresence: presence,
      lastSeenAt: lastSeen,
      employment: e,
      createdAt: DateTime(2026),
    );

SupportMessageRecord _msg(String id, String client, int minute) => SupportMessageRecord(
      id: id,
      conversationId: 'c',
      fromStore: true,
      senderName: 'Store',
      body: id,
      clientMessageId: client,
      createdAt: DateTime(2026, 1, 1, 10, minute),
    );

void main() {
  group('support presence', () {
    final now = DateTime(2026, 10, 13, 12);
    test('a fresh report is trusted', () {
      expect(_agent(lastSeen: now.subtract(const Duration(seconds: 30))).presence(now), SupportPresence.online);
      expect(_agent(presence: 'break', lastSeen: now).presence(now), SupportPresence.onBreak);
    });
    test('an old "online" is shown as disconnected, not online', () {
      expect(_agent(lastSeen: now.subtract(const Duration(minutes: 10))).presence(now), SupportPresence.disconnected);
      expect(_agent(lastSeen: null).presence(now), SupportPresence.disconnected);
    });
    test('signed out or suspended accounts are not online', () {
      expect(_agent(presence: 'signed_out', lastSeen: now).presence(now), SupportPresence.signedOut);
      expect(_agent(lastSeen: now, e: SupportEmployment.suspended).presence(now), SupportPresence.signedOut);
    });
  });

  test('a message being sent shows once, and disappears into the record when it arrives', () {
    const pending = OutgoingMessage(clientMessageId: 'k2', body: 'two');
    final before = mergeMessages([_msg('one', 'k1', 1)], [pending]);
    expect(before, hasLength(2));
    final after = mergeMessages([_msg('two', 'k2', 2), _msg('one', 'k1', 1)], [pending]);
    expect(after, hasLength(2));
    expect(after.whereType<SupportMessageRecord>().map((m) => m.id), ['one', 'two']);
  });

  test('the support portal is the only place a support employee can go', () {
    String? go(String loc, SessionState s) => RouteGuard.redirect(
          location: loc,
          hasValidLicense: true,
          hasStoreOnDisk: false,
          hasEmployees: false,
          session: s,
        );
    final support = SessionState(supportAgent: _agent(lastSeen: DateTime.now()));
    expect(go(RoutePaths.pos, support), RoutePaths.support);
    expect(go(RoutePaths.support, support), isNull);
    expect(go(RoutePaths.support, const SessionState()), RoutePaths.activation);
  });

  test('1414 is reserved and can never be an employee PIN', () {
    expect(MagicPasscodes.isReserved(MagicPasscodes.supportGate), isTrue);
  });

  testWidgets('the hidden entry opens only after holding, not on a tap', (tester) async {
    var opened = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: HoldToOpen(
            duration: const Duration(seconds: 3),
            onHeld: () => opened++,
            child: const SizedBox(width: 100, height: 100, child: ColoredBox(color: Colors.blue)),
          ),
        ),
      ),
    );
    final center = tester.getCenter(find.byType(ColoredBox));
    // A tap and a 1-second press do nothing.
    await tester.tapAt(center);
    var g = await tester.startGesture(center);
    await tester.pump(const Duration(seconds: 1));
    await g.up();
    await tester.pump(const Duration(seconds: 3));
    expect(opened, 0);
    // Held for 3 seconds: opens once.
    g = await tester.startGesture(center);
    await tester.pump(const Duration(milliseconds: 3200));
    await tester.pump(const Duration(milliseconds: 200));
    await g.up();
    await tester.pump(const Duration(seconds: 1));
    expect(opened, 1);
  });
}
