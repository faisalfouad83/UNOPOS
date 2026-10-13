import 'pos_models.dart';

abstract class PosRepository {
  /// Creates a sale row with status=held (or completed, if lines/payment are
  /// supplied up front) and its line items in one transaction. Returns the
  /// full record including a store-unique, human-readable sale number.
  Future<SaleRecord> createSale({
    required String storeId,
    required String branchId,
    required String cashierId,
    String? shiftId,
    String? customerId,
    String? holdLabel,
    required SaleStatus status,
    required List<SaleLineInput> lines,
  });

  Future<void> completeSale({
    required String saleId,
    required SalePaymentMethod paymentMethod,
    int? amountTenderedMinorUnits,
    int? changeGivenMinorUnits,
    String? journalEntryId,
  });

  Future<SaleRecord?> getSale(String saleId);

  /// Replaces what a held sale holds with [lines], keeping its number and
  /// its place in the held list. Returns the held sale as it is now.
  Future<SaleRecord> reholdSale({
    required String saleId,
    required List<SaleLineInput> lines,
    String? customerId,
    String? holdLabel,
  });

  /// Looks an invoice up by the number printed on its receipt. Accepts the
  /// full number ("S-000123") or just its digits ("123").
  Future<SaleRecord?> findSaleByNumber(String storeId, String number);

  Stream<List<SaleRecord>> watchHeldSales(String storeId, String branchId);

  Stream<List<SaleRecord>> watchCompletedSales(String storeId, {DateTime? from, DateTime? to});

  /// Total completed sales per customer, net of returns (customer id →
  /// minor units).
  Future<Map<String, int>> salesTotalsByCustomer(String storeId);

  Future<void> voidSale(String saleId);

  Future<String> createSaleReturn({
    required String storeId,
    required String branchId,
    required String originalSaleId,
    required String refundMethod,
    required String processedByUserId,
    required List<MapEntry<String, int>> saleLineIdToQuantity,
  });
}

/// "123", "s-123" and "S-000123" all mean invoice S-000123.
String normalizeSaleNumber(String input) {
  final trimmed = input.trim().toUpperCase();
  final digits = RegExp(r'\d+').firstMatch(trimmed)?.group(0);
  if (digits == null) return trimmed;
  return 'S-${int.parse(digits).toString().padLeft(6, '0')}';
}

/// Sale statuses that count as sales (returns are netted out per line).
const soldStatuses = ['completed', 'partiallyRefunded', 'refunded'];

/// A sale line as the checkout / hold RPCs take it.
Map<String, dynamic> saleLineJson(SaleLineInput l) => {
      'product_id': l.productId,
      'quantity': l.quantity,
      'unit_price_minor_units': l.unitPriceMinorUnits,
      'discount_amount_minor_units': l.discountAmountMinorUnits,
      'tax_amount_minor_units': l.taxAmountMinorUnits,
      'cost_price_snapshot_minor_units': l.costPriceSnapshotMinorUnits,
    };
