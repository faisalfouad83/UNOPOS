import 'package:flutter_test/flutter_test.dart';
import 'package:unopos/core/offline/outbox.dart';
import 'package:unopos/features/shifts/domain/shift_cash_summary.dart';
import 'package:unopos/features/shifts/domain/shifts_models.dart';

void main() {
  final opened = DateTime(2026, 10, 15, 8);
  final shift = ShiftRecord(
    id: 'shift-1',
    storeId: 's',
    branchId: 'b',
    cashierId: 'cashier',
    openedAt: opened,
    openingCashFloatMinorUnits: 10000,
  );
  final at = opened.add(const Duration(hours: 1));

  OutboxOp sale(String method, Map<String, dynamic> params, [Map<String, dynamic> extras = const {}]) => OutboxOp(
        id: 'sale-${params.hashCode}-$method',
        kind: OutboxKind.checkout,
        createdAt: at,
        params: {
          'p_shift_id': 'shift-1',
          'p_payment_method': method,
          'p_cashier_id': 'cashier',
          ...params,
          'p_extras': extras
        },
      );

  test('changes still waiting to be sent count towards the drawer', () {
    final ops = [
      // Cash 3,500 paid with 4,000.
      sale('cash', {'p_amount_tendered_minor_units': 400000, 'p_change_given_minor_units': 50000}),
      // Paid in dollars: the dollars are listed apart, the change came out of the drawer.
      sale('cash', {'p_amount_tendered_minor_units': 450000, 'p_change_given_minor_units': 100000},
          {'paid_currency': 'USD', 'foreign_tendered_minor_units': 3000}),
      // Pay later with 1,000 up front.
      sale('payLater', const {}, {'paid_now_minor_units': 100000}),
      // Card: no cash.
      sale('card', const {}),
      // Another shift's sale.
      OutboxOp(
        id: 'other',
        kind: OutboxKind.checkout,
        createdAt: at,
        params: const {'p_shift_id': 'shift-2', 'p_payment_method': 'cash', 'p_amount_tendered_minor_units': 999},
      ),
      OutboxOp(
        id: 'debt',
        kind: OutboxKind.rpc,
        rpc: 'record_debt_payment',
        createdAt: at,
        params: const {'p_payment_method': 'cash', 'p_received_by_user_id': 'cashier', 'p_amount_minor_units': 20000},
      ),
      OutboxOp(
        id: 'expense',
        kind: OutboxKind.rpc,
        rpc: 'post_journal_entry',
        createdAt: at,
        params: const {
          'p_reference_type': 'EXPENSE',
          'p_created_by_user_id': 'cashier',
          'p_branch_id': 'b',
          'p_lines': [
            {'account_code': '6040', 'debit_minor_units': 5000, 'credit_minor_units': 0},
            {'account_code': '1000', 'debit_minor_units': 0, 'credit_minor_units': 5000},
          ],
        },
      ),
      // A card expense doesn't touch the drawer.
      OutboxOp(
        id: 'expense-card',
        kind: OutboxKind.rpc,
        rpc: 'post_journal_entry',
        createdAt: at,
        params: const {
          'p_reference_type': 'EXPENSE',
          'p_created_by_user_id': 'cashier',
          'p_branch_id': 'b',
          'p_lines': [
            {'account_code': '6040', 'debit_minor_units': 7000, 'credit_minor_units': 0},
            {'account_code': '1010', 'debit_minor_units': 0, 'credit_minor_units': 7000},
          ],
        },
      ),
    ];
    final summary = const ShiftCashSummary(openingMinorUnits: 10000).withQueued(ops, shift);
    expect(summary.cashSalesMinorUnits, 350000 - 100000);
    expect(summary.debtPaymentsMinorUnits, 100000 + 20000);
    expect(summary.expensesMinorUnits, 5000);
    expect(summary.foreign, {'USD': 3000});
    expect(summary.expectedMinorUnits, 10000 + 250000 + 120000 - 5000);
  });

  test('round-trips through its stored form', () {
    const summary = ShiftCashSummary(
      openingMinorUnits: 1,
      cashSalesMinorUnits: 2,
      debtPaymentsMinorUnits: 3,
      refundsMinorUnits: 4,
      expensesMinorUnits: 5,
      foreign: {'USD': 6},
    );
    final back = ShiftCashSummary.fromJson(summary.toJson());
    expect(back.expectedMinorUnits, summary.expectedMinorUnits);
    expect(back.foreign, {'USD': 6});
  });
}
