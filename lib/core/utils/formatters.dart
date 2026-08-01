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

  static String format(int minorAmount, {required String currencySymbol, String? locale}) {
    final formatter = NumberFormat.currency(
      locale: locale,
      symbol: currencySymbol,
      decimalDigits: 2,
    );
    return formatter.format(toMajorUnits(minorAmount));
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
