import 'package:drift/drift.dart';

/// A sale in any state — including parked/held sales, which just sit here
/// with status=held until resumed. There is deliberately no separate "held
/// sale" table: resuming a hold is just loading these rows back into the cart.
class Sales extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text()();
  TextColumn get branchId => text()();
  TextColumn get saleNumber => text()();
  TextColumn get status => text()(); // held/completed/refunded/partiallyRefunded/voided
  TextColumn get customerId => text().nullable()();
  TextColumn get holdLabel => text().nullable()();
  IntColumn get subtotalMinorUnits => integer().withDefault(const Constant(0))();
  IntColumn get discountTotalMinorUnits => integer().withDefault(const Constant(0))();
  IntColumn get taxTotalMinorUnits => integer().withDefault(const Constant(0))();
  IntColumn get grandTotalMinorUnits => integer().withDefault(const Constant(0))();
  TextColumn get paymentMethod => text().nullable()(); // cash/card/payLater
  IntColumn get amountTenderedMinorUnits => integer().nullable()();
  IntColumn get changeGivenMinorUnits => integer().nullable()();
  TextColumn get shiftId => text().nullable()();
  TextColumn get cashierId => text()();
  TextColumn get journalEntryId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class SaleLines extends Table {
  TextColumn get id => text()();
  TextColumn get saleId => text()();
  TextColumn get productId => text()();
  IntColumn get quantity => integer()();
  IntColumn get unitPriceMinorUnits => integer()();
  IntColumn get discountAmountMinorUnits => integer().withDefault(const Constant(0))();
  IntColumn get taxAmountMinorUnits => integer().withDefault(const Constant(0))();
  IntColumn get lineTotalMinorUnits => integer()();
  IntColumn get costPriceSnapshotMinorUnits => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class SaleReturns extends Table {
  TextColumn get id => text()();
  TextColumn get storeId => text()();
  TextColumn get branchId => text()();
  TextColumn get originalSaleId => text()();
  TextColumn get refundMethod => text()(); // cash/card/storeCredit
  TextColumn get journalEntryId => text().nullable()();
  TextColumn get processedByUserId => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class SaleReturnLines extends Table {
  TextColumn get id => text()();
  TextColumn get saleReturnId => text()();
  TextColumn get saleLineId => text()();
  IntColumn get quantityReturned => integer()();
  IntColumn get refundAmountMinorUnits => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
