import 'package:drift/drift.dart';

import '../../../core/constants/default_chart_of_accounts.dart';
import '../../../core/database/app_database.dart';
import '../../../core/utils/id_generator.dart';
import '../domain/accounting_models.dart';
import '../domain/accounting_repository.dart' as domain;

class DriftAccountingRepository implements domain.AccountingRepository {
  DriftAccountingRepository(this._db);

  final AppDatabase _db;

  @override
  Future<void> seedDefaultChartOfAccounts(String storeId) async {
    final existing = await (_db.select(_db.chartOfAccounts)
          ..where((t) => t.storeId.equals(storeId)))
        .get();
    if (existing.isNotEmpty) return;

    await _db.batch((batch) {
      batch.insertAll(
        _db.chartOfAccounts,
        kDefaultChartOfAccounts.map(
          (seed) => ChartOfAccountsCompanion.insert(
            id: IdGenerator.newId(),
            storeId: storeId,
            code: seed.code,
            name: seed.name,
            type: seed.type.name,
            isSystemAccount: Value(seed.isSystemAccount),
          ),
        ),
      );
    });
  }

  @override
  Future<List<ChartOfAccountEntry>> listAccounts(String storeId) async {
    final rows = await (_db.select(_db.chartOfAccounts)
          ..where((t) => t.storeId.equals(storeId)))
        .get();
    return rows.map(_mapAccount).toList();
  }

  ChartOfAccountEntry _mapAccount(ChartOfAccount row) => ChartOfAccountEntry(
        id: row.id,
        storeId: row.storeId,
        code: row.code,
        name: row.name,
        type: row.type,
        parentAccountId: row.parentAccountId,
        isSystemAccount: row.isSystemAccount,
        isActive: row.isActive,
      );

  Future<Map<String, String>> _codeToIdMap(String storeId) async {
    final accounts = await listAccounts(storeId);
    return {for (final a in accounts) a.code: a.id};
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

    final codeToId = await _codeToIdMap(storeId);
    for (final line in lines) {
      if (!codeToId.containsKey(line.accountCode)) {
        throw UnknownAccountCodeException(line.accountCode);
      }
    }

    final entryId = IdGenerator.newId();
    final now = DateTime.now();
    final date = entryDate ?? now;

    return _db.transaction(() async {
      await _db.into(_db.journalEntries).insert(
            JournalEntriesCompanion.insert(
              id: entryId,
              storeId: storeId,
              branchId: branchId,
              entryDate: date,
              referenceType: _referenceTypeToDb(referenceType),
              referenceId: Value(referenceId),
              memo: Value(memo),
              createdByUserId: createdByUserId,
              createdAt: now,
            ),
          );

      final postedLines = <PostedJournalLine>[];
      for (final line in lines) {
        final lineId = IdGenerator.newId();
        await _db.into(_db.journalLines).insert(
              JournalLinesCompanion.insert(
                id: lineId,
                storeId: storeId,
                journalEntryId: entryId,
                accountId: codeToId[line.accountCode]!,
                debitMinorUnits: Value(line.debitMinorUnits),
                creditMinorUnits: Value(line.creditMinorUnits),
                description: Value(line.description),
              ),
            );
        postedLines.add(PostedJournalLine(
          id: lineId,
          accountId: codeToId[line.accountCode]!,
          accountCode: line.accountCode,
          debitMinorUnits: line.debitMinorUnits,
          creditMinorUnits: line.creditMinorUnits,
          description: line.description,
        ));
      }

      return JournalEntryRecord(
        id: entryId,
        storeId: storeId,
        branchId: branchId,
        entryDate: date,
        referenceType: referenceType,
        referenceId: referenceId,
        memo: memo,
        createdByUserId: createdByUserId,
        createdAt: now,
        lines: postedLines,
      );
    });
  }

