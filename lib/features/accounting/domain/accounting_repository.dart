import 'account_totals.dart';
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

  /// Every account's debits and credits from [from] (inclusive; null = the
  /// first entry) to [to] (exclusive), and in total up to [to] — added up
  /// by the server on the shared backend (no row limit). With no
  /// connection, an estimate from what this device has kept
  /// ([AccountTotals.isEstimate]).
  Future<AccountTotals> accountTotals(String storeId, {DateTime? from, required DateTime to});

  /// Journal entries dated from [from] (inclusive) to [to] (exclusive),
  /// newest first, at most [limit]; entries made on this device and not yet
  /// sent included.
  Future<List<JournalEntryRecord>> journalEntriesBetween(
    String storeId, {
    required DateTime from,
    required DateTime to,
    int limit = 1000,
  });
}

class DateTimeRange {
  const DateTimeRange(this.start, this.end);
  final DateTime start;
  final DateTime end;
}
