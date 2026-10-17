/// One product as the price checker keeps it on the device: only what a
/// customer-facing price lookup needs (no cost price, no stock).
class PriceProduct {
  const PriceProduct({
    required this.id,
    required this.name,
    required this.sku,
    required this.sellPriceMinorUnits,
    this.barcode,
    this.wholesalePriceMinorUnits,
    this.unit = 'pcs',
    this.imagePath,
    this.categoryId,
    this.categoryName,
  });

  final String id;
  final String name;
  final String sku;
  final String? barcode;
  final int sellPriceMinorUnits;

  /// Null when the product has no wholesale price.
  final int? wholesalePriceMinorUnits;
  final String unit;

  /// The product photo's storage path (or local file path on the local
  /// build), as kept on the product.
  final String? imagePath;
  final String? categoryId;
  final String? categoryName;

  /// What the footer shows under "Serial Number": the barcode, or the SKU
  /// when the product has no barcode.
  String get serial => (barcode != null && barcode!.trim().isNotEmpty) ? barcode!.trim() : sku;

  /// Whether [serial] is the barcode (false: the SKU).
  bool get serialIsBarcode => barcode != null && barcode!.trim().isNotEmpty;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'sku': sku,
        'barcode': barcode,
        'sell': sellPriceMinorUnits,
        'wholesale': wholesalePriceMinorUnits,
        'unit': unit,
        'image': imagePath,
        'category_id': categoryId,
        'category': categoryName,
      };

  /// Reads a product written by [toJson]; throws [FormatException] when a
  /// required field is missing or of the wrong type.
  static PriceProduct fromJson(Object? raw) {
    if (raw is! Map) throw const FormatException('product is not an object');
    String? str(String k) {
      final v = raw[k];
      if (v == null) return null;
      if (v is! String) throw FormatException('product.$k is not text');
      return v;
    }

    int? integer(String k) {
      final v = raw[k];
      if (v == null) return null;
      if (v is int) return v;
      if (v is num && v == v.roundToDouble()) return v.toInt();
      throw FormatException('product.$k is not a whole number');
    }

    final id = str('id');
    final name = str('name');
    final sell = integer('sell');
    if (id == null || name == null || sell == null) throw const FormatException('product is incomplete');
    return PriceProduct(
      id: id,
      name: name,
      sku: str('sku') ?? '',
      barcode: str('barcode'),
      sellPriceMinorUnits: sell,
      wholesalePriceMinorUnits: integer('wholesale'),
      unit: str('unit') ?? 'pcs',
      imagePath: str('image'),
      categoryId: str('category_id'),
      categoryName: str('category'),
    );
  }
}

/// A complete, self-describing copy of a store's active products, saved on
/// the device as one file. A new snapshot replaces the previous one only
/// as a whole and only once it has been checked ([validate]).
class PriceSnapshot {
  const PriceSnapshot({
    required this.storeId,
    required this.snapshotId,
    required this.version,
    required this.createdAt,
    required this.products,
  });

  /// Bumped if the file layout ever changes; older layouts are ignored.
  static const int format = 1;

  final String storeId;

  /// Unique per download.
  final String snapshotId;

  /// Counts up by one with each snapshot saved on this device for the store.
  final int version;
  final DateTime createdAt;
  final List<PriceProduct> products;

  int get productCount => products.length;

  Map<String, dynamic> toJson() => {
        'format': format,
        'store_id': storeId,
        'snapshot_id': snapshotId,
        'version': version,
        'created_at': createdAt.toUtc().toIso8601String(),
        'product_count': products.length,
        'products': [for (final p in products) p.toJson()],
      };

