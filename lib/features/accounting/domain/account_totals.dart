import '../../../core/constants/default_chart_of_accounts.dart';
import 'accounting_models.dart';

/// The accounts whose movements are "cash" for the cash flow statement and
/// the Cash & bank section: cash on hand and the bank account.
const Set<String> kCashAccountCodes = {SystemAccountCodes.cash, SystemAccountCodes.bank};

/// How the journal names what caused an entry ('SALE', 'EXPENSE', ...).
String journalReferenceCode(JournalReferenceType type) => switch (type) {
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

/// The reverse of [journalReferenceCode]; unknown codes read as manual.
JournalReferenceType journalReferenceFromCode(String code) => switch (code) {
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

/// True for account types whose balance grows with debits (what the store
/// has or spends); false for ones that grow with credits (what it owes,
/// owns, or earns).
bool isDebitNormalType(String type) =>
    type == AccountType.asset.name || type == AccountType.expense.name || type == AccountType.cogs.name;

/// One account's debits and credits: in the chosen period, and in total up
/// to the end of it (all history), from which its balances follow.
class AccountTotal {
  const AccountTotal({
    required this.code,
    required this.name,
    required this.type,
    this.periodDebit = 0,
    this.periodCredit = 0,
    this.closingDebit = 0,
    this.closingCredit = 0,
  });

  final String code;
  final String name;

  /// asset / liability / equity / revenue / cogs / expense.
  final String type;
  final int periodDebit;
  final int periodCredit;
  final int closingDebit;
  final int closingCredit;

  bool get isDebitNormal => isDebitNormalType(type);

  /// Balance at the end of the period, signed the account's normal way
  /// (positive cash = money held, positive payables = money owed).
  int get closingBalance => isDebitNormal ? closingDebit - closingCredit : closingCredit - closingDebit;

  /// How much the balance moved in the period, signed the same way.
  int get periodChange => isDebitNormal ? periodDebit - periodCredit : periodCredit - periodDebit;

  /// Balance when the period started.
  int get openingBalance => closingBalance - periodChange;

  AccountTotal add({int periodDebit = 0, int periodCredit = 0, int closingDebit = 0, int closingCredit = 0}) =>
      AccountTotal(
        code: code,
        name: name,
        type: type,
        periodDebit: this.periodDebit + periodDebit,
        periodCredit: this.periodCredit + periodCredit,
        closingDebit: this.closingDebit + closingDebit,
        closingCredit: this.closingCredit + closingCredit,
      );

  Map<String, dynamic> toJson() => {
        'account_code': code,
        'account_name': name,
        'account_type': type,
        'period_debit': periodDebit,
        'period_credit': periodCredit,
        'closing_debit': closingDebit,
        'closing_credit': closingCredit,
      };

  /// Reads a row of the server's `account_totals` (or [toJson]).
  factory AccountTotal.fromJson(Map<String, dynamic> json) => AccountTotal(
        code: json['account_code'] as String,
        name: (json['account_name'] as String?) ?? '',
        type: (json['account_type'] as String?) ?? '',
        periodDebit: _int(json['period_debit']),
        periodCredit: _int(json['period_credit']),
        closingDebit: _int(json['closing_debit']),
        closingCredit: _int(json['closing_credit']),
      );
}

/// Debits and credits on one account in the period caused by one kind of
/// event (all sales, all expenses, ...).
class ReferenceMovement {
  const ReferenceMovement({
    required this.accountCode,
    required this.referenceType,
    this.debit = 0,
    this.credit = 0,
  });

  final String accountCode;

  /// The journal's code for the cause: 'SALE', 'EXPENSE', ...
  final String referenceType;
  final int debit;
  final int credit;

  Map<String, dynamic> toJson() =>
      {'account_code': accountCode, 'reference_type': referenceType, 'debit': debit, 'credit': credit};

  factory ReferenceMovement.fromJson(Map<String, dynamic> json) => ReferenceMovement(
        accountCode: json['account_code'] as String,
        referenceType: (json['reference_type'] as String?) ?? 'MANUAL',
        debit: _int(json['debit']),
        credit: _int(json['credit']),
      );
}

/// Where a set of totals came from.
enum TotalsSource {
  /// Just added up by the server.
  live,

  /// Worked out on this device with no connection: the server's last
  /// figures for this period (or the journal kept on the device) plus
  /// entries made here and not yet sent. May be incomplete.
  offlineEstimate,

  /// The local (single-device) build: worked out from its own database.
  local,
}

/// Every account's totals for one period, plus the cash and bank movements
/// by cause — everything the accounting statements are built from.
class AccountTotals {
  AccountTotals({
    required this.from,
    required this.to,
    required List<AccountTotal> accounts,
    this.movements = const [],
    required this.source,
    required this.fetchedAt,
    this.unsentEntries = 0,
    this.unsentSales = 0,
  }) : accounts = {for (final a in (List.of(accounts)..sort((a, b) => a.code.compareTo(b.code)))) a.code: a};

  /// Start of the period (inclusive); null = from the first entry.
  final DateTime? from;

  /// End of the period (exclusive): balances are as at this moment.
  final DateTime to;

  /// By account code, in code order.
  final Map<String, AccountTotal> accounts;

  /// Cash and bank movements in the period, by account and cause.
  final List<ReferenceMovement> movements;
  final TotalsSource source;

  /// When the figures were added up (for an estimate: when the server's
  /// part was, if any).
  final DateTime fetchedAt;

  /// Journal entries made on this device, not yet sent, that are included.
  final int unsentEntries;

  /// Sales made on this device, not yet sent: not included (the server
  /// posts their journal entry when they arrive).
  final int unsentSales;

  bool get isEstimate => source == TotalsSource.offlineEstimate;

  /// The account with [code], or an empty one when the store has none.
  AccountTotal account(String code) => accounts[code] ?? AccountTotal(code: code, name: code, type: '');

  Iterable<AccountTotal> ofType(AccountType type) => accounts.values.where((a) => a.type == type.name);

  /// Copies these totals with other details changed.
  AccountTotals copyWith({TotalsSource? source, int? unsentEntries, int? unsentSales}) => AccountTotals(
        from: from,
        to: to,
        accounts: accounts.values.toList(),
        movements: movements,
        source: source ?? this.source,
        fetchedAt: fetchedAt,
        unsentEntries: unsentEntries ?? this.unsentEntries,
        unsentSales: unsentSales ?? this.unsentSales,
      );

  /// Builds totals from the server's `account_totals` rows and
  /// `account_movements_by_reference` rows.
  factory AccountTotals.fromServerRows({
    required DateTime? from,
    required DateTime to,
    required List<Map<String, dynamic>> accountRows,
    List<Map<String, dynamic>> movementRows = const [],
    TotalsSource source = TotalsSource.live,
    DateTime? fetchedAt,
  }) =>
      AccountTotals(
        from: from,
        to: to,
        accounts: accountRows.map(AccountTotal.fromJson).toList(),
        movements: movementRows.map(ReferenceMovement.fromJson).toList(),
        source: source,
        fetchedAt: fetchedAt ?? DateTime.now(),
      );

  /// Adds up [entries] (any dates; only those before [to] count) for the
  /// store's [chart] of accounts. Lines on accounts not in the chart are
  /// left out.
  factory AccountTotals.fromEntries({
    required List<ChartOfAccountEntry> chart,
    required Iterable<JournalEntryRecord> entries,
    required DateTime? from,
    required DateTime to,
    required TotalsSource source,
    DateTime? fetchedAt,
  }) {
    final empty = AccountTotals(
      from: from,
      to: to,
      accounts: [for (final a in chart) AccountTotal(code: a.code, name: a.name, type: a.type)],
      source: source,
      fetchedAt: fetchedAt ?? DateTime.now(),
    );
    return empty.withEntries(entries, countAsUnsent: false);
  }

  /// These totals with [entries] added (those dated before [to]; the
  /// period columns only for those on or after [from]). Used to lay
  /// entries made on this device and not yet sent over the server's
  /// figures. With [countAsUnsent], they are counted in [unsentEntries].
  AccountTotals withEntries(Iterable<JournalEntryRecord> entries, {bool countAsUnsent = true}) {
    final next = Map.of(accounts);
    final moves = <String, ReferenceMovement>{
      for (final m in movements) '${m.accountCode}|${m.referenceType}': m,
    };
    var added = 0;
    for (final e in entries) {
      if (!e.entryDate.isBefore(to)) continue;
      final inPeriod = from == null || !e.entryDate.isBefore(from!);
      added++;
      for (final line in e.lines) {
        final current = next[line.accountCode];
        if (current == null) continue;
        next[line.accountCode] = current.add(
          periodDebit: inPeriod ? line.debitMinorUnits : 0,
          periodCredit: inPeriod ? line.creditMinorUnits : 0,
          closingDebit: line.debitMinorUnits,
          closingCredit: line.creditMinorUnits,
        );
        if (inPeriod && kCashAccountCodes.contains(line.accountCode)) {
          final ref = journalReferenceCode(e.referenceType);
          final key = '${line.accountCode}|$ref';
          final m = moves[key];
          moves[key] = ReferenceMovement(
            accountCode: line.accountCode,
            referenceType: ref,
            debit: (m?.debit ?? 0) + line.debitMinorUnits,
            credit: (m?.credit ?? 0) + line.creditMinorUnits,
          );
        }
      }
    }
    return AccountTotals(
      from: from,
      to: to,
      accounts: next.values.toList(),
      movements: moves.values.toList(),
      source: source,
      fetchedAt: fetchedAt,
      unsentEntries: unsentEntries + (countAsUnsent ? added : 0),
      unsentSales: unsentSales,
    );
  }

  Map<String, dynamic> toJson() => {
        'from': from?.toUtc().toIso8601String(),
        'to': to.toUtc().toIso8601String(),
        'fetched_at': fetchedAt.toUtc().toIso8601String(),
        'accounts': [for (final a in accounts.values) a.toJson()],
        'movements': [for (final m in movements) m.toJson()],
      };

  /// Reads [toJson] back (a copy kept on the device), as [source].
  factory AccountTotals.fromJson(Map<String, dynamic> json, {required TotalsSource source}) => AccountTotals(
        from: json['from'] == null ? null : DateTime.parse(json['from'] as String).toLocal(),
        to: DateTime.parse(json['to'] as String).toLocal(),
        fetchedAt: DateTime.parse(json['fetched_at'] as String).toLocal(),
        accounts: [for (final a in (json['accounts'] as List).cast<Map>()) AccountTotal.fromJson(a.cast())],
        movements: [
          for (final m in (json['movements'] as List? ?? const []).cast<Map>()) ReferenceMovement.fromJson(m.cast())
        ],
        source: source,
      );
}

int _int(Object? v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;
