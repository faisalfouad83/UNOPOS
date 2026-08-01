import 'package:flutter_test/flutter_test.dart';
import 'package:unopos/core/security/passcode_hasher.dart';

void main() {
  group('PasscodeHasher', () {
    test('verifies a correct PIN against its hash', () {
      final hash = PasscodeHasher.hash('4821');
      expect(PasscodeHasher.verify('4821', hash), isTrue);
    });

    test('rejects an incorrect PIN', () {
      final hash = PasscodeHasher.hash('4821');
      expect(PasscodeHasher.verify('0000', hash), isFalse);
    });

    test('never stores the PIN in plain text', () {
      final hash = PasscodeHasher.hash('1234');
      expect(hash, isNot(contains('1234')));
    });

    test('does not crash on a malformed stored hash', () {
      expect(PasscodeHasher.verify('1234', 'not-a-real-bcrypt-hash'), isFalse);
    });
  });
}
