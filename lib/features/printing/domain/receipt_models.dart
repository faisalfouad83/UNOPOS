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
}
