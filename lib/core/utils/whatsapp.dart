import 'package:url_launcher/url_launcher.dart';

/// Sending text to a customer's WhatsApp (receipts, debt reminders) via a
/// wa.me link — opens WhatsApp (app or web) with the message ready to send,
/// so nothing goes out without the cashier pressing send.
class WhatsApp {
  const WhatsApp._();

  /// International digits for wa.me. Local Iraqi mobile numbers
  /// (07xx xxx xxxx) get the 964 country code; numbers already in
  /// international form (+964…, 00964…) are kept. Null if unusable.
  static String? normalizePhone(String raw, {String defaultCountryCode = '964'}) {
    const arabicDigits = '٠١٢٣٤٥٦٧٨٩';
    final digits = StringBuffer();
    for (final ch in raw.trim().split('')) {
      final a = arabicDigits.indexOf(ch);
      if (a >= 0) {
        digits.write(a);
      } else if (RegExp(r'\d').hasMatch(ch)) {
        digits.write(ch);
      }
    }
    var number = digits.toString();
    if (number.startsWith('00')) number = number.substring(2);
    if (number.startsWith('0')) number = '$defaultCountryCode${number.substring(1)}';
    if (number.length < 10 || number.length > 15) return null;
    return number;
  }

  static Uri link(String phoneDigits, String message) =>
      Uri.parse('https://wa.me/$phoneDigits?text=${Uri.encodeComponent(message)}');

  /// Opens WhatsApp with [message] addressed to [phone]. False when the
  /// number is unusable or nothing could open the link.
  static Future<bool> send(String phone, String message) async {
    final number = normalizePhone(phone);
    if (number == null) return false;
    return launchUrl(link(number, message), mode: LaunchMode.externalApplication);
  }
}
