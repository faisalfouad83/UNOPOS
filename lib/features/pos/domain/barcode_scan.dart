import '../../inventory/domain/inventory_models.dart';

/// The product a scanned (or typed + Enter) code means, from the store's
/// active products: an exact barcode first, then an exact SKU (ignoring
/// case). Null when nothing matches exactly.
ProductRecord? matchScannedProduct(List<ProductRecord> products, String code) {
  final c = code.trim();
  if (c.isEmpty) return null;
  for (final p in products) {
    if (p.isActive && (p.barcode?.trim() ?? '') == c) return p;
  }
  final lower = c.toLowerCase();
  for (final p in products) {
    if (p.isActive && p.sku.trim().toLowerCase() == lower) return p;
  }
  return null;
}

/// When a typed search narrows the catalog down to a single product,
/// Enter adds it (no exact code needed). Null for zero or several matches.
ProductRecord? singleSearchMatch(List<ProductRecord> products, String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return null;
  ProductRecord? found;
  for (final p in products) {
    if (!p.isActive) continue;
    final hit = p.name.toLowerCase().contains(q) ||
        p.sku.toLowerCase().contains(q) ||
        (p.barcode ?? '').toLowerCase().contains(q);
    if (!hit) continue;
    if (found != null) return null;
    found = p;
  }
  return found;
}

/// Splits what a scanner typed into separate codes. Keyboard-emulating
/// scanners end each code with Enter, but some send Tab, or a CR/LF that
/// lands inside the text (e.g. on Android or when pasted).
List<String> splitScannedCodes(String raw) =>
    raw.split(RegExp(r'[\r\n\t]+')).map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
