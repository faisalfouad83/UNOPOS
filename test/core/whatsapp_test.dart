import 'package:flutter_test/flutter_test.dart';
import 'package:unopos/core/utils/formatters.dart';
import 'package:unopos/core/utils/whatsapp.dart';
import 'package:unopos/features/printing/domain/receipt_models.dart';
import 'package:unopos/features/printing/domain/receipt_text.dart';

void main() {
  test('Iraqi numbers are normalized for wa.me', () {
    expect(WhatsApp.normalizePhone('0770 123 4567'), '9647701234567');
    expect(WhatsApp.normalizePhone('+964 770 123 4567'), '9647701234567');
    expect(WhatsApp.normalizePhone('00964-770-123-4567'), '9647701234567');
    expect(WhatsApp.normalizePhone('٠٧٧٠١٢٣٤٥٦٧'), '9647701234567');
    expect(WhatsApp.normalizePhone('123'), isNull);
  });

  test('the link carries the encoded message', () {
    expect(WhatsApp.link('9647701234567', 'شكراً & 1').toString(),
        'https://wa.me/9647701234567?text=%D8%B4%D9%83%D8%B1%D8%A7%D9%8B%20%26%201');
  });

  test('plain-text receipt lists items and total', () {
    Money.currency = CurrencyInfo.iqd;
    final text = receiptPlainText(ReceiptDocument(
      storeName: 'متجر',
      branchName: '',
      saleNumber: 'S-1',
      dateTime: DateTime(2026, 10, 11, 9),
      cashierName: 'Ali',
      lines: const [ReceiptLine(name: 'شاي', quantity: 2, unitPriceMinorUnits: 150000, lineTotalMinorUnits: 300000)],
      subtotalMinorUnits: 300000,
      discountTotalMinorUnits: 0,
      taxTotalMinorUnits: 0,
      grandTotalMinorUnits: 300000,
      paymentMethodLabel: 'نقداً',
      currencySymbol: 'د.ع',
      labels: const ReceiptLabels(total: 'المجموع'),
    ));
    expect(text, contains('شاي  ×2  3,000 د.ع'));
    expect(text, contains('*المجموع: 3,000 د.ع*'));
  });
}
