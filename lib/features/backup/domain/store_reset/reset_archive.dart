import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

/// The backup file written before a store reset: one JSON document with a
/// manifest and the data.
///
/// ```
/// {
///   "manifest": {format, format_version, schema_version, store_id,
///                reset_id, scopes, exported_at, counts: {table: rows},
///                device_ops, data_sha256},
///   "data":     {"tables": {table: [rows]}, "device": {...}}
/// }
/// ```
///
/// `data_sha256` is the SHA-256 of `data` as written (JSON, UTF-8), so a
/// copy can be checked after it is read back. `device` holds this device's
/// changes not yet sent ("outbox") and its sync details: they are not on
/// the server, so the backup is the only other place they exist.
class ResetArchive {
  const ResetArchive._();

  static const String format = 'unopos_store_reset_backup';
  static const int formatVersion = 1;

  /// The last database migration the app was built for.
  static const String schemaVersion = '0029';

  /// The file for [tables] (each table's rows) and [device].
  static ResetArchiveFile build({
    required String storeId,
    required String resetId,
    required List<String> scopes,
    required Map<String, List<Map<String, dynamic>>> tables,
    required Map<String, dynamic> device,
    required DateTime exportedAt,
  }) {
    final data = {'tables': tables, 'device': device};
    final dataJson = jsonEncode(data);
    final hash = sha256.convert(utf8.encode(dataJson)).toString();
    final counts = {for (final e in tables.entries) e.key: e.value.length};
    final deviceOps = (device['outbox'] as List?)?.length ?? 0;
    final manifest = {
      'format': format,
      'format_version': formatVersion,
      'schema_version': schemaVersion,
      'store_id': storeId,
      'reset_id': resetId,
      'scopes': scopes,
      'exported_at': exportedAt.toUtc().toIso8601String(),
      'counts': counts,
      'device_ops': deviceOps,
      'data_sha256': hash,
    };
    final text = '{"manifest":${jsonEncode(manifest)},"data":$dataJson}';
    return ResetArchiveFile(
      bytes: Uint8List.fromList(utf8.encode(text)),
      sha256: hash,
      counts: counts,
      deviceOps: deviceOps,
    );
  }

  /// Checks [bytes] read back from where the file was saved against what
  /// was written ([expected]): it parses, is this format and store, every
  /// table has the rows it should, and the data's hash matches. Throws
  /// [ResetArchiveInvalid] saying what is wrong.
  static void verify(Uint8List bytes, ResetArchiveFile expected, {required String storeId}) {
    final Map<String, dynamic> doc;
    try {
      doc = (jsonDecode(utf8.decode(bytes)) as Map).cast<String, dynamic>();
    } catch (_) {
      throw const ResetArchiveInvalid('unreadable');
    }
    final manifest = (doc['manifest'] as Map?)?.cast<String, dynamic>();
    final data = (doc['data'] as Map?)?.cast<String, dynamic>();
    if (manifest == null || data == null) throw const ResetArchiveInvalid('incomplete');
    if (manifest['format'] != format || manifest['format_version'] != formatVersion) {
      throw const ResetArchiveInvalid('format');
    }
    if (manifest['store_id'] != storeId) throw const ResetArchiveInvalid('store');
    final hash = sha256.convert(utf8.encode(jsonEncode(data))).toString();
    if (hash != manifest['data_sha256'] || hash != expected.sha256) throw const ResetArchiveInvalid('hash');
    final tables = (data['tables'] as Map?)?.cast<String, dynamic>() ?? const {};
    final counts = (manifest['counts'] as Map?)?.cast<String, dynamic>() ?? const {};
    for (final e in expected.counts.entries) {
      final rows = tables[e.key];
      if (rows is! List || rows.length != e.value || counts[e.key] != e.value) {
        throw ResetArchiveInvalid('count:${e.key}');
      }
    }
  }
}

/// A backup file ready to save, and what it should read back as.
class ResetArchiveFile {
  const ResetArchiveFile({required this.bytes, required this.sha256, required this.counts, required this.deviceOps});

  final Uint8List bytes;
  final String sha256;

  /// Rows per table.
  final Map<String, int> counts;

  /// Unsent changes from this device included.
  final int deviceOps;
}

/// The saved backup doesn't read back as written.
class ResetArchiveInvalid implements Exception {
  const ResetArchiveInvalid(this.reason);
  final String reason;

  @override
  String toString() => 'The backup file did not check out ($reason).';
}