  /// Reads a snapshot written by [toJson] and checks it ([validate]).
  /// Throws [FormatException] if it is damaged, of another layout, or
  /// belongs to a store other than [expectedStoreId].
  static PriceSnapshot fromJson(Object? raw, {required String expectedStoreId}) {
    if (raw is! Map) throw const FormatException('snapshot is not an object');
    if (raw['format'] != format) throw const FormatException('unknown snapshot format');
    final storeId = raw['store_id'];
    final snapshotId = raw['snapshot_id'];
    final version = raw['version'];
    final createdAt = raw['created_at'] is String ? DateTime.tryParse(raw['created_at'] as String) : null;
    final list = raw['products'];
    if (storeId is! String || snapshotId is! String || version is! int || createdAt == null || list is! List) {
      throw const FormatException('snapshot header is incomplete');
    }
    final snapshot = PriceSnapshot(
      storeId: storeId,
      snapshotId: snapshotId,
      version: version,
      createdAt: createdAt.toLocal(),
      products: [for (final p in list) PriceProduct.fromJson(p)],
    );
    if (raw['product_count'] != snapshot.products.length) {
      throw const FormatException('snapshot is truncated');
    }
    snapshot.validate(expectedStoreId: expectedStoreId);
    return snapshot;
  }

  /// Throws [FormatException] unless this snapshot is safe to show:
  /// belongs to [expectedStoreId], has an id, and every product has an id
  /// (no repeats), a name and a price that is not negative.
  void validate({required String expectedStoreId}) {
    if (storeId != expectedStoreId) throw const FormatException('snapshot belongs to another store');
    if (snapshotId.isEmpty || version < 1) throw const FormatException('snapshot has no id');
    final ids = <String>{};
    for (final p in products) {
      if (p.id.isEmpty || !ids.add(p.id)) throw const FormatException('product id missing or repeated');
      if (p.name.trim().isEmpty) throw const FormatException('product without a name');
      if (p.sellPriceMinorUnits < 0 || (p.wholesalePriceMinorUnits ?? 0) < 0) {
        throw const FormatException('negative price');
      }
    }
  }
}

/// How the last synchronization attempt ended.
enum PriceSyncResult { never, success, failed }

/// Notes kept next to the snapshot: when it was last refreshed, and how
/// the last attempt went (kept even when the attempt failed and the
/// snapshot itself was left alone).
class PriceSnapshotMeta {
  const PriceSnapshotMeta({
    required this.storeId,
    this.snapshotId,
    this.version = 0,
    this.createdAt,
    this.lastSuccessfulSync,
    this.lastAttempt,
    this.productCount = 0,
    this.lastResult = PriceSyncResult.never,
    this.lastError,
  });

  final String storeId;
  final String? snapshotId;
  final int version;
  final DateTime? createdAt;
  final DateTime? lastSuccessfulSync;
  final DateTime? lastAttempt;
  final int productCount;
  final PriceSyncResult lastResult;

  /// A short technical reason for the last failure (never shown raw to a
  /// customer; for staff and support).
  final String? lastError;

  PriceSnapshotMeta copyWith({
    String? snapshotId,
    int? version,
    DateTime? createdAt,
    DateTime? lastSuccessfulSync,
    DateTime? lastAttempt,
    int? productCount,
    PriceSyncResult? lastResult,
    String? lastError,
    bool clearError = false,
  }) =>
      PriceSnapshotMeta(
        storeId: storeId,
        snapshotId: snapshotId ?? this.snapshotId,
        version: version ?? this.version,
        createdAt: createdAt ?? this.createdAt,
        lastSuccessfulSync: lastSuccessfulSync ?? this.lastSuccessfulSync,
        lastAttempt: lastAttempt ?? this.lastAttempt,
        productCount: productCount ?? this.productCount,
        lastResult: lastResult ?? this.lastResult,
        lastError: clearError ? null : (lastError ?? this.lastError),
      );

  Map<String, dynamic> toJson() => {
        'store_id': storeId,
        'snapshot_id': snapshotId,
        'version': version,
        'created_at': createdAt?.toUtc().toIso8601String(),
        'last_successful_sync': lastSuccessfulSync?.toUtc().toIso8601String(),
        'last_attempt': lastAttempt?.toUtc().toIso8601String(),
        'product_count': productCount,
        'last_result': lastResult.name,
        'last_error': lastError,
      };

