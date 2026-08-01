import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import 'app_secrets.dart';

enum LicenseTier {
  trial1Month(days: 30),
  months3(days: 90),
  months6(days: 182),
  months12(days: 365),
  lifetime(days: null);

  const LicenseTier({required this.days});

  /// Null means no expiry (lifetime).
  final int? days;

  static LicenseTier fromIndex(int i) => LicenseTier.values[i];
}

class ActivationPayload {
  ActivationPayload({
    required this.tier,
    required this.issuedAt,
    required this.expiresAt,
    required this.storeNameRef,
    required this.nonce,
  });

  final LicenseTier tier;
  final DateTime issuedAt;

  /// Null for [LicenseTier.lifetime].
  final DateTime? expiresAt;
  final String storeNameRef;
  final int nonce;

  bool get isLifetime => expiresAt == null;

  int? daysRemaining([DateTime? now]) {
    if (expiresAt == null) return null;
    final today = now ?? DateTime.now();
    return expiresAt!.difference(today).inDays;
  }

  bool isExpired([DateTime? now]) {
    if (expiresAt == null) return false;
    final today = now ?? DateTime.now();
    return !today.isBefore(expiresAt!);
  }
}

class ActivationCodeException implements Exception {
  ActivationCodeException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Encodes/signs/verifies UNOPOS activation codes so they can be validated
/// fully offline. Format: `UNPS-<payload-hex>-<signature-hex>`.
///
/// Hex was chosen over Crockford base32 for implementation reliability (no
/// custom alphabet/decoder to get subtly wrong) while still avoiding the
/// classic manual-entry ambiguities (0/O, 1/I don't both appear in hex).
class ActivationCodeCodec {
  const ActivationCodeCodec._();

  static const String _prefix = 'UNPS';

  /// Truncated HMAC (first 8 bytes / 64 bits) — enough to stop casual
  /// tampering while keeping the printed/typed code short. See the
  /// disclosed limitation in [AppSecrets].
  static const int _signatureBytes = 8;

  static const int _epochDayZero = 0; // days since 1970-01-01
  static const int _lifetimeSentinel = 0xFFFFFFFF;

  static String generate({
    required LicenseTier tier,
    required String storeNameRef,
    DateTime? issuedAt,
  }) {
    final issued = issuedAt ?? DateTime.now();
    final expires = tier.days == null ? null : issued.add(Duration(days: tier.days!));
    final nonce = Random.secure().nextInt(0xFFFFFFFF);

    final payloadBytes = _encodePayload(
      tier: tier,
      issuedAt: issued,
      expiresAt: expires,
      storeNameRef: storeNameRef,
      nonce: nonce,
    );
    final signature = _sign(payloadBytes);

    return '$_prefix-${_bytesToHex(payloadBytes)}-${_bytesToHex(signature)}';
  }

  /// Throws [ActivationCodeException] with a user-facing reason if the code
  /// is malformed or its signature does not match. Does NOT check expiry —
  /// callers should check [ActivationPayload.isExpired] separately so an
  /// expired-but-authentic code can be distinguished from a forged one.
  static ActivationPayload verifyAndDecode(String rawCode) {
    final code = rawCode.trim().toUpperCase();
    final parts = code.split('-');
    if (parts.length != 3 || parts[0] != _prefix) {
      throw ActivationCodeException('Malformed activation code');
    }

    final Uint8List payloadBytes;
    final Uint8List signatureBytes;
    try {
      payloadBytes = _hexToBytes(parts[1]);
      signatureBytes = _hexToBytes(parts[2]);
    } on FormatException {
      throw ActivationCodeException('Malformed activation code');
    }

    final expectedSignature = _sign(payloadBytes);
    if (!_constantTimeEquals(signatureBytes, expectedSignature)) {
      throw ActivationCodeException('Invalid or tampered activation code');
    }

    return _decodePayload(payloadBytes);
  }

  static Uint8List _sign(Uint8List payload) {
    final hmac = Hmac(sha256, utf8.encode(AppSecrets.activationHmacKey));
    final digest = hmac.convert(payload).bytes;
    return Uint8List.fromList(digest.sublist(0, _signatureBytes));
  }

  static Uint8List _encodePayload({
    required LicenseTier tier,
    required DateTime issuedAt,
    required DateTime? expiresAt,
    required String storeNameRef,
    required int nonce,
  }) {
    final nameBytes = utf8.encode(storeNameRef.length > 200 ? storeNameRef.substring(0, 200) : storeNameRef);
    final builder = BytesBuilder();
    builder.addByte(1); // format version
    builder.addByte(tier.index);
    builder.add(_uint32(_daysSinceEpoch(issuedAt)));
    builder.add(_uint32(expiresAt == null ? _lifetimeSentinel : _daysSinceEpoch(expiresAt)));
    builder.add(_uint32(nonce));
    builder.addByte(nameBytes.length);
    builder.add(nameBytes);
    return builder.toBytes();
  }

  static ActivationPayload _decodePayload(Uint8List bytes) {
    if (bytes.length < 14) {
      throw ActivationCodeException('Malformed activation code');
    }
    final version = bytes[0];
    if (version != 1) {
      throw ActivationCodeException('Unsupported activation code version');
    }
    final tierIndex = bytes[1];
    if (tierIndex < 0 || tierIndex >= LicenseTier.values.length) {
      throw ActivationCodeException('Malformed activation code');
    }
    final tier = LicenseTier.fromIndex(tierIndex);
    final issuedDay = _readUint32(bytes, 2);
    final expiresDay = _readUint32(bytes, 6);
    final nameLen = bytes[14];
    if (bytes.length < 15 + nameLen) {
      throw ActivationCodeException('Malformed activation code');
    }
    final storeNameRef = utf8.decode(bytes.sublist(15, 15 + nameLen));

    return ActivationPayload(
      tier: tier,
      issuedAt: _epochDayToDate(issuedDay),
      expiresAt: expiresDay == _lifetimeSentinel ? null : _epochDayToDate(expiresDay),
      storeNameRef: storeNameRef,
      nonce: _readUint32(bytes, 10),
    );
  }

  static int _daysSinceEpoch(DateTime date) {
    final utcDate = DateTime.utc(date.year, date.month, date.day);
    return utcDate.difference(DateTime.utc(1970, 1, 1)).inDays + _epochDayZero;
  }

  static DateTime _epochDayToDate(int days) {
    return DateTime.utc(1970, 1, 1).add(Duration(days: days));
  }

  static Uint8List _uint32(int value) {
    final bytes = Uint8List(4);
    final bd = ByteData.sublistView(bytes);
    bd.setUint32(0, value, Endian.big);
    return bytes;
  }

  static int _readUint32(Uint8List bytes, int offset) {
    return ByteData.sublistView(bytes, offset, offset + 4).getUint32(0, Endian.big);
  }

  static String _bytesToHex(Uint8List bytes) {
    final buffer = StringBuffer();
    for (final b in bytes) {
      buffer.write(b.toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString().toUpperCase();
  }

  static Uint8List _hexToBytes(String hex) {
    if (hex.length.isOdd) throw const FormatException('Odd length hex string');
    final result = Uint8List(hex.length ~/ 2);
    for (var i = 0; i < result.length; i++) {
      result[i] = int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16);
    }
    return result;
  }

  static bool _constantTimeEquals(Uint8List a, Uint8List b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }
}
