import 'dart:typed_data';

class ReceiptLine {
  const ReceiptLine({
    required this.name,
    required this.quantity,
    required this.unitPriceMinorUnits,
    required this.lineTotalMinorUnits,
    this.discountMinorUnits = 0,
  });

  final String name;
  final int quantity;
  final int unitPriceMinorUnits;
  final int lineTotalMinorUnits;
  final int discountMinorUnits;
}

/// The paper a receipt is laid out for: a thermal roll (58/80 mm, see
/// [ReceiptLayout.paperWidthMm]) or an A4/A5 sheet.
enum ReceiptPaper {
  thermal,
  a5,
  a4;

  static ReceiptPaper fromName(String? name) =>
      ReceiptPaper.values.where((p) => p.name == name).firstOrNull ?? ReceiptPaper.thermal;
}

/// The look of the receipt.
enum ReceiptStyle {
  classic,
  modern,
  compact;

  static ReceiptStyle fromName(String? name) =>
      ReceiptStyle.values.where((s) => s.name == name).firstOrNull ?? ReceiptStyle.classic;
}

class ReceiptLayout {
  const ReceiptLayout({this.paper = ReceiptPaper.thermal, this.style = ReceiptStyle.classic, this.paperWidthMm = 58});

  final ReceiptPaper paper;
  final ReceiptStyle style;

  /// Roll width for thermal paper (58 or 80).
  final int paperWidthMm;

  bool get isThermal => paper == ReceiptPaper.thermal;
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
    this.invoice = 'Invoice',
    this.item = 'Item',
    this.quantity = 'Qty',
    this.unitPrice = 'Price',
    this.lineTotal = 'Total',
    this.date = 'Date',
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

  /// Column headings and title used by the A4/A5 invoice.
  final String invoice;
  final String item;
  final String quantity;
  final String unitPrice;
  final String lineTotal;
  final String date;
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
    this.extraRows = const [],
    this.logoPng,
    this.layout = const ReceiptLayout(),
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

  /// Additional label/value rows printed after the payment details (e.g.
  /// the amount paid in a foreign currency and the rate used).
  final List<(String, String)> extraRows;

  /// The store's logo (PNG), printed at the top when set.
  final Uint8List? logoPng;

  /// Paper and style chosen in Settings › Printer.
  final ReceiptLayout layout;

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
    for (final (label, value) in extraRows) {
      yield label;
      yield value;
    }
  }
}
