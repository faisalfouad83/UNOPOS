import '../../accounting/domain/accounting_posting_service.dart';
import '../../debts/domain/debts_repository.dart';
import '../../inventory/domain/inventory_models.dart';
import '../../inventory/domain/inventory_repository.dart';
import 'pos_models.dart';
import 'pos_repository.dart';

class ReturnLineInput {
  const ReturnLineInput({required this.saleLine, required this.quantityReturned});
  final SaleLineRecord saleLine;
  final int quantityReturned;
}

/// Mirrors [CompleteSaleUseCase] for the opposite direction: processing a
/// return restocks inventory, posts the reversing accounting entry, and (for
/// a pay-later sale) shrinks the customer's outstanding debt instead of
/// leaving a stale balance.
class ProcessSaleReturnUseCase {
  ProcessSaleReturnUseCase({
    required PosRepository posRepository,
    required InventoryRepository inventoryRepository,
    required AccountingPostingService accountingPostingService,
    required DebtsRepository debtsRepository,
  })  : _posRepository = posRepository,
        _inventoryRepository = inventoryRepository,
        _accountingPostingService = accountingPostingService,
        _debtsRepository = debtsRepository;

  final PosRepository _posRepository;
  final InventoryRepository _inventoryRepository;
  final AccountingPostingService _accountingPostingService;
  final DebtsRepository _debtsRepository;

  Future<void> processReturn({
    required SaleRecord originalSale,
    required List<ReturnLineInput> returnLines,
    required String processedByUserId,
    required bool refundToCash,
  }) async {
    final lines = returnLines.where((l) => l.quantityReturned > 0).toList();
    if (lines.isEmpty) return;

    final returnId = await _posRepository.createSaleReturn(
      storeId: originalSale.storeId,
      branchId: originalSale.branchId,
      originalSaleId: originalSale.id,
      refundMethod: refundToCash ? 'cash' : 'card',
      processedByUserId: processedByUserId,
      saleLineIdToQuantity: lines.map((l) => MapEntry(l.saleLine.id, l.quantityReturned)).toList(),
    );

    var refundMinorUnits = 0;
    var restockedCogsMinorUnits = 0;
    for (final line in lines) {
      final unitTotal = line.saleLine.quantity == 0 ? 0 : line.saleLine.lineTotalMinorUnits ~/ line.saleLine.quantity;
      refundMinorUnits += unitTotal * line.quantityReturned;
      restockedCogsMinorUnits += line.saleLine.costPriceSnapshotMinorUnits * line.quantityReturned;

      await _inventoryRepository.recordStockMovement(
        storeId: originalSale.storeId,
        productId: line.saleLine.productId,
        branchId: originalSale.branchId,
        type: StockMovementType.returnIn,
        quantity: line.quantityReturned,
        referenceType: 'SALE_RETURN',
        referenceId: returnId,
        createdByUserId: processedByUserId,
      );
    }

    final wasPayLater = originalSale.paymentMethod == SalePaymentMethod.payLater;

    await _accountingPostingService.postSaleReturn(
      storeId: originalSale.storeId,
      branchId: originalSale.branchId,
      saleReturnId: returnId,
      createdByUserId: processedByUserId,
      refundMinorUnits: refundMinorUnits,
      restockedCogsMinorUnits: restockedCogsMinorUnits,
      refundToCash: refundToCash,
      wasPayLater: wasPayLater,
    );

    if (wasPayLater) {
      final debtEntry = await _debtsRepository.findBySaleId(originalSale.id);
      if (debtEntry != null) {
        await _debtsRepository.reduceOriginalAmount(debtEntry.id, refundMinorUnits);
      }
    }
  }
}
