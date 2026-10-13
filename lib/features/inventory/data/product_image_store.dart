import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_client_provider.dart';
import '../../../core/supabase/supabase_config.dart';

/// Where product photos are kept. On the shared backend: a private Storage
/// bucket, one folder per store (only that store can read or change it),
/// with a copy cached on the device so photos still show offline. On the
/// local build: files in the app's own folder. A product's `imagePath` is
/// the storage path (or the local file path).
class ProductImageStore {
  ProductImageStore(this._client);

  static const bucket = 'product-images';

  final SupabaseClient? _client;

  Future<Directory> _dir(String name) async {
    final dir = Directory(p.join((await getApplicationSupportDirectory()).path, name));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<File> _cacheFile(String path) async =>
      File(p.join((await _dir('product_image_cache')).path, '${sha1.convert(path.codeUnits)}.png'));

  /// Saves [png] as [productId]'s photo and returns its path. A new name
  /// every time, so a changed photo never shows a stale cached copy.
  Future<String> save({required String storeId, required String productId, required Uint8List png}) async {
    final name = '$productId-${DateTime.now().millisecondsSinceEpoch}.png';
    final client = _client;
    if (client == null) {
      final file = File(p.join((await _dir('product_images')).path, name));
      await file.writeAsBytes(png, flush: true);
      return file.path;
    }
    final path = '$storeId/$name';
    await client.storage.from(bucket).uploadBinary(
          path,
          png,
          fileOptions: const FileOptions(contentType: 'image/png', upsert: true),
        );
    await (await _cacheFile(path)).writeAsBytes(png, flush: true);
    return path;
  }

  /// The photo's bytes, from the device cache when possible. Null if it
  /// can't be found (e.g. offline and never downloaded on this device).
  Future<Uint8List?> load(String path) async {
    final client = _client;
    if (client == null) {
      final file = File(path);
      return await file.exists() ? file.readAsBytes() : null;
    }
    final cache = await _cacheFile(path);
    if (await cache.exists()) return cache.readAsBytes();
    try {
      final bytes = await client.storage.from(bucket).download(path);
      await cache.writeAsBytes(bytes, flush: true);
      return bytes;
    } catch (_) {
      return null;
    }
  }

  /// Removes a photo no product uses any more. Best effort: a leftover
  /// file is harmless, a failed delete must not fail the product edit.
  Future<void> remove(String path) async {
    try {
      final client = _client;
      if (client == null) {
        final file = File(path);
        if (await file.exists()) await file.delete();
        return;
      }
      await client.storage.from(bucket).remove([path]);
      final cache = await _cacheFile(path);
      if (await cache.exists()) await cache.delete();
    } catch (_) {}
  }
}

final productImageStoreProvider = Provider<ProductImageStore>((ref) {
  return ProductImageStore(kUseSupabaseBackend ? ref.watch(supabaseClientProvider) : null);
});

/// A product photo's bytes, kept in memory once loaded.
final productImageProvider = FutureProvider.family<Uint8List?, String>((ref, path) {
  return ref.watch(productImageStoreProvider).load(path);
});
