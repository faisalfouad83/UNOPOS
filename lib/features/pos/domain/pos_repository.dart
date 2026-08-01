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

  Stream<List<SaleRecord>> watchHeldSales(String storeId, String branchId);

  Stream<List<SaleRecord>> watchCompletedSales(String storeId, {DateTime? from, DateTime? to});

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
