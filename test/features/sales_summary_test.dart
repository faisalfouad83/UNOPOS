import 'package:flutter_test/flutter_test.dart';
import 'package:unopos/features/pos/domain/pos_models.dart';
import 'package:unopos/features/reports/domain/sales_summary.dart';

SaleRecord _sale(String id, DateTime at, SalePaymentMethod method, List<SaleLineRecord> lines) => SaleRecord(
      id: id,
      storeId: 's',
      branchId: 'b',
      saleNumber: id,
      status: SaleStatus.completed,
      cashierId: 'c',
      createdAt: at,
      completedAt: at,
      paymentMethod: method,
      grandTotalMinorUnits: lines.fold(0, (s, l) => s + l.lineTotalMinorUnits),
      taxTotalMinorUnits: lines.fold(0, (s, l) => s + l.taxAmountMinorUnits),
      lines: lines,
    );

SaleLineRecord _line(String product, int qty, int unit, int cost, {int tax = 0}) => SaleLineRecord(
      id: '$product$qty',
      saleId: 'x',
      productId: product,
      quantity: qty,
      unitPriceMinorUnits: unit,
      taxAmountMinorUnits: tax,
      lineTotalMinorUnits: unit * qty + tax,
      costPriceSnapshotMinorUnits: cost,
    );

void main() {
  final now = DateTime(2026, 10, 11, 18);
  final sales = [
    _sale('a', DateTime(2026, 10, 11, 9, 15), SalePaymentMethod.cash, [_line('tea', 2, 3000, 2000)]),
    _sale('b', DateTime(2026, 10, 11, 9, 45), SalePaymentMethod.card, [_line('sugar', 1, 1500, 1000, tax: 150)]),
    _sale('c', DateTime(2026, 10, 9, 12), SalePaymentMethod.cash, [_line('tea', 10, 3000, 2000)]),
    _sale('old', DateTime(2026, 8, 1), SalePaymentMethod.cash, [_line('tea', 1, 3000, 2000)]),
  ];

  test('today: totals, profit excluding tax, and hourly buckets', () {
    final s = SalesSummary.of(sales, ReportPeriod.today, now: now);
    expect(s.salesCount, 2);
    expect(s.revenueMinorUnits, 7650);
    expect(s.profitMinorUnits, (6000 - 4000) + (1500 - 1000));
    expect(s.margin, closeTo(2500 / 7500, 1e-9));
    expect(s.buckets, hasLength(24));
    expect(s.buckets[9].totalMinorUnits, 7650);
    expect(s.buckets[9].count, 2);
    expect(s.byPaymentMethod, {SalePaymentMethod.cash: 6000, SalePaymentMethod.card: 1650});
  });

  test('week: daily buckets and top products by revenue', () {
    final s = SalesSummary.of(sales, ReportPeriod.week, now: now);
    expect(s.salesCount, 3, reason: 'the August sale is outside the week');
    expect(s.buckets, hasLength(7));
    expect(s.buckets.last.totalMinorUnits, 7650);
    expect(s.buckets[4].totalMinorUnits, 30000); // Oct 9
    expect(s.topProducts.first.productId, 'tea');
    expect(s.topProducts.first.quantity, 12);
  });

  test('no sales gives zeros, not errors', () {
    final s = SalesSummary.of(const [], ReportPeriod.month, now: now);
    expect((s.salesCount, s.revenueMinorUnits, s.averageSaleMinorUnits, s.margin), (0, 0, 0, null));
    expect(s.buckets, hasLength(30));
  });
}
