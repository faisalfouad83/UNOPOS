import 'package:flutter_test/flutter_test.dart';
import 'package:unopos/core/security/activation_code_codec.dart';

void main() {
  group('ActivationCodeCodec', () {
    test('round-trips a generated code', () {
      final code = ActivationCodeCodec.generate(tier: LicenseTier.months6, storeNameRef: 'Test Supermarket');
      final payload = ActivationCodeCodec.verifyAndDecode(code);

      expect(payload.storeNameRef, 'Test Supermarket');
      expect(payload.tier, LicenseTier.months6);
      expect(payload.isLifetime, isFalse);
      expect(payload.expiresAt, isNotNull);
    });

    test('lifetime tier has no expiry', () {
      final code = ActivationCodeCodec.generate(tier: LicenseTier.lifetime, storeNameRef: 'Forever Mart');
      final payload = ActivationCodeCodec.verifyAndDecode(code);

      expect(payload.isLifetime, isTrue);
      expect(payload.expiresAt, isNull);
      expect(payload.isExpired(), isFalse);
    });

    test('expiry is computed correctly for a 1-month trial', () {
      final issued = DateTime.utc(2026, 1, 1);
      final code = ActivationCodeCodec.generate(tier: LicenseTier.trial1Month, storeNameRef: 'Trial Store', issuedAt: issued);
      final payload = ActivationCodeCodec.verifyAndDecode(code);

      expect(payload.isExpired(DateTime.utc(2026, 1, 15)), isFalse);
      expect(payload.isExpired(DateTime.utc(2026, 2, 5)), isTrue);
    });

    test('rejects a tampered code (flipped character in payload)', () {
      final code = ActivationCodeCodec.generate(tier: LicenseTier.months3, storeNameRef: 'Tamper Test');
      final parts = code.split('-');
      final payloadHex = parts[1];
      // Flip the first hex character to something different.
      final flippedChar = payloadHex[0] == 'A' ? 'B' : 'A';
      final tamperedPayload = flippedChar + payloadHex.substring(1);
      final tamperedCode = '${parts[0]}-$tamperedPayload-${parts[2]}';

      expect(() => ActivationCodeCodec.verifyAndDecode(tamperedCode), throwsA(isA<ActivationCodeException>()));
    });

    test('rejects a malformed code', () {
      expect(() => ActivationCodeCodec.verifyAndDecode('not-a-real-code'), throwsA(isA<ActivationCodeException>()));
      expect(() => ActivationCodeCodec.verifyAndDecode(''), throwsA(isA<ActivationCodeException>()));
    });

    test('rejects a code with a mismatched signature from another code', () {
      final codeA = ActivationCodeCodec.generate(tier: LicenseTier.months12, storeNameRef: 'Store A');
      final codeB = ActivationCodeCodec.generate(tier: LicenseTier.months12, storeNameRef: 'Store B');
      final payloadA = codeA.split('-')[1];
      final signatureB = codeB.split('-')[2];
      final mixed = 'UNPS-$payloadA-$signatureB';

      expect(() => ActivationCodeCodec.verifyAndDecode(mixed), throwsA(isA<ActivationCodeException>()));
    });
  });
}
