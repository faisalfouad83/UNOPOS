import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/debts_models.dart';
import '../domain/debts_repository.dart';

class SupabaseDebtsRepository implements DebtsRepository {
  SupabaseDebtsRepository(this._client);

  final SupabaseClient _client;

  CustomerRecord _mapCustomer(Map<String, dynamic> row) => CustomerRecord(
        id: row['id'] as String,
        storeId: row['store_id'] as String,
        name: row['name'] as String,
        phone: row['phone'] as String?,
        address: row['address'] as String?,
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
        status: DebtStatus.values.firstWhere((s) => s.name == row['status']),
        createdAt: DateTime.parse(row['created_at'] as String),
      );

  DebtPaymentRecord _mapPayment(Map<String, dynamic> row) => DebtPaymentRecord(
        id: row['id'] as String,
        debtLedgerEntryId: row['debt_ledger_entry_id'] as String,
        amountMinorUnits: (row['amount_minor_units'] as num).toInt(),
        paymentMethod: row['payment_method'] as String,
        receivedByUserId: row['received_by_user_id'] as String,
        journalEntryId: row['journal_entry_id'] as String?,
        paidAt: DateTime.parse(row['paid_at'] as String),
      );

  @override
  Future<CustomerRecord> createCustomer(String storeId, String name, {String? phone, String? address}) async {
    final row = await _client.from('customers').insert({
      'store_id': storeId,
      'name': name,
      'phone': phone,
      'address': address,
    }).select().single();
    return _mapCustomer(row);
  }

  @override
  Stream<List<CustomerRecord>> watchCustomers(String storeId) {
    return _client.from('customers').stream(primaryKey: ['id']).order('name').map((rows) => rows.map(_mapCustomer).toList());
  }

  @override
  Future<CustomerRecord?> findCustomerByName(String storeId, String name) async {
    final row = await _client.from('customers').select().eq('store_id', storeId).eq('name', name).maybeSingle();
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
    final row = await _client.from('debt_ledger_entries').insert({
      'store_id': storeId,
      'branch_id': branchId,
      'customer_id': customerId,
      'sale_id': saleId,
      'journal_entry_id': journalEntryId,
      'original_amount_minor_units': originalAmountMinorUnits,
      'receipt_ref': receiptRef,
    }).select().single();
    return _mapEntry(row);
  }

  @override
  Stream<List<DebtLedgerEntryRecord>> watchDebtsForCustomer(String customerId) {
    return _client
        .from('debt_ledger_entries')
        .stream(primaryKey: ['id'])
        .eq('customer_id', customerId)
        .order('created_at', ascending: false)
        .map((rows) => rows.map(_mapEntry).toList());
  }

  @override
  Stream<List<DebtLedgerEntryRecord>> watchOpenDebts(String storeId) {
    return _client
        .from('debt_ledger_entries')
        .stream(primaryKey: ['id'])
        .neq('status', 'paid')
        .order('created_at', ascending: false)
        .map((rows) => rows.map(_mapEntry).toList());
  }

  @override
  Future<DebtLedgerEntryRecord?> findBySaleId(String saleId) async {
    final row = await _client.from('debt_ledger_entries').select().eq('sale_id', saleId).maybeSingle();
    return row == null ? null : _mapEntry(row);
  }

  @override
  Future<void> reduceOriginalAmount(String debtLedgerEntryId, int reduceByMinorUnits) async {
    await _client.rpc('reduce_debt_original_amount', params: {
      'p_debt_ledger_entry_id': debtLedgerEntryId,
      'p_reduce_by_minor_units': reduceByMinorUnits,
    });
  }

  @override
  Future<String> recordPayment({
    required String debtLedgerEntryId,
    required int amountMinorUnits,
    required String paymentMethod,
    required String receivedByUserId,
  }) async {
    final id = await _client.rpc('record_debt_payment', params: {
      'p_debt_ledger_entry_id': debtLedgerEntryId,
      'p_amount_minor_units': amountMinorUnits,
      'p_payment_method': paymentMethod,
      'p_received_by_user_id': receivedByUserId,
    });
    return id as String;
  }

  @override
  Future<void> attachJournalEntryToPayment(String paymentId, String journalEntryId) async {
    await _client.from('debt_payments').update({'journal_entry_id': journalEntryId}).eq('id', paymentId);
  }

  @override
  Stream<List<DebtPaymentRecord>> watchPaymentHistory(String debtLedgerEntryId) {
    return _client
        .from('debt_payments')
        .stream(primaryKey: ['id'])
        .eq('debt_ledger_entry_id', debtLedgerEntryId)
        .order('paid_at', ascending: false)
        .map((rows) => rows.map(_mapPayment).toList());
  }
}
