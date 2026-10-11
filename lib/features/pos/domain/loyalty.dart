import '../presentation/cart_controller.dart';

/// Loyalty-point arithmetic shared by the till and the local checkout.
/// The shared backend repeats the earn/redeem part in checkout_sale_once.
class Loyalty {
  const Loyalty._();

  /// Points earned on a sale of [totalMinorUnits]: one per full
  /// [spendPerPointMinor] spent (0 when loyalty is off).
  static int pointsEarned(int totalMinorUnits, int spendPerPointMinor) =>
      spendPerPointMinor <= 0 || totalMinorUnits <= 0 ? 0 : totalMinorUnits ~/ spendPerPointMinor;

  /// The most points that can go towards a sale: limited by the balance and
  /// by the sale total (a sale can't go below zero).
  static int maxRedeemable({required int balance, required int pointValueMinor, required int payableMinorUnits}) {
    if (pointValueMinor <= 0 || balance <= 0 || payableMinorUnits <= 0) return 0;
    final byTotal = payableMinorUnits ~/ pointValueMinor;
    return balance < byTotal ? balance : byTotal;
  }

  /// [lines] with [discountMinorUnits] spread over them in proportion to
  /// each line's price after its own discount, so tax and revenue are
  /// recomputed exactly as for any other discount. Rounding leftovers go to
  /// the largest line.
  static List<CartLine> applyDiscount(List<CartLine> lines, int discountMinorUnits) {
    if (discountMinorUnits <= 0 || lines.isEmpty) return lines;
    final bases = <int>[for (final l in lines) l.grossMinorUnits - l.discountAmountMinorUnits];
    final total = bases.fold<int>(0, (a, b) => a + b);
    if (total <= 0) return lines;
    final amount = discountMinorUnits > total ? total : discountMinorUnits;

    final shares = <int>[for (final b in bases) amount * b ~/ total];
    final leftover = amount - shares.fold<int>(0, (a, b) => a + b);
    var largest = 0;
    for (var i = 1; i < bases.length; i++) {
      if (bases[i] > bases[largest]) largest = i;
    }
    shares[largest] += leftover;

    return [
      for (var i = 0; i < lines.length; i++)
        lines[i].copyWith(discountAmountMinorUnits: lines[i].discountAmountMinorUnits + shares[i]),
    ];
  }
}
