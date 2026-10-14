import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/offline/offline_cache.dart';
import '../../../core/offline/sync_service.dart';
import '../../../core/utils/id_generator.dart';

import '../domain/debts_models.dart';
import '../domain/debts_repository.dart';

class SupabaseDebtsRepository implements DebtsRepository {
  SupabaseDebtsRepository(this._client, this._writer);

  final SupabaseClient _client;
  final OfflineWriter _writer;

  CustomerRecord _mapCustomer(Map<String, dynamic> row) => CustomerRecord(
        id: row['id'] as String,
        storeId: row['store_id'] as String,
        name: row['name'] as String,
        phone: row['phone'] as String?,
        address: row['address'] as String?,
        loyaltyPoints: (row['loyalty_points'] as num?)?.toInt() ?? 0,
      );

  DebtLedgerEntryRecord _mapEntry(Map<String, dynamic> row) => DebtLedgerEntryRecord(
        id: row['id'] as String,
        storeId: row['store_id'] as String,
        branchId: row['branch_id'] as String,
        customerId: row['customer_id'] as String,
        saleId: row['sale_id'] as String?,
        journalEntryId: row['journal_entry_id'] as String?,
        originalAmountMinorUnits: (row['original_amount_minor_units'] as num).toInt(),
        amountPaidMinorUnits: (row['amount_paid_minor_units'] as num?)?.toInt() ?? 0,
        receiptRef: row['receipt_ref'] as String?,
        status: _status(row),
        createdAt: DateTime.parse(row['created_at'] as String).toLocal(),
      );

  /// A payment made on this device and not yet sent changes the amount
  /// paid before the server has updated the status, so it is worked out
  /// from the amounts here.
  DebtStatus _status(Map<String, dynamic> row) {
    final original = (row['original_amount_minor_units'] as num).toInt();
    final paid = (row['amount_paid_minor_units'] as num?)?.toInt() ?? 0;
    if (paid >= original && original > 0) return DebtStatus.paid;
    if (paid > 0) return DebtStatus.partiallyPaid;
    return DebtStatus.values.firstWhere((s) => s.name == row['status']);
  }

  DebtPaymentRecord _mapPayment(Map<String, dynamic> row) => DebtPaymentRecord(
        id: row['id'] as String,
        debtLedgerEntryId: row['debt_ledger_entry_id'] as String,
        amountMinorUnits: (row['amount_minor_units'] as num).toInt(),
        paymentMethod: row['payment_method'] as String,
        receivedByUserId: row['received_by_user_id'] as String,
        journalEntryId: row['journal_entry_id'] as String?,
        paidAt: DateTime.parse(row['paid_at'] as String).toLocal(),
      );

  @override
  Future<CustomerRecord> createCustomer(String storeId, String name, {String? phone, String? address}) async {
    final row = await _writer.insert('customers', {
      'store_id': storeId,
      'name': name,
      'phone': phone,
      'address': address,
      'loyalty_points': 0,
    });
    return _mapCustomer(row);
  }

  @override
  Stream<List<CustomerRecord>> watchCustomers(String storeId) {
    // Cached so customers can still be picked (and added) at the till offline.
    return resilientRows(
      'customers.$storeId',
      () => _client.from('customers').stream(primaryKey: ['id']).order('name'),
      table: 'customers',
      where: (r) => r['store_id'] == storeId,
    ).map((rows) => rows.where((r) => r['store_id'] == storeId).map(_mapCustomer).toList());
  }

  @override
  Future<CustomerRecord?> findCustomerByName(String storeId, String name) async {
    final rows = await fetchRowsOrCached(
      'customers.$storeId',
      () async =>
          (await _client.from('customers').select().eq('store_id', storeId).order('name')).cast<Map<String, dynamic>>(),
      table: 'customers',
      where: (r) => r['store_id'] == storeId,
    );
    final row = rows?.where((r) => r['name'] == name).firstOrNull;
    return row == null ? null : _mapCustomer(row);
  }

  @override
  Future<void> adjustLoyaltyPoints(String customerId, int delta) async {
    // Shared-backend checkouts adjust points inside checkout_sale_once;
    // this is only for manual corrections.
    final row = await _client.from('customers').select('loyalty_points').eq('id', customerId).single();
    final current = (row['loyalty_points'] as num?)?.toInt() ?? 0;
    await _writer.update('customers', {'loyalty_points': current + delta}, value: customerId);
  }

  @override
  Future<void> updateCustomer(CustomerRecord customer) async {
    await _writer.update(
      'customers',
      {'name': customer.name, 'phone': customer.phone, 'address': customer.address},
      value: customer.id,
    );
  }

