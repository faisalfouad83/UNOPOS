import '../../../core/utils/formatters.dart';

/// Quick amounts for the payment dialog, all in minor units: the exact
/// amount due first, then the total rounded up to the notes customers
/// actually hand over (IQD: 250, 500, 1,000, 5,000, 10,000, 25,000, 50,000;
/// USD: 1, 5, 10, 20, 50, 100). They only fill in the amount field — the
/// cashier still reviews it and confirms.
List<int> paymentSuggestions(int dueMinorUnits, {required String currencyCode, int max = 6}) {
  if (dueMinorUnits <= 0) return const [0];
  final notes = currencyCode.toUpperCase() == 'USD'
      ? const [1, 5, 10, 20, 50, 100]
      : const [250, 500, 1000, 5000, 10000, 25000, 50000];
  final result = <int>{dueMinorUnits};
  for (final note in notes) {
    final step = note * Money.minorUnitsPerMajor;
    final rounded = ((dueMinorUnits + step - 1) ~/ step) * step;
    if (rounded > dueMinorUnits) result.add(rounded);
  }
  final sorted = result.toList()..sort();
  return sorted.take(max).toList();
}

/// The smallest amount of [currency] that changes hands, in minor units:
/// one whole dinar for IQD (no coins below it), one cent for USD.
int cashUnitMinor(CurrencyInfo currency) => currency.decimals == 0 ? Money.minorUnitsPerMajor : 1;

/// [minorUnits] rounded (half up) to what can actually be paid in
/// [currency] — the same figure [CurrencyInfo.format] shows. A sale with a
/// percent discount or tax can come to a fraction of a dinar; what the
/// customer is asked for, and what the payment is checked against, is this.
int roundToCash(int minorUnits, CurrencyInfo currency) {
  final unit = cashUnitMinor(currency);
  if (unit == 1) return minorUnits;
  final sign = minorUnits < 0 ? -1 : 1;
  return sign * ((minorUnits.abs() + unit ~/ 2) ~/ unit) * unit;
}

/// [minorUnits] in [currency] as typed into an amount field (whole
/// numbers for zero-decimal currencies like IQD, cents for USD).
String amountInputText(int minorUnits, CurrencyInfo currency) =>
    Money.toMajorUnits(minorUnits).toStringAsFixed(currency.decimals);

/// What a cash payment comes to when the customer may pay in the store's
/// currency or the other one of the IQD/USD pair. Everything is in minor
/// units; amounts handed over are compared with the amount due rounded to
/// that currency's smallest unit, so paying exactly what is shown is always
/// enough.
class CashPayment {
  const CashPayment({
    required this.payableMinorUnits,
    required this.rate,
    this.enteredMinorUnits = 0,
    this.inForeign = false,
  });

  /// The sale total, exactly (may hold a fraction of the smallest unit).
  final int payableMinorUnits;
  final ExchangeRate rate;

  /// What was typed, in minor units of the currency it was paid in.
  final int enteredMinorUnits;
  final bool inForeign;

  /// What the customer is asked for in the store's currency.
  int get dueMinorUnits => roundToCash(payableMinorUnits, rate.storeCurrency);

  /// What the customer is asked for in the other currency.
  int get foreignDueMinorUnits => roundToCash(rate.toForeign(payableMinorUnits), rate.foreign);

  /// The amount due in the currency being paid in.
  int get dueInPaidCurrency => inForeign ? foreignDueMinorUnits : dueMinorUnits;

  bool get isPaidInFull => enteredMinorUnits >= dueInPaidCurrency;

  /// What was received, in the store's currency. Paying the foreign amount
  /// shown counts as paying the sale in full (conversion leftovers below
  /// one cent or dinar don't make it short).
  int get receivedMinorUnits {
    if (!inForeign) return enteredMinorUnits;
    final converted = rate.toStore(enteredMinorUnits);
    return isPaidInFull && converted < dueMinorUnits ? dueMinorUnits : converted;
  }

  /// Change to hand back in the store's currency, in whole units of it.
  int get changeMinorUnits {
    final over = receivedMinorUnits - dueMinorUnits;
    if (over <= 0) return 0;
    final unit = cashUnitMinor(rate.storeCurrency);
    return over ~/ unit * unit;
  }

  /// Still to pay, in the store's currency (0 once paid in full).
  int get remainingMinorUnits {
    if (isPaidInFull) return 0;
    final left = dueMinorUnits - receivedMinorUnits;
    return left < 0 ? 0 : left;
  }
}

/// What a payment comes to: change to give back when the customer paid
/// more than is due, or what is still owed when they paid less.
class PaymentBreakdown {
  const PaymentBreakdown({required this.dueMinorUnits, required this.paidMinorUnits});

  final int dueMinorUnits;
  final int paidMinorUnits;

  int get changeMinorUnits => paidMinorUnits > dueMinorUnits ? paidMinorUnits - dueMinorUnits : 0;
  int get remainingMinorUnits => paidMinorUnits < dueMinorUnits ? dueMinorUnits - paidMinorUnits : 0;
  bool get isPaidInFull => paidMinorUnits >= dueMinorUnits;
}
