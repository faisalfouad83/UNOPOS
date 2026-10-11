import 'inventory_models.dart';

enum ExpiryStatus { none, ok, soon, expired }

/// How close [product] is to its best-before date. "Soon" means within
/// [warnDays] days (inclusive); the expiry day itself still counts as soon.
ExpiryStatus expiryStatusOf(ProductRecord product, {DateTime? now, int warnDays = 30}) {
  final expiry = product.expiryDate;
  if (expiry == null) return ExpiryStatus.none;
  final days = daysUntilExpiry(product, now: now)!;
  if (days < 0) return ExpiryStatus.expired;
  if (days <= warnDays) return ExpiryStatus.soon;
  return ExpiryStatus.ok;
}

/// Whole days from today to the expiry date (negative once expired).
int? daysUntilExpiry(ProductRecord product, {DateTime? now}) {
  final expiry = product.expiryDate;
  if (expiry == null) return null;
  final today = now ?? DateTime.now();
  final a = DateTime.utc(today.year, today.month, today.day);
  final b = DateTime.utc(expiry.year, expiry.month, expiry.day);
  return b.difference(a).inDays;
}

/// Products that are expired or expire within [warnDays], soonest first.
List<ProductRecord> productsNearExpiry(Iterable<ProductRecord> products, {DateTime? now, int warnDays = 30}) {
  final list = products.where((p) {
    final s = expiryStatusOf(p, now: now, warnDays: warnDays);
    return s == ExpiryStatus.soon || s == ExpiryStatus.expired;
  }).toList()
    ..sort((a, b) => a.expiryDate!.compareTo(b.expiryDate!));
  return list;
}