  @override
  Future<void> updateCustomerPhone(String customerId, String? phone) async {
    await _writer.update('customers', {'phone': phone}, value: customerId);
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
    final row = await _writer.insert('debt_ledger_entries', {
      'store_id': storeId,
      'branch_id': branchId,
      'customer_id': customerId,
      'sale_id': saleId,
      'journal_entry_id': journalEntryId,
      'original_amount_minor_units': originalAmountMinorUnits,
      'amount_paid_minor_units': 0,
      'status': 'open',
      'receipt_ref': receiptRef,
      'created_at': DateTime.now().toUtc().toIso8601String(),
    });
    return _mapEntry(row);
  }

  @override
  Stream<List<DebtLedgerEntryRecord>> watchDebtsForCustomer(String customerId) {
    return resilientRows(
      'debts.customer.$customerId',
      () => _client
          .from('debt_ledger_entries')
          .stream(primaryKey: ['id'])
          .eq('customer_id', customerId)
          .order('created_at', ascending: false),
      table: 'debt_ledger_entries',
      where: (r) => r['customer_id'] == customerId,
    ).map((rows) => rows.map(_mapEntry).toList());
  }

  @override
  Stream<List<DebtLedgerEntryRecord>> watchOpenDebts(String storeId) {
    return resilientRows(
      'debts.open.$storeId',
      () => _client
          .from('debt_ledger_entries')
          .stream(primaryKey: ['id'])
          .neq('status', 'paid')
          .order('created_at', ascending: false),
      table: 'debt_ledger_entries',
    ).map((rows) => rows.map(_mapEntry).where((e) => e.status != DebtStatus.paid).toList());
  }

  @override
  Future<DebtLedgerEntryRecord?> findBySaleId(String saleId) async {
    final rows = await fetchRowsOrCached(
      'debt.sale.$saleId',
      () async =>
          (await _client.from('debt_ledger_entries').select().eq('sale_id', saleId)).cast<Map<String, dynamic>>(),
      table: 'debt_ledger_entries',
      where: (r) => r['sale_id'] == saleId,
    );
    return (rows == null || rows.isEmpty) ? null : _mapEntry(rows.first);
  }

  @override
  Future<void> reduceOriginalAmount(String debtLedgerEntryId, int reduceByMinorUnits) async {
    await _writer.rpc(
      'reduce_debt_original_amount',
      {'p_debt_ledger_entry_id': debtLedgerEntryId, 'p_reduce_by_minor_units': reduceByMinorUnits},
      offline: () => null,
      increments: [
        {
          'table': 'debt_ledger_entries',
          'id': debtLedgerEntryId,
          'column': 'original_amount_minor_units',
          'by': -reduceByMinorUnits,
        },
      ],
    );
  }

  @override
  Future<String> recordPayment({
    required String debtLedgerEntryId,
    required int amountMinorUnits,
    required String paymentMethod,
    required String receivedByUserId,
  }) async {
    // Works offline: the payment shows at once (and on the debt) and is
    // recorded on the server — exactly once — when the connection is back.
    final localId = IdGenerator.newId();
    final id = await _writer.rpc(
      'record_debt_payment',
      {
        'p_debt_ledger_entry_id': debtLedgerEntryId,
        'p_amount_minor_units': amountMinorUnits,
        'p_payment_method': paymentMethod,
        'p_received_by_user_id': receivedByUserId,
      },
      offline: () => localId,
      opId: localId,
      previewTable: 'debt_payments',
      preview: {
        'id': localId,
        'debt_ledger_entry_id': debtLedgerEntryId,
        'amount_minor_units': amountMinorUnits,
        'payment_method': paymentMethod,
        'received_by_user_id': receivedByUserId,
        'paid_at': DateTime.now().toUtc().toIso8601String(),
      },
      increments: [
        {
          'table': 'debt_ledger_entries',
          'id': debtLedgerEntryId,
          'column': 'amount_paid_minor_units',
          'by': amountMinorUnits,
        },
      ],
    );
    return id as String;
  }

  @override
  Future<void> attachJournalEntryToPayment(String paymentId, String journalEntryId) async {
    await _writer.update('debt_payments', {'journal_entry_id': journalEntryId}, value: paymentId);
  }

  @override
  Stream<List<DebtPaymentRecord>> watchPaymentHistory(String debtLedgerEntryId) {
    return resilientRows(
      'debt_payments.$debtLedgerEntryId',
      () => _client
          .from('debt_payments')
          .stream(primaryKey: ['id'])
          .eq('debt_ledger_entry_id', debtLedgerEntryId)
          .order('paid_at', ascending: false),
      table: 'debt_payments',
      where: (r) => r['debt_ledger_entry_id'] == debtLedgerEntryId,
    ).map((rows) => rows.map(_mapPayment).toList());
  }
}
