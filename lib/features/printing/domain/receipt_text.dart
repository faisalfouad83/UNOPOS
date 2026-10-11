import '../../../core/utils/formatters.dart';
import 'receipt_models.dart';

/// The receipt as plain text, for sending as a message (WhatsApp).
String receiptPlainText(ReceiptDocument doc) {
  String money(int minor) => Money.format(minor, currencySymbol: doc.currencySymbol);
  final l = doc.labels;
  final b = StringBuffer()
    ..writeln('*${doc.storeName}*')
    ..writeln('${l.sale}: ${doc.saleNumber}')
    ..writeln(AppDateFormat.dateTime(doc.dateTime))
    ..writeln();
  for (final line in doc.lines) {
    b.writeln('${line.name}  ×${line.quantity}  ${money(line.lineTotalMinorUnits)}');
  }
  b.writeln();
  if (doc.discountTotalMinorUnits > 0) b.writeln('${l.discount}: -${money(doc.discountTotalMinorUnits)}');
  if (doc.taxTotalMinorUnits > 0) b.writeln('${l.tax}: ${money(doc.taxTotalMinorUnits)}');
  b
    ..writeln('*${l.total}: ${money(doc.grandTotalMinorUnits)}*')
    ..writeln('${l.payment}: ${doc.paymentMethodLabel}');
  for (final (label, value) in doc.extraRows) {
    b.writeln('$label: $value');
  }
  if (doc.isPayLater) b.writeln(l.payLaterBanner);
  b
    ..writeln()
    ..write(doc.footerText);
  return b.toString();
}
