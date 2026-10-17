import 'dart:async';
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../inventory/data/product_image_store.dart';
import '../../inventory/domain/inventory_repository.dart';
import '../domain/price_snapshot.dart';

/// Where the price checker downloads a store's products from. Every call
/// either returns the complete, current list or throws — never a partial
/// or cached one, so a snapshot made from it is always up to date.
abstract class PriceCatalogSource {
  /// The store's active products, with their category names.
  Future<List<PriceProduct>> fetchActiveProducts(String storeId);

  /// A product photo's bytes; null when it can't be fetched.
  Future<Uint8List?> fetchImage(String imagePath);
}

/// Straight from the shared backend (no offline copies), page by page.
class SupabasePriceCatalogSource implements PriceCatalogSource {
  SupabasePriceCatalogSource(this._client, this._images);

  final SupabaseClient _client;
  final ProductImageStore _images;

  static const int _page = 1000;
  static const Duration _timeout = Duration(seconds: 25);

  @override
  Future<List<PriceProduct>> fetchActiveProducts(String storeId) async {
    final categories = <String, String>{};
    final categoryRows =
        await _client.from('categories').select('id, name, store_id').eq('store_id', storeId).timeout(_timeout);
    for (final row in categoryRows) {
      categories['${row['id']}'] = '${row['name'] ?? ''}';
    }
    final products = <PriceProduct>[];
    for (var from = 0;; from += _page) {
      final rows = await _client
          .from('products')
          .select(
            'id, store_id, name, sku, barcode, sell_price_minor_units, wholesale_price_minor_units, unit, image_path, '
            'category_id, is_active',
          )
          .eq('store_id', storeId)
          .eq('is_active', true)
          .order('id')
          .range(from, from + _page - 1)
          .timeout(_timeout);
      for (final row in rows) {
        // Rows of another store must never reach this store's snapshot.
        if (row['store_id'] != storeId) throw StateError('product of another store');
        if (row['is_active'] == false) continue;
        final categoryId = row['category_id'] as String?;
        products.add(PriceProduct(
          id: row['id'] as String,
          name: (row['name'] as String?) ?? '',
          sku: (row['sku'] as String?) ?? '',
          barcode: row['barcode'] as String?,
          sellPriceMinorUnits: (row['sell_price_minor_units'] as num?)?.toInt() ?? 0,
          wholesalePriceMinorUnits: (row['wholesale_price_minor_units'] as num?)?.toInt(),
          unit: (row['unit'] as String?) ?? 'pcs',
          imagePath: row['image_path'] as String?,
          categoryId: categoryId,
          categoryName: categoryId == null ? null : categories[categoryId],
        ));
      }
      if (rows.length < _page) break;
    }
    return products;
  }

  @override
  Future<Uint8List?> fetchImage(String imagePath) => _images.load(imagePath);
}

/// Through the inventory repository — the local (single-device) build,
/// whose database is always on the device and current.
class RepositoryPriceCatalogSource implements PriceCatalogSource {
  RepositoryPriceCatalogSource(this._repository, this._images);

  final InventoryRepository _repository;
  final ProductImageStore _images;

  @override
  Future<List<PriceProduct>> fetchActiveProducts(String storeId) async {
    final categories = {
      for (final c in await _repository.watchCategories(storeId).first.timeout(const Duration(seconds: 20)))
        c.id: c.name,
    };
    final products = await _repository.watchProducts(storeId).first.timeout(const Duration(seconds: 20));
    return [
      for (final p in products)
        if (p.isActive && p.storeId == storeId)
          PriceProduct(
            id: p.id,
            name: p.name,
            sku: p.sku,
            barcode: p.barcode,
            sellPriceMinorUnits: p.sellPriceMinorUnits,
            wholesalePriceMinorUnits: p.wholesalePriceMinorUnits,
            unit: p.unit,
            imagePath: p.imagePath,
            categoryId: p.categoryId,
            categoryName: p.categoryId == null ? null : categories[p.categoryId],
          ),
    ];
  }

  @override
  Future<Uint8List?> fetchImage(String imagePath) => _images.load(imagePath);
}
