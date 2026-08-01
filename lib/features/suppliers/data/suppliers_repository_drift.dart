import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/utils/id_generator.dart';
import '../domain/suppliers_models.dart';
import '../domain/suppliers_repository.dart';

class DriftSuppliersRepository implements SuppliersRepository {
  DriftSuppliersRepository(this._db);

  final AppDatabase _db;

  SupplierRecord _mapSupplier(Supplier row) => SupplierRecord(
        id: row.id,
        storeId: row.storeId,
        name: row.name,
        contactPhone: row.contactPhone,
        contactPerson: row.contactPerson,
        address: row.address,
      );

  SupplierTransactionRecord _mapTx(SupplierTransaction row) => SupplierTransactionRecord(
        id: row.id,
        storeId: row.storeId,
        supplierId: row.supplierId,
        type: SupplierTransactionType.values.firstWhere((t) => t.name == row.type),
        amountMinorUnits: row.amountMinorUnits,
        relatedPurchaseOrderId: row.relatedPurchaseOrderId,
        deliveryDate: row.deliveryDate,
        journalEntryId: row.journalEntryId,
        createdByUserId: row.createdByUserId,
        createdAt: row.createdAt,
      );

  @override
  Future<SupplierRecord> createSupplier({
    required String storeId,
    required String name,
    String? contactPhone,
    String? contactPerson,
    String? address,
  }) async {
    final id = IdGenerator.newId();
    await _db.into(_db.suppliers).insert(
          SuppliersCompanion.insert(
            id: id,
            storeId: storeId,
            name: name,
            contactPhone: Value(contactPhone),
            contactPerson: Value(contactPerson),
            address: Value(address),
            createdAt: DateTime.now(),
          ),
        );
    return SupplierRecord(id: id, storeId: storeId, name: name, contactPhone: contactPhone, contactPerson: contactPerson, address: address);
  }

  @override
  Stream<List<SupplierRecord>> watchSuppliers(String storeId) {
    return (_db.select(_db.suppliers)
          ..where((t) => t.storeId.equals(storeId))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch()
        .map((rows) => rows.map(_mapSupplier).toList());
  }

  @override
  Future<String> recordTransaction({
    required String storeId,
    required String supplierId,
    required SupplierTransactionType type,
    required int amountMinorUnits,
    String? relatedPurchaseOrderId,
    DateTime? deliveryDate,
    required String createdByUserId,
  }) async {
    final id = IdGenerator.newId();
    await _db.into(_db.supplierTransactions).insert(
          SupplierTransactionsCompanion.insert(
            id: id,
            storeId: storeId,
            supplierId: supplierId,
            type: type.name,
            amountMinorUnits: amountMinorUnits,
            relatedPurchaseOrderId: Value(relatedPurchaseOrderId),
            deliveryDate: Value(deliveryDate),
            createdByUserId: createdByUserId,
            createdAt: DateTime.now(),
          ),
        );
    return id;
  }

  @override
  Future<void> attachJournalEntry(String transactionId, String journalEntryId) async {
    await (_db.update(_db.supplierTransactions)..where((t) => t.id.equals(transactionId)))
        .write(SupplierTransactionsCompanion(journalEntryId: Value(journalEntryId)));
  }

  @override
  Stream<List<SupplierTransactionRecord>> watchTransactions(String supplierId) {
    return (_db.select(_db.supplierTransactions)
          ..where((t) => t.supplierId.equals(supplierId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch()
        .map((rows) => rows.map(_mapTx).toList());
  }

  @override
  Future<int> balanceOwed(String supplierId) async {
    final rows = await (_db.select(_db.supplierTransactions)..where((t) => t.supplierId.equals(supplierId))).get();
    var balance = 0;
    for (final row in rows) {
      switch (row.type) {
        case 'purchase':
        case 'adjustment':
          balance += row.amountMinorUnits;
        case 'payment':
          balance -= row.amountMinorUnits;
      }
    }
    return balance;
  }
}
