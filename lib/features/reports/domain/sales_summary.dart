import '../../pos/domain/pos_models.dart';

enum ReportPeriod { today, week, month }

/// Figures for the sales dashboard over one period.
class SalesSummary {
  const SalesSummary({
    required this.salesCount,
    required this.revenueMinorUnits,
    required this.profitMinorUnits,
    required this.taxMinorUnits,
    required this.buckets,
    required this.byPaymentMethod,
    required this.topProducts,
  });

  final int salesCount;

  /// Total taken, including tax.
  final int revenueMinorUnits;

  /// Revenue excluding tax, minus the cost of the goods sold (at the cost
  /// recorded on each sale line).
  final int profitMinorUnits;
  final int taxMinorUnits;

  /// Sales per hour (today) or per day (week/month), oldest first.
  final List<SalesBucket> buckets;
  final Map<SalePaymentMethod, int> byPaymentMethod;

  /// Best sellers by revenue, highest first (at most 5).
  final List<ProductSales> topProducts;

  int get averageSaleMinorUnits => salesCount == 0 ? 0 : (revenueMinorUnits / salesCount).round();

  /// Profit as a share of revenue excluding tax, 0–1 (null with no sales).
  double? get margin {
    final net = revenueMinorUnits - taxMinorUnits;
    return net <= 0 ? null : profitMinorUnits / net;
  }

  static DateTime periodStart(ReportPeriod period, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    return switch (period) {
      ReportPeriod.today => today,
      ReportPeriod.week => today.subtract(const Duration(days: 6)),
      ReportPeriod.month => today.subtract(const Duration(days: 29)),
    };
  }

  static SalesSummary of(List<SaleRecord> sales, ReportPeriod period, {DateTime? now}) {
    final current = now ?? DateTime.now();
    final start = periodStart(period, current);

    final buckets = <SalesBucket>[
      if (period == ReportPeriod.today)
        for (var h = 0; h < 24; h++) SalesBucket(start.add(Duration(hours: h)))
      else
        for (var d = 0; d < (period == ReportPeriod.week ? 7 : 30); d++)
          SalesBucket(DateTime(start.year, start.month, start.day + d)),
    ];

    var count = 0, revenue = 0, profit = 0, tax = 0;
    final byMethod = <SalePaymentMethod, int>{};
    final productTotals = <String, ProductSales>{};

    for (final sale in sales) {
      final at = sale.completedAt ?? sale.createdAt;
      if (at.isBefore(start) || at.isAfter(current)) continue;
      // Returns are netted out of the invoice they came from; a fully
      // returned invoice no longer counts as a sale.
      final total = sale.netTotalMinorUnits;
      if (sale.status == SaleStatus.refunded) continue;
      count++;
      revenue += total;
      tax += sale.netTaxMinorUnits;
      final method = sale.paymentMethod;
      if (method != null) byMethod[method] = (byMethod[method] ?? 0) + total;

      final index = period == ReportPeriod.today
          ? at.hour
          : DateTime(at.year, at.month, at.day).difference(DateTime(start.year, start.month, start.day)).inDays;
      if (index >= 0 && index < buckets.length) buckets[index].add(total);

      for (final line in sale.lines) {
        if (line.remainingQuantity <= 0) continue;
        final net = line.netTotalMinorUnits - line.netTaxMinorUnits;
        profit += net - line.netCostMinorUnits;
        productTotals.update(
          line.productId,
          (p) => p.add(line.remainingQuantity, line.netTotalMinorUnits),
          ifAbsent: () => ProductSales(line.productId, line.remainingQuantity, line.netTotalMinorUnits),
        );
      }
    }

    final top = productTotals.values.toList()..sort((a, b) => b.revenueMinorUnits.compareTo(a.revenueMinorUnits));
    return SalesSummary(
      salesCount: count,
      revenueMinorUnits: revenue,
      profitMinorUnits: profit,
      taxMinorUnits: tax,
      buckets: buckets,
      byPaymentMethod: byMethod,
      topProducts: top.take(5).toList(),
    );
  }
}

class SalesBucket {
  SalesBucket(this.start);
  final DateTime start;
  int totalMinorUnits = 0;
  int count = 0;

  void add(int amount) {
    totalMinorUnits += amount;
    count++;
  }
}

class ProductSales {
  ProductSales(this.productId, this.quantity, this.revenueMinorUnits);
  final String productId;
  int quantity;
  int revenueMinorUnits;

  ProductSales add(int qty, int amount) {
    quantity += qty;
    revenueMinorUnits += amount;
    return this;
  }
}
