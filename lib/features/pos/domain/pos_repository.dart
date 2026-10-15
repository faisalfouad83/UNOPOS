import 'invoice_query.dart';
import 'pos_models.dart';

/// The held sale a cart was resumed from was already sold or discarded
/// (e.g. on another till) — nothing was charged or held.
class HeldSaleClosedException implements Exception {
  const HeldSaleClosedException();
}

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
  /// Throws [HeldSaleClosedException] when it is no longer held.
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

  /// One page of the store's invoices with their lines and, for pay-later
  /// invoices, the debt they created (what's paid / still owed).
  Future<List<InvoiceRecord>> listInvoices(InvoiceQuery query);

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

/// "123", "s-123" and "S-000123" all mean invoice S-000123. Any other
/// number (a sale made offline, "OFFLINE-3F2A1B", or a held sale numbered
/// offline, "H-…") is matched as it is.
String normalizeSaleNumber(String input) {
  final trimmed = input.trim().toUpperCase();
  final match = RegExp(r'^(?:#|S\s*-?\s*)?(\d+)$').firstMatch(trimmed);
  if (match == null) return trimmed;
  return 'S-${int.parse(match.group(1)!).toString().padLeft(6, '0')}';
}

/// The prefix of a receipt number printed for a sale made offline; what
/// follows is the start of the sale's own id.
const offlineSaleNumberPrefix = 'OFFLINE-';

/// Whether [text] typed in a search box is an invoice number rather than
/// a customer's name: digits, or one of the till's own number prefixes.
bool looksLikeSaleNumber(String text) {
  final t = text.trim().toUpperCase();
  return RegExp(r'\d').hasMatch(t) || t.startsWith(offlineSaleNumberPrefix) || t.startsWith('H-');
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
