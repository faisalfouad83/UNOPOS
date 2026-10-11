import 'package:intl/intl.dart';

/// Money is stored as integer minor units (e.g. fils/cents) everywhere in
/// the domain and database layers to avoid floating-point rounding bugs in
/// the accounting engine. These helpers convert to/from that representation
/// purely for display and user input.
class Money {
  const Money._();

  static const int minorUnitsPerMajor = 100;

  static int toMinorUnits(double majorAmount) => (majorAmount * minorUnitsPerMajor).round();

  static double toMajorUnits(int minorAmount) => minorAmount / minorUnitsPerMajor;

  /// The store's currency, kept in sync with its Settings by the app root
  /// so every screen and receipt formats money the same way without each
  /// call site needing to look the setting up.
  static CurrencyInfo currency = CurrencyInfo.iqd;

  /// Formats [minorAmount] in [currency]. [currencySymbol] overrides only
  /// the symbol (e.g. ASCII-only thermal printers).
  static String format(int minorAmount, {String? currencySymbol, String? locale}) {
    return currency.format(minorAmount, symbolOverride: currencySymbol);
  }
}

class CurrencyInfo {
  const CurrencyInfo(this.code, this.symbol);

  static const CurrencyInfo iqd = CurrencyInfo('IQD', 'د.ع');
  static const CurrencyInfo usd = CurrencyInfo('USD', r'$');

  final String code;
  final String symbol;

  /// Iraqi dinar has no fractional coins in circulation, so prices are
  /// shown as whole dinars; stored values stay in minor units regardless.
  static const Set<String> _zeroDecimalCodes = {'IQD', 'IRR', 'JPY', 'KRW'};

  int get decimals => _zeroDecimalCodes.contains(code.toUpperCase()) ? 0 : 2;

  String format(int minorAmount, {String? symbolOverride}) {
    final digits = decimals;
    final number = NumberFormat(digits == 0 ? '#,##0' : '#,##0.00', 'en').format(
      digits == 0 ? (minorAmount / Money.minorUnitsPerMajor).round() : Money.toMajorUnits(minorAmount),
    );
    final sym = symbolOverride ?? symbol;
    if (sym.isEmpty) return number;
    // Single-character symbols ($, €) lead the amount; codes and Arabic
    // symbols (IQD, د.ع) follow it, as they're written locally.
    final leads = sym.length == 1;
    return leads ? '$sym$number' : '$number $sym';
  }
}

class AppDateFormat {
  const AppDateFormat._();

  static String shortDate(DateTime date, {String? locale}) =>
      DateFormat.yMMMd(locale).format(date);

  static String dateTime(DateTime date, {String? locale}) =>
      DateFormat.yMMMd(locale).add_jm().format(date);

  static String time(DateTime date, {String? locale}) => DateFormat.jm(locale).format(date);
}
