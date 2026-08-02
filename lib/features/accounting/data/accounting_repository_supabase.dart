import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/accounting_models.dart';
import '../domain/accounting_repository.dart' as domain;

class SupabaseAccountingRepository implements domain.AccountingRepository {
  SupabaseAccountingRepository(this._client);

  final SupabaseClient _client;

  ChartOfAccountEntry _mapAccount(Map<String, dynamic> row) => ChartOfAccountEntry(
        id: row['id'] as String,
        storeId: row['store_id'] as String,
        code: row['code'] as String,
        name: row['name'] as String,
        type: row['type'] as String,
        parentAccountId: row['parent_account_id'] as String?,
        isSystemAccount: row['is_system_account'] as bool? ?? false,
        isActive: row['is_active'] as bool? ?? true,
      );

  PostedJournalLine _mapLineJson(Map<String, dynamic> json) => PostedJournalLine(
        id: json['id'] as String,
        accountId: json['account_id'] as String,
        accountCode: json['account_code'] as String,
        debitMinorUnits: (json['debit_minor_units'] as num).toInt(),
        creditMinorUnits: (json['credit_minor_units'] as num).toInt(),
        description: json['description'] as String? ?? '',
      );

  JournalEntryRecord _mapEntryJson(Map<String, dynamic> json) => JournalEntryRecord(
        id: json['id'] as String,
        storeId: json['store_id'] as String,
        branchId: json['branch_id'] as String,
        entryDate: DateTime.parse(json['entry_date'] as String),
        referenceType: _referenceTypeFromDb(json['reference_type'] as String),
        referenceId: json['reference_id'] as String?,
        memo: json['memo'] as String? ?? '',
        createdByUserId: json['created_by_user_id'] as String,
        isReversal: json['is_reversal'] as bool? ?? false,
        reversalOfEntryId: json['reversal_of_entry_id'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
        lines: (json['lines'] as List).cast<Map<String, dynamic>>().map(_mapLineJson).toList(),
      );

  @override
  Future<void> seedDefaultChartOfAccounts(String storeId) async {
    // register_store() already seeds this at store-creation time — this is
    // a defensive no-op guard for interface parity (e.g. manual re-seed
    // calls), mirroring the Drift version's "return early if rows exist".
    final existing = await _client.from('chart_of_accounts').select('id').eq('store_id', storeId).limit(1);
    if ((existing as List).isNotEmpty) return;
    // Deliberately does not attempt to seed here: only register_store() (a
    // SECURITY DEFINER function invoked once, at registration) is allowed
    // to write the store's initial chart of accounts.
  }

  @override
  Future<List<ChartOfAccountEntry>> listAccounts(String storeId) async {
    final rows = await _client.from('chart_of_accounts').select().eq('store_id', storeId);
    return (rows as List).cast<Map<String, dynamic>>().map(_mapAccount).toList();
  }

  @override
  Future<JournalEntryRecord> postJournalEntry({
    required String storeId,
    required String branchId,
    required JournalReferenceType referenceType,
    String? referenceId,
    String memo = '',
    required String createdByUserId,
    required List<JournalLineInput> lines,
    DateTime? entryDate,
  }) async {
    // Same pre-validation as the Drift version, kept client-side so
    // ArgumentError/UnbalancedJournalEntryException surface immediately
    // without a network round trip; the RPC repeats these checks server-side
    // as defense-in-depth (e.g. for a second concurrent caller).
    if (lines.length < 2) {
      throw ArgumentError('A journal entry needs at least two lines');
    }
    for (final line in lines) {
      if (!line.isValid) {
        throw ArgumentError(
          'Each journal line must be either a debit or a credit, never both/neither (account ${line.accountCode})',
        );
      }
    }
    final debitTotal = lines.fold<int>(0, (sum, l) => sum + l.debitMinorUnits);
    final creditTotal = lines.fold<int>(0, (sum, l) => sum + l.creditMinorUnits);
    if (debitTotal != creditTotal) {
      throw UnbalancedJournalEntryException(debitTotal, creditTotal);
    }

    final json = await _client.rpc('post_journal_entry', params: {
      'p_branch_id': branchId,
      'p_reference_type': _referenceTypeToDb(referenceType),
      'p_reference_id': referenceId,
      'p_memo': memo,
      'p_created_by_user_id': createdByUserId,
      'p_lines': lines
          .map((l) => {
                'account_code': l.accountCode,
                'debit_minor_units': l.debitMinorUnits,
                'credit_minor_units': l.creditMinorUnits,
                'description': l.description,
              })
          .toList(),
      'p_entry_date': entryDate?.toIso8601String(),
    });
    return _mapEntryJson(json as Map<String, dynamic>);
  }

  @override
  Future<JournalEntryRecord> postReversingEntry({
    required String originalEntryId,
    required String createdByUserId,
    String memo = 'Reversal',
  }) async {
    final json = await _client.rpc('post_reversing_entry', params: {
      'p_original_entry_id': originalEntryId,
      'p_created_by_user_id': createdByUserId,
      'p_memo': memo,
    });
    return _mapEntryJson(json as Map<String, dynamic>);
  }

  @override
  Stream<List<JournalEntryRecord>> watchJournalEntries(String storeId, {domain.DateTimeRange? range}) {
    // .stream() supports only one server-side filter; RLS already scopes to
    // this store, so an optional date range (needing two conditions) is
    // applied client-side in the map below instead.
    return _client.from('journal_entries').stream(primaryKey: ['id']).order('entry_date', ascending: false).asyncMap((rows) async {
      var filtered = rows;
      if (range != null) {
        filtered = rows.where((r) {
          final date = DateTime.parse(r['entry_date'] as String);
          return !date.isBefore(range.start) && !date.isAfter(range.end);
        }).toList();
      }
      if (filtered.isEmpty) return <JournalEntryRecord>[];

      final entryIds = filtered.map((r) => r['id'] as String).toList();
      final lineRows = await _client
          .from('journal_lines')
          .select('*, chart_of_accounts(code)')
          .inFilter('journal_entry_id', entryIds);

      final linesByEntry = <String, List<PostedJournalLine>>{};
      for (final lr in (lineRows as List).cast<Map<String, dynamic>>()) {
        final entryId = lr['journal_entry_id'] as String;
        final accountCode = (lr['chart_of_accounts'] as Map<String, dynamic>?)?['code'] as String? ?? '?';
        (linesByEntry[entryId] ??= []).add(PostedJournalLine(
          id: lr['id'] as String,
          accountId: lr['account_id'] as String,
          accountCode: accountCode,
          debitMinorUnits: (lr['debit_minor_units'] as num).toInt(),
          creditMinorUnits: (lr['credit_minor_units'] as num).toInt(),
          description: lr['description'] as String? ?? '',
        ));
      }

      return filtered
          .map((row) => JournalEntryRecord(
                id: row['id'] as String,
                storeId: row['store_id'] as String,
                branchId: row['branch_id'] as String,
                entryDate: DateTime.parse(row['entry_date'] as String),
                referenceType: _referenceTypeFromDb(row['reference_type'] as String),
                referenceId: row['reference_id'] as String?,
                memo: row['memo'] as String? ?? '',
                createdByUserId: row['created_by_user_id'] as String,
                isReversal: row['is_reversal'] as bool? ?? false,
                reversalOfEntryId: row['reversal_of_entry_id'] as String?,
                createdAt: DateTime.parse(row['created_at'] as String),
                lines: linesByEntry[row['id']] ?? const [],
              ))
          .toList();
    });
  }

  @override
  Future<Map<String, int>> trialBalance(String storeId, {DateTime? asOf}) async {
    final rows = await _client.rpc('trial_balance', params: {'p_as_of': asOf?.toIso8601String()});
    final balances = <String, int>{};
    for (final row in (rows as List).cast<Map<String, dynamic>>()) {
      balances[row['account_code'] as String] = (row['balance_minor_units'] as num).toInt();
    }
    return balances;
  }

  static String _referenceTypeToDb(JournalReferenceType type) => switch (type) {
        JournalReferenceType.sale => 'SALE',
        JournalReferenceType.purchase => 'PURCHASE',
        JournalReferenceType.supplierPayment => 'SUPPLIER_PAYMENT',
        JournalReferenceType.debtPayment => 'DEBT_PAYMENT',
        JournalReferenceType.expense => 'EXPENSE',
        JournalReferenceType.returnEntry => 'RETURN',
        JournalReferenceType.adjustment => 'ADJUSTMENT',
        JournalReferenceType.manual => 'MANUAL',
        JournalReferenceType.openingBalance => 'OPENING_BALANCE',
      };

  static JournalReferenceType _referenceTypeFromDb(String value) => switch (value) {
        'SALE' => JournalReferenceType.sale,
        'PURCHASE' => JournalReferenceType.purchase,
        'SUPPLIER_PAYMENT' => JournalReferenceType.supplierPayment,
        'DEBT_PAYMENT' => JournalReferenceType.debtPayment,
        'EXPENSE' => JournalReferenceType.expense,
        'RETURN' => JournalReferenceType.returnEntry,
        'ADJUSTMENT' => JournalReferenceType.adjustment,
        'OPENING_BALANCE' => JournalReferenceType.openingBalance,
        _ => JournalReferenceType.manual,
      };
}
