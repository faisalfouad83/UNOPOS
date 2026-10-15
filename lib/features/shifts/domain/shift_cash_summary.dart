import '../../../core/offline/outbox.dart';
import 'shifts_models.dart';

/// What should be in a shift's cash drawer, in the store's currency: the
/// float it opened with, plus cash taken for sales and for debts (money
/// taken up front on pay-later sales included), minus cash handed back for
/// returns and cash spent on expenses. Cash taken in other currencies is
/// kept apart in [foreign] (it doesn't count towards the store currency).
class ShiftCashSummary {
  const ShiftCashSummary({
    required this.openingMinorUnits,
    this.cashSalesMinorUnits = 0,
    this.debtPaymentsMinorUnits = 0,
    this.refundsMinorUnits = 0,
    this.expensesMinorUnits = 0,
    this.foreign = const {},
    this.complete = true,
  });

  final int openingMinorUnits;

  /// Cash kept from sales: what was paid less the change given (a sale paid
  /// in another currency only gave change out of the drawer).
  final int cashSalesMinorUnits;
  final int debtPaymentsMinorUnits;
  final int refundsMinorUnits;
  final int expensesMinorUnits;

  /// Other currencies taken, by currency code, in that currency's minor units.
  final Map<String, int> foreign;

  /// False when worked out without a connection: changes made on other
  /// devices (or sent from here since the last connection) may be missing.
  final bool complete;

  int get expectedMinorUnits =>
      openingMinorUnits + cashSalesMinorUnits + debtPaymentsMinorUnits - refundsMinorUnits - expensesMinorUnits;

  factory ShiftCashSummary.fromJson(Map<String, dynamic> json) => ShiftCashSummary(
        openingMinorUnits: _int(json['opening_minor_units']),
        cashSalesMinorUnits: _int(json['cash_sales_minor_units']),
        debtPaymentsMinorUnits: _int(json['debt_payments_minor_units']),
        refundsMinorUnits: _int(json['refunds_minor_units']),
        expensesMinorUnits: _int(json['expenses_minor_units']),
        foreign: {
          for (final f in (json['foreign'] as List? ?? const []).cast<Map>())
            f['currency'] as String: _int(f['amount_minor_units']),
        },
      );

  Map<String, dynamic> toJson() => {
        'opening_minor_units': openingMinorUnits,
        'cash_sales_minor_units': cashSalesMinorUnits,
        'debt_payments_minor_units': debtPaymentsMinorUnits,
        'refunds_minor_units': refundsMinorUnits,
        'expenses_minor_units': expensesMinorUnits,
        'foreign': [
          for (final e in foreign.entries) {'currency': e.key, 'amount_minor_units': e.value},
        ],
      };

  ShiftCashSummary copyWith({int? openingMinorUnits, bool? complete}) => ShiftCashSummary(
        openingMinorUnits: openingMinorUnits ?? this.openingMinorUnits,
        cashSalesMinorUnits: cashSalesMinorUnits,
        debtPaymentsMinorUnits: debtPaymentsMinorUnits,
        refundsMinorUnits: refundsMinorUnits,
        expensesMinorUnits: expensesMinorUnits,
        foreign: foreign,
        complete: complete ?? this.complete,
      );

  /// This summary with the changes still waiting to be sent from this
  /// device ([ops]) that move cash in [shift]'s drawer added on.
  ShiftCashSummary withQueued(Iterable<OutboxOp> ops, ShiftRecord shift) {
    var sales = cashSalesMinorUnits;
    var debts = debtPaymentsMinorUnits;
    var refunds = refundsMinorUnits;
    var expenses = expensesMinorUnits;
    final other = Map<String, int>.of(foreign);
    for (final op in ops) {
      if (op.createdAt.isBefore(shift.openedAt)) continue;
      final p = op.params ?? const <String, dynamic>{};
      switch (op.kind) {
        case OutboxKind.checkout:
          if (p['p_shift_id'] != shift.id) continue;
          final extras = (p['p_extras'] as Map?) ?? const {};
          final change = _int(p['p_change_given_minor_units']);
          switch (p['p_payment_method']) {
            case 'cash':
              final inForeign = _int(extras['foreign_tendered_minor_units']);
              if (inForeign > 0) {
                final code = (extras['paid_currency'] as String?) ?? 'USD';
                other[code] = (other[code] ?? 0) + inForeign;
                sales -= change;
              } else if (p['p_amount_tendered_minor_units'] != null) {
                sales += _int(p['p_amount_tendered_minor_units']) - change;
              } else {
                sales += _int(op.row?['grand_total_minor_units']);
              }
            case 'payLater':
              debts += _int(extras['paid_now_minor_units']);
          }
        case OutboxKind.rpc:
          switch (op.rpc) {
            case 'record_debt_payment':
              if (p['p_payment_method'] == 'cash' && p['p_received_by_user_id'] == shift.cashierId) {
                debts += _int(p['p_amount_minor_units']);
              }
            case 'post_journal_entry':
              if (p['p_reference_type'] != 'EXPENSE' ||
                  p['p_created_by_user_id'] != shift.cashierId ||
                  p['p_branch_id'] != shift.branchId) {
                continue;
              }
              for (final l in ((p['p_lines'] as List?) ?? const []).cast<Map>()) {
                if (l['account_code'] == '1000') {
                  expenses += _int(l['credit_minor_units']) - _int(l['debit_minor_units']);
                }
              }
            case 'process_sale_return':
              if (p['p_processed_by_user_id'] == shift.cashierId && p['p_refund_to_cash'] == true) {
                refunds += _int(op.row?['refund_cash_minor_units'] ?? op.row?['refund_minor_units']);
              }
          }
        case OutboxKind.insert || OutboxKind.update:
          break;
      }
    }
    return ShiftCashSummary(
      openingMinorUnits: openingMinorUnits,
      cashSalesMinorUnits: sales,
      debtPaymentsMinorUnits: debts,
      refundsMinorUnits: refunds,
      expensesMinorUnits: expenses,
      foreign: other,
      complete: complete,
    );
  }
}

int _int(Object? v) => v is num ? v.toInt() : (v is String ? int.tryParse(v) ?? 0 : 0);
