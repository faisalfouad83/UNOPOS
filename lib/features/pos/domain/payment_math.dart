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
