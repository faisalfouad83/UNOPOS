class ReceiptLine {
  const ReceiptLine({
    required this.name,
    required this.quantity,
    required this.unitPriceMinorUnits,
    required this.lineTotalMinorUnits,
  });

  final String name;
  final int quantity;
  final int unitPriceMinorUnits;
  final int lineTotalMinorUnits;
}

/// The fixed captions printed on a receipt, so it can be printed in the
/// store's language. Defaults to English.
class ReceiptLabels {
  const ReceiptLabels({
    this.sale = 'Sale',
    this.cashier = 'Cashier',
    this.customer = 'Customer',
    this.subtotal = 'Subtotal',
    this.discount = 'Discount',
    this.tax = 'Tax',
    this.total = 'TOTAL',
    this.payment = 'Payment',
    this.tendered = 'Tendered',
    this.change = 'Change',
    this.payLaterBanner = '*** ON ACCOUNT / PAY LATER ***',
    this.cash = 'Cash',
    this.card = 'Card',
    this.payLater = 'Pay Later',
  });

  final String sale;
  final String cashier;
  final String customer;
  final String subtotal;
  final String discount;
  final String tax;
  final String total;
  final String payment;
  final String tendered;
  final String change;
  final String payLaterBanner;
  final String cash;
  final String card;
  final String payLater;
}

/// Driver-agnostic receipt content — every printer driver renders this same
/// document differently (raw ESC/POS bytes vs a PDF page).
class ReceiptDocument {
  const ReceiptDocument({
    required this.storeName,
    required this.branchName,
    this.branchPhone = '',
    this.branchAddress = '',
    required this.saleNumber,
    required this.dateTime,
    required this.cashierName,
    this.customerName,
    required this.lines,
    required this.subtotalMinorUnits,
    required this.discountTotalMinorUnits,
    required this.taxTotalMinorUnits,
    required this.grandTotalMinorUnits,
    required this.paymentMethodLabel,
    this.amountTenderedMinorUnits,
    this.changeGivenMinorUnits,
    this.isPayLater = false,
    required this.currencySymbol,
    this.footerText = 'Thank you!',
    this.labels = const ReceiptLabels(),
  });

  final String storeName;
  final String branchName;
  final String branchPhone;
  final String branchAddress;
  final String saleNumber;
  final DateTime dateTime;
  final String cashierName;
  final String? customerName;
  final List<ReceiptLine> lines;
  final int subtotalMinorUnits;
  final int discountTotalMinorUnits;
  final int taxTotalMinorUnits;
  final int grandTotalMinorUnits;
  final String paymentMethodLabel;
  final int? amountTenderedMinorUnits;
  final int? changeGivenMinorUnits;
  final bool isPayLater;
  final String currencySymbol;
  final String footerText;
  final ReceiptLabels labels;

  /// Every piece of text the receipt prints, for deciding whether it can go
  /// out as plain printer text or needs rendering (e.g. Arabic).
  Iterable<String> get allText sync* {
    yield storeName;
    yield branchName;
    yield branchPhone;
    yield branchAddress;
    yield cashierName;
    if (customerName != null) yield customerName!;
    for (final line in lines) {
      yield line.name;
    }
    yield paymentMethodLabel;
    yield currencySymbol;
    yield footerText;
    yield labels.sale;
    yield labels.cashier;
    yield labels.subtotal;
    yield labels.total;
    yield labels.payLaterBanner;
  }
}
