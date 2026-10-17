import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../domain/price_snapshot.dart';

/// Keeps the price checker's product snapshot on the device, apart from
/// the general offline copies (OfflineCache): one folder per store under
/// the app's support folder, holding
///
/// * `snapshot.json` — the products, replaced only as a whole,
/// * `meta.json` — when it was last refreshed and how the last try went,
/// * `images/` — small copies of the product photos.
///
/// Every file is written to a temporary file first and then renamed over
/// the old one, so a crash or full disk mid-write never leaves a half
/// written snapshot: the previous one stays until the new one is complete
/// and checked. A store only ever reads its own folder.
class PriceSnapshotStore {
  PriceSnapshotStore({Future<Directory> Function()? baseDir}) : _baseDir = baseDir ?? getApplicationSupportDirectory;

  final Future<Directory> Function() _baseDir;

  static String _safe(String storeId) => storeId.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');

  Future<Directory> storeDir(String storeId) async {
    final dir = Directory(p.join((await _baseDir()).path, 'price_checker', _safe(storeId)));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<File> _file(String storeId, String name) async => File(p.join((await storeDir(storeId)).path, name));

  static Future<void> _writeAtomically(File target, List<int> bytes) async {
    final tmp = File('${target.path}.tmp');
    await tmp.writeAsBytes(bytes, flush: true);
    await tmp.rename(target.path);
  }

  /// The saved snapshot for [storeId]; null when there is none yet or the
  /// file can't be read safely (damaged, another store's, older layout).
  Future<PriceSnapshot?> loadSnapshot(String storeId) async {
    try {
      final file = await _file(storeId, 'snapshot.json');
      if (!await file.exists()) return null;
      return PriceSnapshot.fromJson(jsonDecode(await file.readAsString()), expectedStoreId: storeId);
    } catch (_) {
      return null;
    }
  }

  /// Checks [candidate], writes it beside the current snapshot, reads the
  /// written file back and checks it again, and only then puts it in place
  /// of the current one. On any failure the current snapshot is left
  /// exactly as it was and the error is rethrown.
  Future<PriceSnapshot> replaceSnapshot(PriceSnapshot candidate) async {
    candidate.validate(expectedStoreId: candidate.storeId);
    final target = await _file(candidate.storeId, 'snapshot.json');
    final tmp = File('${target.path}.tmp');
    try {
      await tmp.writeAsString(jsonEncode(candidate.toJson()), flush: true);
      final written = PriceSnapshot.fromJson(jsonDecode(await tmp.readAsString()), expectedStoreId: candidate.storeId);
      if (written.snapshotId != candidate.snapshotId || written.productCount != candidate.productCount) {
        throw const FormatException('snapshot changed while being saved');
      }
      await tmp.rename(target.path);
      return written;
    } catch (_) {
      try {
        if (await tmp.exists()) await tmp.delete();
      } catch (_) {}
      rethrow;
    }
  }

  Future<PriceSnapshotMeta> loadMeta(String storeId) async {
    try {
      final file = await _file(storeId, 'meta.json');
      if (!await file.exists()) return PriceSnapshotMeta(storeId: storeId);
      final raw = jsonDecode(await file.readAsString());
      if (raw is! Map<String, dynamic> || raw['store_id'] != storeId) return PriceSnapshotMeta(storeId: storeId);
      return PriceSnapshotMeta.fromJson(raw, storeId: storeId);
    } catch (_) {
      return PriceSnapshotMeta(storeId: storeId);
    }
  }

  Future<void> saveMeta(PriceSnapshotMeta meta) async {
    await _writeAtomically(await _file(meta.storeId, 'meta.json'), utf8.encode(jsonEncode(meta.toJson())));
  }

  Future<Directory> _imagesDir(String storeId) async {
    final dir = Directory(p.join((await storeDir(storeId)).path, 'images'));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// The photo's file name: a new photo always gets a new storage path, so
  /// the same name means the same picture.
  static String imageName(String imagePath) => '${sha1.convert(utf8.encode(imagePath))}.img';

  Future<File> imageFile(String storeId, String imagePath) async =>
      File(p.join((await _imagesDir(storeId)).path, imageName(imagePath)));

  /// The saved copy of [imagePath]'s photo, or null.
  Future<Uint8List?> loadImage(String storeId, String imagePath) async {
    try {
      final file = await imageFile(storeId, imagePath);
      return await file.exists() ? await file.readAsBytes() : null;
    } catch (_) {
      return null;
    }
  }

  Future<bool> hasImage(String storeId, String imagePath) async => (await imageFile(storeId, imagePath)).exists();

  Future<void> saveImage(String storeId, String imagePath, Uint8List bytes) async {
    await _writeAtomically(await imageFile(storeId, imagePath), bytes);
  }

  /// Deletes saved photos no product in the snapshot uses any more.
  Future<void> pruneImages(String storeId, Iterable<String> keepImagePaths) async {
    try {
      final keep = {for (final path in keepImagePaths) imageName(path)};
      await for (final entry in (await _imagesDir(storeId)).list()) {
        if (entry is File && !keep.contains(p.basename(entry.path))) await entry.delete();
      }
    } catch (_) {}
  }
}