  static PriceSnapshotMeta fromJson(Map<String, dynamic> raw, {required String storeId}) {
    DateTime? date(String k) => raw[k] is String ? DateTime.tryParse(raw[k] as String)?.toLocal() : null;
    return PriceSnapshotMeta(
      storeId: storeId,
      snapshotId: raw['snapshot_id'] as String?,
      version: raw['version'] is int ? raw['version'] as int : 0,
      createdAt: date('created_at'),
      lastSuccessfulSync: date('last_successful_sync'),
      lastAttempt: date('last_attempt'),
      productCount: raw['product_count'] is int ? raw['product_count'] as int : 0,
      lastResult:
          PriceSyncResult.values.where((r) => r.name == raw['last_result']).firstOrNull ?? PriceSyncResult.never,
      lastError: raw['last_error'] as String?,
    );
  }
}

/// What a lookup found.
sealed class PriceLookup {
  const PriceLookup();
}

/// Exactly one product matches.
class PriceFound extends PriceLookup {
  const PriceFound(this.product);
  final PriceProduct product;
}

/// Several products match (e.g. two share a barcode, or a name search):
/// the customer picks one — never a silently chosen price.
class PriceChoices extends PriceLookup {
  const PriceChoices(this.products, {this.exact = false});
  final List<PriceProduct> products;

  /// True when they all match the code exactly (a duplicate barcode/SKU).
  final bool exact;
}

class PriceNotFound extends PriceLookup {
  const PriceNotFound(this.query);
  final String query;
}

/// A fast in-memory index of a snapshot's products by barcode, SKU and
/// name, built once per snapshot.
class PriceIndex {
  PriceIndex(List<PriceProduct> products) : _products = List.unmodifiable(products) {
    for (final p in _products) {
      final barcode = _code(p.barcode);
      if (barcode.isNotEmpty) _byBarcode.putIfAbsent(barcode, () => []).add(p);
      final sku = _code(p.sku);
      if (sku.isNotEmpty) _bySku.putIfAbsent(sku, () => []).add(p);
      _haystack.add('${p.name.toLowerCase()}\u0000$barcode\u0000$sku');
    }
  }

  static const int maxChoices = 50;

  final List<PriceProduct> _products;
  final _byBarcode = <String, List<PriceProduct>>{};
  final _bySku = <String, List<PriceProduct>>{};
  final _haystack = <String>[];

  int get length => _products.length;

  static String _code(String? s) => (s ?? '').trim().toLowerCase();

  /// Products whose barcode or SKU is exactly [code] (case and surrounding
  /// spaces ignored), barcode matches first, each product once.
  List<PriceProduct> exact(String code) {
    final key = _code(code);
    if (key.isEmpty) return const [];
    final seen = <String>{};
    return [
      for (final p in [...?_byBarcode[key], ...?_bySku[key]])
        if (seen.add(p.id)) p,
    ];
  }

  /// Products whose name, barcode or SKU contains [query], at most
  /// [maxChoices].
  List<PriceProduct> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    final out = <PriceProduct>[];
    for (var i = 0; i < _products.length && out.length < maxChoices; i++) {
      if (_haystack[i].contains(q)) out.add(_products[i]);
    }
    return out;
  }

  /// A scanned or typed code: one exact match shows the product; several
  /// exact matches, or only partial matches, become a choice list.
  PriceLookup lookup(String query) {
    final exactMatches = exact(query);
    if (exactMatches.length == 1) return PriceFound(exactMatches.single);
    if (exactMatches.length > 1) return PriceChoices(exactMatches, exact: true);
    final partial = search(query);
    if (partial.isEmpty) return PriceNotFound(query.trim());
    return PriceChoices(partial);
  }
}
