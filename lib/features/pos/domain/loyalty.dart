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

  /// [lines] with the points discount spread over them (see [spreadDiscount]).
  static List<CartLine> applyDiscount(List<CartLine> lines, int discountMinorUnits) =>
      spreadDiscount(lines, discountMinorUnits);
}
