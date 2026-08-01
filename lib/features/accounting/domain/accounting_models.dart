/// One debit XOR credit line to be posted as part of a journal entry. Never
/// both non-zero, never both zero.
class JournalLineInput {
  const JournalLineInput({
    required this.accountCode,
    this.debitMinorUnits = 0,
    this.creditMinorUnits = 0,
    this.description = '',
  });

  final String accountCode;
  final int debitMinorUnits;
  final int creditMinorUnits;
  final String description;

  bool get isValid =>
      (debitMinorUnits > 0) != (creditMinorUnits > 0) && debitMinorUnits >= 0 && creditMinorUnits >= 0;
}

enum JournalReferenceType {
  sale,
  purchase,
  supplierPayment,
  debtPayment,
  expense,
  returnEntry,
  adjustment,
  manual,
  openingBalance,
}

class ChartOfAccountEntry {
  const ChartOfAccountEntry({
    required this.id,
    required this.storeId,
    required this.code,
    required this.name,
    required this.type,
    this.parentAccountId,
    this.isSystemAccount = false,
    this.isActive = true,
  });

  final String id;
  final String storeId;
  final String code;
  final String name;
  final String type;
  final String? parentAccountId;
  final bool isSystemAccount;
  final bool isActive;
}

class JournalEntryRecord {
  const JournalEntryRecord({
    required this.id,
    required this.storeId,
    required this.branchId,
    required this.entryDate,
    required this.referenceType,
    this.referenceId,
    this.memo = '',
    required this.createdByUserId,
    this.isReversal = false,
    this.reversalOfEntryId,
    required this.createdAt,
    required this.lines,
  });

  final String id;
  final String storeId;
  final String branchId;
  final DateTime entryDate;
  final JournalReferenceType referenceType;
  final String? referenceId;
  final String memo;
  final String createdByUserId;
  final bool isReversal;
  final String? reversalOfEntryId;
  final DateTime createdAt;
  final List<PostedJournalLine> lines;
}

class PostedJournalLine {
  const PostedJournalLine({
    required this.id,
    required this.accountId,
    required this.accountCode,
    required this.debitMinorUnits,
    required this.creditMinorUnits,
    this.description = '',
  });

  final String id;
  final String accountId;
  final String accountCode;
  final int debitMinorUnits;
  final int creditMinorUnits;
  final String description;
}

class UnbalancedJournalEntryException implements Exception {
  UnbalancedJournalEntryException(this.debitTotal, this.creditTotal);
  final int debitTotal;
  final int creditTotal;
  @override
  String toString() =>
      'Journal entry does not balance: debits=$debitTotal credits=$creditTotal';
}

class UnknownAccountCodeException implements Exception {
  UnknownAccountCodeException(this.code);
  final String code;
  @override
  String toString() => 'Unknown chart-of-accounts code: $code';
}
