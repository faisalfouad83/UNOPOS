import 'accounting_models.dart';

abstract class AccountingRepository {
  /// Seeds the default Chart of Accounts for a brand-new store. No-op if
  /// accounts already exist for that store.
  Future<void> seedDefaultChartOfAccounts(String storeId);

  Future<List<ChartOfAccountEntry>> listAccounts(String storeId);

  /// The one and only way journal entries are written. Enforces: at least
  /// two lines, each line debit XOR credit, and sum(debits) == sum(credits).
  /// Throws [UnbalancedJournalEntryException] or [UnknownAccountCodeException]
  /// on violation. The whole entry + its lines are written atomically.
  Future<JournalEntryRecord> postJournalEntry({
    required String storeId,
    required String branchId,
    required JournalReferenceType referenceType,
    String? referenceId,
    String memo,
    required String createdByUserId,
    required List<JournalLineInput> lines,
    DateTime? entryDate,
  });

  /// Posts an equal-and-opposite entry reversing [originalEntryId]. Used for
  /// corrections — the original entry is never edited or deleted.
  Future<JournalEntryRecord> postReversingEntry({
    required String originalEntryId,
    required String createdByUserId,
    String memo,
  });

  Stream<List<JournalEntryRecord>> watchJournalEntries(String storeId, {DateTimeRange? range});

  /// account code -> net balance in minor units (debits - credits for
  /// asset/expense/cogs types, credits - debits for liability/equity/revenue).
  Future<Map<String, int>> trialBalance(String storeId, {DateTime? asOf});
}

class DateTimeRange {
  const DateTimeRange(this.start, this.end);
  final DateTime start;
  final DateTime end;
}