  @override
  Future<JournalEntryRecord> postReversingEntry({
    required String originalEntryId,
    required String createdByUserId,
    String memo = 'Reversal',
  }) async {
    final original = await (_db.select(_db.journalEntries)
          ..where((t) => t.id.equals(originalEntryId)))
        .getSingle();
    final originalLines = await (_db.select(_db.journalLines)
          ..where((t) => t.journalEntryId.equals(originalEntryId)))
        .get();

    final accounts = await listAccounts(original.storeId);
    final idToCode = {for (final a in accounts) a.id: a.code};

    final flippedLines = originalLines
        .map((l) => JournalLineInput(
              accountCode: idToCode[l.accountId]!,
              debitMinorUnits: l.creditMinorUnits,
              creditMinorUnits: l.debitMinorUnits,
              description: l.description,
            ))
        .toList();

    final entryId = IdGenerator.newId();
    final now = DateTime.now();

    return _db.transaction(() async {
      await _db.into(_db.journalEntries).insert(
            JournalEntriesCompanion.insert(
              id: entryId,
              storeId: original.storeId,
              branchId: original.branchId,
              entryDate: now,
              referenceType: original.referenceType,
              referenceId: Value(original.referenceId),
              memo: Value(memo),
              createdByUserId: createdByUserId,
              isReversal: const Value(true),
              reversalOfEntryId: Value(originalEntryId),
              createdAt: now,
            ),
          );

      final postedLines = <PostedJournalLine>[];
      final codeToId = await _codeToIdMap(original.storeId);
      for (final line in flippedLines) {
        final lineId = IdGenerator.newId();
        await _db.into(_db.journalLines).insert(
              JournalLinesCompanion.insert(
                id: lineId,
                storeId: original.storeId,
                journalEntryId: entryId,
                accountId: codeToId[line.accountCode]!,
                debitMinorUnits: Value(line.debitMinorUnits),
                creditMinorUnits: Value(line.creditMinorUnits),
                description: Value(line.description),
              ),
            );
        postedLines.add(PostedJournalLine(
          id: lineId,
          accountId: codeToId[line.accountCode]!,
          accountCode: line.accountCode,
          debitMinorUnits: line.debitMinorUnits,
          creditMinorUnits: line.creditMinorUnits,
          description: line.description,
        ));
      }

      return JournalEntryRecord(
        id: entryId,
        storeId: original.storeId,
        branchId: original.branchId,
        entryDate: now,
        referenceType: _referenceTypeFromDb(original.referenceType),
        referenceId: original.referenceId,
        memo: memo,
        createdByUserId: createdByUserId,
        isReversal: true,
        reversalOfEntryId: originalEntryId,
        createdAt: now,
        lines: postedLines,
      );
    });
  }

  @override
  Stream<List<JournalEntryRecord>> watchJournalEntries(String storeId, {domain.DateTimeRange? range}) {
    final query = _db.select(_db.journalEntries)..where((t) => t.storeId.equals(storeId));
    if (range != null) {
      query.where((t) => t.entryDate.isBetweenValues(range.start, range.end));
    }
    query.orderBy([(t) => OrderingTerm.desc(t.entryDate)]);

    return query.watch().asyncMap((entries) async {
      final result = <JournalEntryRecord>[];
      for (final entry in entries) {
        final lines = await (_db.select(_db.journalLines)
              ..where((t) => t.journalEntryId.equals(entry.id)))
            .get();
        final accounts = await listAccounts(storeId);
        final idToCode = {for (final a in accounts) a.id: a.code};
        result.add(JournalEntryRecord(
          id: entry.id,
          storeId: entry.storeId,
          branchId: entry.branchId,
          entryDate: entry.entryDate,
          referenceType: _referenceTypeFromDb(entry.referenceType),
          referenceId: entry.referenceId,
          memo: entry.memo,
          createdByUserId: entry.createdByUserId,
          isReversal: entry.isReversal,
          reversalOfEntryId: entry.reversalOfEntryId,
          createdAt: entry.createdAt,
          lines: lines
              .map((l) => PostedJournalLine(
                    id: l.id,
                    accountId: l.accountId,
                    accountCode: idToCode[l.accountId] ?? '?',
                    debitMinorUnits: l.debitMinorUnits,
                    creditMinorUnits: l.creditMinorUnits,
                    description: l.description,
                  ))
              .toList(),
        ));
      }
      return result;
    });
  }

  @override
  Future<Map<String, int>> trialBalance(String storeId, {DateTime? asOf}) async {
    final accounts = await listAccounts(storeId);
    final idToCode = {for (final a in accounts) a.id: a.code};
    final typeByCode = {for (final a in accounts) a.code: a.type};

    var query = _db.select(_db.journalLines).join([
      innerJoin(_db.journalEntries, _db.journalEntries.id.equalsExp(_db.journalLines.journalEntryId)),
    ])
      ..where(_db.journalLines.storeId.equals(storeId));
    if (asOf != null) {
      query = query..where(_db.journalEntries.entryDate.isSmallerOrEqualValue(asOf));
    }

    final rows = await query.get();
    final debitTotals = <String, int>{};
    final creditTotals = <String, int>{};
    for (final row in rows) {
      final line = row.readTable(_db.journalLines);
      final code = idToCode[line.accountId];
      if (code == null) continue;
      debitTotals[code] = (debitTotals[code] ?? 0) + line.debitMinorUnits;
      creditTotals[code] = (creditTotals[code] ?? 0) + line.creditMinorUnits;
    }

    final balances = <String, int>{};
    for (final code in {...debitTotals.keys, ...creditTotals.keys}) {
      final debit = debitTotals[code] ?? 0;
      final credit = creditTotals[code] ?? 0;
      final type = typeByCode[code];
      final isDebitNormal = type == AccountType.asset.name ||
          type == AccountType.expense.name ||
          type == AccountType.cogs.name;
      balances[code] = isDebitNormal ? debit - credit : credit - debit;
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
