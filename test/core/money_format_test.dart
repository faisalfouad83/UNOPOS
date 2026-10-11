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

  test('exchange rate converts dollars to dinars and back', () {
    const rate = ExchangeRate(storeCurrency: CurrencyInfo.iqd, iqdPerUsd: 1500);
    expect(rate.foreign.code, 'USD');
    expect(rate.toStore(2000), 3000000); // $20 -> 30,000 IQD
    expect(rate.toForeign(3000000), 2000);
    expect(rate.label, '1 USD = 1,500 IQD');
  });

  test('a dollar store converts dinars the other way', () {
    const rate = ExchangeRate(storeCurrency: CurrencyInfo.usd, iqdPerUsd: 1500);
    expect(rate.foreign.code, 'IQD');
    expect(rate.toStore(1500000), 1000); // 15,000 IQD -> $10
  });
}
