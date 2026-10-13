import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/utils/id_generator.dart';
import '../domain/pos_models.dart';
import '../domain/pos_repository.dart';

class DriftPosRepository implements PosRepository {
  DriftPosRepository(this._db);

  final AppDatabase _db;

  SaleLineRecord _mapLine(SaleLine row) => SaleLineRecord(
        id: row.id,
        saleId: row.saleId,
        productId: row.productId,
        quantity: row.quantity,
        unitPriceMinorUnits: row.unitPriceMinorUnits,
        discountAmountMinorUnits: row.discountAmountMinorUnits,
        taxAmountMinorUnits: row.taxAmountMinorUnits,
        lineTotalMinorUnits: row.lineTotalMinorUnits,
        costPriceSnapshotMinorUnits: row.costPriceSnapshotMinorUnits,
        quantityReturned: row.quantityReturned,
      );

  SaleRecord _mapSale(Sale row, List<SaleLineRecord> lines) => SaleRecord(
        id: row.id,
        storeId: row.storeId,
        branchId: row.branchId,
        saleNumber: row.saleNumber,
        status: SaleStatus.values.firstWhere((s) => s.name == row.status),
        customerId: row.customerId,
        holdLabel: row.holdLabel,
        subtotalMinorUnits: row.subtotalMinorUnits,
        discountTotalMinorUnits: row.discountTotalMinorUnits,
        taxTotalMinorUnits: row.taxTotalMinorUnits,
        grandTotalMinorUnits: row.grandTotalMinorUnits,
        paymentMethod:
            row.paymentMethod == null ? null : SalePaymentMethod.values.firstWhere((p) => p.name == row.paymentMethod),
        amountTenderedMinorUnits: row.amountTenderedMinorUnits,
        changeGivenMinorUnits: row.changeGivenMinorUnits,
        shiftId: row.shiftId,
        cashierId: row.cashierId,
        journalEntryId: row.journalEntryId,
        createdAt: row.createdAt,
        completedAt: row.completedAt,
        lines: lines,
      );

  Future<String> _nextSaleNumber(String storeId) async {
    final countExp = _db.sales.id.count();
    final query = _db.selectOnly(_db.sales)
      ..addColumns([countExp])
      ..where(_db.sales.storeId.equals(storeId));
    final result = await query.getSingle();
    final count = result.read(countExp) ?? 0;
    return 'S-${(count + 1).toString().padLeft(6, '0')}';
  }

  @override
  Future<SaleRecord> createSale({
    required String storeId,
    required String branchId,
    required String cashierId,
    String? shiftId,
    String? customerId,
    String? holdLabel,
    required SaleStatus status,
    required List<SaleLineInput> lines,
  }) async {
    final saleId = IdGenerator.newId();
    final saleNumber = await _nextSaleNumber(storeId);
    final now = DateTime.now();

    final subtotal = lines.fold<int>(0, (s, l) => s + l.unitPriceMinorUnits * l.quantity);
    final discountTotal = lines.fold<int>(0, (s, l) => s + l.discountAmountMinorUnits);
    final taxTotal = lines.fold<int>(0, (s, l) => s + l.taxAmountMinorUnits);
    final grandTotal = subtotal - discountTotal + taxTotal;

    final mappedLines = <SaleLineRecord>[];

    await _db.transaction(() async {
      await _db.into(_db.sales).insert(
            SalesCompanion.insert(
              id: saleId,
              storeId: storeId,
              branchId: branchId,
              saleNumber: saleNumber,
              status: status.name,
              customerId: Value(customerId),
              holdLabel: Value(holdLabel),
              subtotalMinorUnits: Value(subtotal),
              discountTotalMinorUnits: Value(discountTotal),
              taxTotalMinorUnits: Value(taxTotal),
              grandTotalMinorUnits: Value(grandTotal),
              shiftId: Value(shiftId),
              cashierId: cashierId,
              createdAt: now,
            ),
          );

      for (final line in lines) {
        final lineId = IdGenerator.newId();
        await _db.into(_db.saleLines).insert(
              SaleLinesCompanion.insert(
                id: lineId,
                saleId: saleId,
                productId: line.productId,
                quantity: line.quantity,
                unitPriceMinorUnits: line.unitPriceMinorUnits,
                discountAmountMinorUnits: Value(line.discountAmountMinorUnits),
                taxAmountMinorUnits: Value(line.taxAmountMinorUnits),
                lineTotalMinorUnits: line.lineTotalMinorUnits,
                costPriceSnapshotMinorUnits: Value(line.costPriceSnapshotMinorUnits),
              ),
            );
        mappedLines.add(
          SaleLineRecord(
            id: lineId,
            saleId: saleId,
            productId: line.productId,
            quantity: line.quantity,
            unitPriceMinorUnits: line.unitPriceMinorUnits,
            discountAmountMinorUnits: line.discountAmountMinorUnits,
            taxAmountMinorUnits: line.taxAmountMinorUnits,
            lineTotalMinorUnits: line.lineTotalMinorUnits,
            costPriceSnapshotMinorUnits: line.costPriceSnapshotMinorUnits,
          ),
        );
      }
    });

    return SaleRecord(
      id: saleId,
      storeId: storeId,
      branchId: branchId,
      saleNumber: saleNumber,
      status: status,
      customerId: customerId,
      holdLabel: holdLabel,
      subtotalMinorUnits: subtotal,
      discountTotalMinorUnits: discountTotal,
      taxTotalMinorUnits: taxTotal,
      grandTotalMinorUnits: grandTotal,
      shiftId: shiftId,
      cashierId: cashierId,
      createdAt: now,
      lines: mappedLines,
    );
  }

