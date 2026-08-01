import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/utils/id_generator.dart';
import '../domain/debts_models.dart';
import '../domain/debts_repository.dart';

class DriftDebtsRepository implements DebtsRepository {
  DriftDebtsRepository(this._db);

  final AppDatabase _db;

  CustomerRecord _mapCustomer(Customer row) =>
      CustomerRecord(id: row.id, storeId: row.storeId, name: row.name, phone: row.phone, address: row.address);

  DebtLedgerEntryRecord _mapEntry(DebtLedgerEntry row) => DebtLedgerEntryRecord(
        id: row.id,
        storeId: row.storeId,
        branchId: row.branchId,
        customerId: row.customerId,
        saleId: row.saleId,
        journalEntryId: row.journalEntryId,
        originalAmountMinorUnits: row.originalAmountMinorUnits,
        amountPaidMinorUnits: row.amountPaidMinorUnits,
        receiptRef: row.receiptRef,
        status: DebtStatus.values.firstWhere((s) => s.name == row.status),
        createdAt: row.createdAt,
      );

  DebtPaymentRecord _mapPayment(DebtPayment row) => DebtPaymentRecord(
        id: row.id,
        debtLedgerEntryId: row.debtLedgerEntryId,
        amountMinorUnits: row.amountMinorUnits,
        paymentMethod: row.paymentMethod,
        receivedByUserId: row.receivedByUserId,
        journalEntryId: row.journalEntryId,
        paidAt: row.paidAt,
      );

  @override
  Future<CustomerRecord> createCustomer(String storeId, String name, {String? phone, String? address}) async {
    final id = IdGenerator.newId();
    await _db.into(_db.customers).insert(
          CustomersCompanion.insert(
            id: id,
            storeId: storeId,
            name: name,
            phone: Value(phone),
            address: Value(address),
            createdAt: DateTime.now(),
          ),
        );
    return CustomerRecord(id: id, storeId: storeId, name: name, phone: phone, address: address);
  }

  @override
  Stream<List<CustomerRecord>> watchCustomers(String storeId) {
    return (_db.select(_db.customers)
          ..where((t) => t.storeId.equals(storeId))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch()
        .map((rows) => rows.map(_mapCustomer).toList());
  }

  @override
  Future<CustomerRecord?> findCustomerByName(String storeId, String name) async {
    final row = await (_db.select(_db.customers)
          ..where((t) => t.storeId.equals(storeId) & t.name.equals(name)))
        .getSingleOrNull();
    return row == null ? null : _mapCustomer(row);
  }

  @override
  Future<DebtLedgerEntryRecord> createDebtEntry({
    required String storeId,
    required String branchId,
    required String customerId,
    String? saleId,
    String? journalEntryId,
    required int originalAmountMinorUnits,
    String? receiptRef,
  }) async {
    final id = IdGenerator.newId();
    final now = DateTime.now();
    await _db.into(_db.debtLedgerEntries).insert(
          DebtLedgerEntriesCompanion.insert(
            id: id,
            storeId: storeId,
            branchId: branchId,
            customerId: customerId,
            saleId: Value(saleId),
            journalEntryId: Value(journalEntryId),
            originalAmountMinorUnits: originalAmountMinorUnits,
            receiptRef: Value(receiptRef),
            createdAt: now,
          ),
        );
    return DebtLedgerEntryRecord(
      id: id,
      storeId: storeId,
      branchId: branchId,
      customerId: customerId,
      saleId: saleId,
      journalEntryId: journalEntryId,
      originalAmountMinorUnits: originalAmountMinorUnits,
      receiptRef: receiptRef,
      createdAt: now,
    );
  }

  @override
  Stream<List<DebtLedgerEntryRecord>> watchDebtsForCustomer(String customerId) {
    return (_db.select(_db.debtLedgerEntries)
          ..where((t) => t.customerId.equals(customerId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch()
        .map((rows) => rows.map(_mapEntry).toList());
  }

  @override
  Stream<List<DebtLedgerEntryRecord>> watchOpenDebts(String storeId) {
    return (_db.select(_db.debtLedgerEntries)
          ..where((t) => t.storeId.equals(storeId) & t.status.isNotValue('paid'))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch()
        .map((rows) => rows.map(_mapEntry).toList());
  }

  @override
  Future<String> recordPayment({
    required String debtLedgerEntryId,
    required int amountMinorUnits,
    required String paymentMethod,
    required String receivedByUserId,
  }) async {
    final paymentId = IdGenerator.newId();
    await _db.transaction(() async {
      final entry = await (_db.select(_db.debtLedgerEntries)..where((t) => t.id.equals(debtLedgerEntryId))).getSingle();

      await _db.into(_db.debtPayments).insert(
            DebtPaymentsCompanion.insert(
              id: paymentId,
              debtLedgerEntryId: debtLedgerEntryId,
              amountMinorUnits: amountMinorUnits,
              paymentMethod: paymentMethod,
              receivedByUserId: receivedByUserId,
              paidAt: DateTime.now(),
            ),
          );

      final newPaid = entry.amountPaidMinorUnits + amountMinorUnits;
      final newStatus = newPaid >= entry.originalAmountMinorUnits
          ? 'paid'
          : (newPaid > 0 ? 'partiallyPaid' : 'open');

      await (_db.update(_db.debtLedgerEntries)..where((t) => t.id.equals(debtLedgerEntryId))).write(
        DebtLedgerEntriesCompanion(
          amountPaidMinorUnits: Value(newPaid),
          status: Value(newStatus),
        ),
      );
    });
    return paymentId;
  }

  @override
  Future<void> attachJournalEntryToPayment(String paymentId, String journalEntryId) async {
    await (_db.update(_db.debtPayments)..where((t) => t.id.equals(paymentId)))
        .write(DebtPaymentsCompanion(journalEntryId: Value(journalEntryId)));
  }

  @override
  Stream<List<DebtPaymentRecord>> watchPaymentHistory(String debtLedgerEntryId) {
    return (_db.select(_db.debtPayments)
          ..where((t) => t.debtLedgerEntryId.equals(debtLedgerEntryId))
          ..orderBy([(t) => OrderingTerm.desc(t.paidAt)]))
        .watch()
        .map((rows) => rows.map(_mapPayment).toList());
  }
}
