import 'package:flutter_test/flutter_test.dart';
import 'package:unopos/core/utils/formatters.dart';

void main() {
  test('Iraqi dinar shows whole dinars with the symbol after the amount', () {
    expect(CurrencyInfo.iqd.format(1250000), '12,500 د.ع');
  });

  test('US dollar keeps cents with the symbol first', () {
    expect(CurrencyInfo.usd.format(123456), r'$1,234.56');
  });

  test('a code used as the symbol goes after the amount', () {
    expect(CurrencyInfo.iqd.format(500000, symbolOverride: 'IQD'), '5,000 IQD');
  });

  test('Money.format follows the store currency', () {
    Money.currency = CurrencyInfo.usd;
    expect(Money.format(1000), r'$10.00');
    Money.currency = CurrencyInfo.iqd;
    expect(Money.format(1000), '10 د.ع');
  });
}
