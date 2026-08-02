import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/suppliers_models.dart';
import '../domain/suppliers_repository.dart';

class SupabaseSuppliersRepository implements SuppliersRepository {
  SupabaseSuppliersRepository(this._client);

  final SupabaseClient _client;

  SupplierRecord _mapSupplier(Map<String, dynamic> row) => SupplierRecord(
        id: row['id'] as String,
        storeId: row['store_id'] as String,
        name: row['name'] as String,
        contactPhone: row['contact_phone'] as String?,
        contactPerson: row['contact_person'] as String?,
        address: row['address'] as String?,
      );

  SupplierTransactionRecord _mapTx(Map<String, dynamic> row) => SupplierTransactionRecord(
        id: row['id'] as String,
        storeId: row['store_id'] as String,
        supplierId: row['supplier_id'] as String,
        type: SupplierTransactionType.values.firstWhere((t) => t.name == row['type']),
        amountMinorUnits: (row['amount_minor_units'] as num).toInt(),
        relatedPurchaseOrderId: row['related_purchase_order_id'] as String?,
        deliveryDate: row['delivery_date'] == null ? null : DateTime.parse(row['delivery_date'] as String),
        journalEntryId: row['journal_entry_id'] as String?,
        createdByUserId: row['created_by_user_id'] as String,
        createdAt: DateTime.parse(row['created_at'] as String),
      );

  @override
  Future<SupplierRecord> createSupplier({
    required String storeId,
    required String name,
    String? contactPhone,
    String? contactPerson,
    String? address,
  }) async {
    final row = await _client.from('suppliers').insert({
      'store_id': storeId,
      'name': name,
      'contact_phone': contactPhone,
      'contact_person': contactPerson,
      'address': address,
    }).select().single();
    return _mapSupplier(row);
  }

  @override
  Stream<List<SupplierRecord>> watchSuppliers(String storeId) {
    return _client.from('suppliers').stream(primaryKey: ['id']).order('name').map((rows) => rows.map(_mapSupplier).toList());
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
    final row = await _client.from('supplier_transactions').insert({
      'store_id': storeId,
      'supplier_id': supplierId,
      'type': type.name,
      'amount_minor_units': amountMinorUnits,
      'related_purchase_order_id': relatedPurchaseOrderId,
      'delivery_date': deliveryDate?.toIso8601String(),
      'created_by_user_id': createdByUserId,
    }).select('id').single();
    return row['id'] as String;
  }

  @override
  Future<void> attachJournalEntry(String transactionId, String journalEntryId) async {
    await _client.from('supplier_transactions').update({'journal_entry_id': journalEntryId}).eq('id', transactionId);
  }

  @override
  Stream<List<SupplierTransactionRecord>> watchTransactions(String supplierId) {
    return _client
        .from('supplier_transactions')
        .stream(primaryKey: ['id'])
        .eq('supplier_id', supplierId)
        .order('created_at', ascending: false)
        .map((rows) => rows.map(_mapTx).toList());
  }

  @override
  Future<int> balanceOwed(String supplierId) async {
    final result = await _client.rpc('supplier_balance_owed', params: {'p_supplier_id': supplierId});
    return (result as num).toInt();
  }
}