  @override
  Future<void> completeSale({
    required String saleId,
    required SalePaymentMethod paymentMethod,
    int? amountTenderedMinorUnits,
    int? changeGivenMinorUnits,
    String? journalEntryId,
  }) async {
    await (_db.update(_db.sales)..where((t) => t.id.equals(saleId))).write(
      SalesCompanion(
        status: const Value('completed'),
        paymentMethod: Value(paymentMethod.name),
        amountTenderedMinorUnits: Value(amountTenderedMinorUnits),
        changeGivenMinorUnits: Value(changeGivenMinorUnits),
        journalEntryId: Value(journalEntryId),
        completedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<SaleRecord?> getSale(String saleId) async {
    final row = await (_db.select(_db.sales)..where((t) => t.id.equals(saleId))).getSingleOrNull();
    if (row == null) return null;
    final lines = await (_db.select(_db.saleLines)..where((t) => t.saleId.equals(saleId))).get();
    return _mapSale(row, lines.map(_mapLine).toList());
  }

  @override
  Future<SaleRecord> reholdSale({
    required String saleId,
    required List<SaleLineInput> lines,
    String? customerId,
    String? holdLabel,
  }) async {
    if (lines.isEmpty) throw ArgumentError('a sale needs at least one line');
    final subtotal = lines.fold<int>(0, (s, l) => s + l.unitPriceMinorUnits * l.quantity);
    final discountTotal = lines.fold<int>(0, (s, l) => s + l.discountAmountMinorUnits);
    final taxTotal = lines.fold<int>(0, (s, l) => s + l.taxAmountMinorUnits);
    await _db.transaction(() async {
      final sale = await (_db.select(_db.sales)..where((t) => t.id.equals(saleId))).getSingleOrNull();
      if (sale == null || sale.status != SaleStatus.held.name) throw StateError('held sale not found');
      await (_db.delete(_db.saleLines)..where((t) => t.saleId.equals(saleId))).go();
      for (final line in lines) {
        await _db.into(_db.saleLines).insert(
              SaleLinesCompanion.insert(
                id: IdGenerator.newId(),
                saleId: saleId,
                productId: line.productId,
                quantity: line.quantity,
                unitPriceMinorUnits: line.unitPriceMinorUnits,
                discountAmountMinorUnits: Value(line.discountAmountMinorUnits),
                taxAmountMinorUnits: Value(line.taxAmountMinorUnits),
                lineTotalMinorUnits: line.lineTotalMinorUnits,
                costPriceSnapshotMinorUnits: Value(line.costPriceSnapshotMinorUnits),
              ),
            );
      }
      await (_db.update(_db.sales)..where((t) => t.id.equals(saleId))).write(
        SalesCompanion(
          customerId: Value(customerId),
          holdLabel: Value(holdLabel),
          subtotalMinorUnits: Value(subtotal),
          discountTotalMinorUnits: Value(discountTotal),
          taxTotalMinorUnits: Value(taxTotal),
          grandTotalMinorUnits: Value(subtotal - discountTotal + taxTotal),
        ),
      );
    });
    return (await getSale(saleId))!;
  }

  @override
  Future<SaleRecord?> findSaleByNumber(String storeId, String number) async {
    final row = await (_db.select(_db.sales)
          ..where(
            (t) =>
                t.storeId.equals(storeId) &
                t.saleNumber.equals(normalizeSaleNumber(number)) &
                t.status.equals('voided').not(),
          )
          ..limit(1))
        .getSingleOrNull();
    if (row == null) return null;
    return getSale(row.id);
  }

  @override
  Stream<List<SaleRecord>> watchHeldSales(String storeId, String branchId) {
    final query = _db.select(_db.sales)
      ..where((t) => t.storeId.equals(storeId) & t.branchId.equals(branchId) & t.status.equals('held'))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return query.watch().asyncMap((rows) async {
      final result = <SaleRecord>[];
      for (final row in rows) {
        final lines = await (_db.select(_db.saleLines)..where((t) => t.saleId.equals(row.id))).get();
        result.add(_mapSale(row, lines.map(_mapLine).toList()));
      }
      return result;
    });
  }

  @override
  Future<Map<String, int>> salesTotalsByCustomer(String storeId) async {
    final rows = await _db.customSelect(
      'SELECT s.customer_id AS customer_id, SUM(s.grand_total_minor_units - COALESCE(('
      '  SELECT SUM((l.line_total_minor_units / l.quantity) * l.quantity_returned) FROM sale_lines l '
      '  WHERE l.sale_id = s.id AND l.quantity > 0), 0)) AS total FROM sales s '
      "WHERE s.store_id = ? AND s.status IN ('completed', 'partiallyRefunded', 'refunded') "
      'AND s.customer_id IS NOT NULL GROUP BY s.customer_id',
      variables: [Variable.withString(storeId)],
      readsFrom: {_db.sales, _db.saleLines},
    ).get();
    return {for (final r in rows) r.read<String>('customer_id'): r.read<int>('total')};
  }

  @override
  Stream<List<SaleRecord>> watchCompletedSales(String storeId, {DateTime? from, DateTime? to}) {
    final query = _db.select(_db.sales)..where((t) => t.storeId.equals(storeId) & t.status.isIn(soldStatuses));
    if (from != null) query.where((t) => t.completedAt.isBiggerOrEqualValue(from));
    if (to != null) query.where((t) => t.completedAt.isSmallerOrEqualValue(to));
    query.orderBy([(t) => OrderingTerm.desc(t.completedAt)]);
    return query.watch().asyncMap((rows) async {
      final result = <SaleRecord>[];
      for (final row in rows) {
        final lines = await (_db.select(_db.saleLines)..where((t) => t.saleId.equals(row.id))).get();
        result.add(_mapSale(row, lines.map(_mapLine).toList()));
      }
      return result;
    });
  }

  @override
  Future<void> voidSale(String saleId) async {
    await (_db.update(
      _db.sales,
    )..where((t) => t.id.equals(saleId)))
        .write(const SalesCompanion(status: Value('voided')));
  }

  @override
  Future<String> createSaleReturn({
    required String storeId,
    required String branchId,
    required String originalSaleId,
    required String refundMethod,
    required String processedByUserId,
    required List<MapEntry<String, int>> saleLineIdToQuantity,
  }) async {
    final returnId = IdGenerator.newId();
    await _db.transaction(() async {
      await _db.into(_db.saleReturns).insert(
            SaleReturnsCompanion.insert(
              id: returnId,
              storeId: storeId,
              branchId: branchId,
              originalSaleId: originalSaleId,
              refundMethod: refundMethod,
              processedByUserId: processedByUserId,
              createdAt: DateTime.now(),
            ),
          );
      for (final entry in saleLineIdToQuantity) {
        final line = await (_db.select(_db.saleLines)..where((t) => t.id.equals(entry.key))).getSingle();
        if (entry.value > line.quantity - line.quantityReturned) {
          throw StateError('return exceeds remaining quantity');
        }
        await (_db.update(_db.saleLines)..where((t) => t.id.equals(line.id))).write(
          SaleLinesCompanion(quantityReturned: Value(line.quantityReturned + entry.value)),
        );
        final unitRefund = line.quantity == 0 ? 0 : (line.lineTotalMinorUnits ~/ line.quantity) * entry.value;
        await _db.into(_db.saleReturnLines).insert(
              SaleReturnLinesCompanion.insert(
                id: IdGenerator.newId(),
                saleReturnId: returnId,
                saleLineId: entry.key,
                quantityReturned: entry.value,
                refundAmountMinorUnits: unitRefund,
              ),
            );
      }
      final lines = await (_db.select(_db.saleLines)..where((t) => t.saleId.equals(originalSaleId))).get();
      final fullyReturned = lines.every((l) => l.quantityReturned >= l.quantity);
      await (_db.update(_db.sales)..where((t) => t.id.equals(originalSaleId))).write(
        SalesCompanion(status: Value(fullyReturned ? 'refunded' : 'partiallyRefunded')),
      );
    });
    return returnId;
  }
}
