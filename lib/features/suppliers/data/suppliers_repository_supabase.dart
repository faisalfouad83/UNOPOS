import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/offline/offline_cache.dart';
import '../../../core/offline/sync_service.dart';

import '../domain/suppliers_models.dart';
import '../domain/suppliers_repository.dart';

class SupabaseSuppliersRepository implements SuppliersRepository {
  SupabaseSuppliersRepository(this._client, this._writer);

  final SupabaseClient _client;
  final OfflineWriter _writer;

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
        deliveryDate: row['delivery_date'] == null ? null : DateTime.parse(row['delivery_date'] as String).toLocal(),
        journalEntryId: row['journal_entry_id'] as String?,
        createdByUserId: row['created_by_user_id'] as String,
        createdAt: DateTime.parse(row['created_at'] as String).toLocal(),
      );

  @override
  Future<SupplierRecord> createSupplier({
    required String storeId,
    required String name,
    String? contactPhone,
    String? contactPerson,
    String? address,
  }) async {
    final row = await _writer.insert('suppliers', {
      'store_id': storeId,
      'name': name,
      'contact_phone': contactPhone,
      'contact_person': contactPerson,
      'address': address,
    });
    return _mapSupplier(row);
  }

  @override
  Stream<List<SupplierRecord>> watchSuppliers(String storeId) {
    return resilientRows(
      'suppliers.$storeId',
      () => _client.from('suppliers').stream(primaryKey: ['id']).order('name'),
      table: 'suppliers',
    ).map((rows) => rows.map(_mapSupplier).toList());
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
    final row = await _writer.insert('supplier_transactions', {
      'store_id': storeId,
      'supplier_id': supplierId,
      'type': type.name,
      'amount_minor_units': amountMinorUnits,
      'related_purchase_order_id': relatedPurchaseOrderId,
      'delivery_date': deliveryDate?.toUtc().toIso8601String(),
      'created_by_user_id': createdByUserId,
      'created_at': DateTime.now().toUtc().toIso8601String(),
    });
    return row['id'] as String;
  }

  @override
  Future<void> attachJournalEntry(String transactionId, String journalEntryId) async {
    await _writer.update('supplier_transactions', {'journal_entry_id': journalEntryId}, value: transactionId);
  }

  @override
  Stream<List<SupplierTransactionRecord>> watchTransactions(String supplierId) {
    return resilientRows(
      'supplier_transactions.$supplierId',
      () => _client
          .from('supplier_transactions')
          .stream(primaryKey: ['id'])
          .eq('supplier_id', supplierId)
          .order('created_at', ascending: false),
      table: 'supplier_transactions',
      where: (r) => r['supplier_id'] == supplierId,
    ).map((rows) => rows.map(_mapTx).toList());
  }

  @override
  Future<int> balanceOwed(String supplierId) async {
    final key = 'supplier_balance.$supplierId';
    try {
      final result = await _client
          .rpc('supplier_balance_owed', params: {'p_supplier_id': supplierId}).timeout(const Duration(seconds: 10));
      await OfflineCache.write(key, result);
      return (result as num).toInt();
    } catch (e) {
      if (!isNetworkError(e)) rethrow;
      return ((await OfflineCache.read(key)) as num?)?.toInt() ?? 0;
    }
  }
}
