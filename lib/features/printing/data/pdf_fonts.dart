import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;

/// Fonts for every printed PDF (receipts, labels). The pdf package's
/// built-in Helvetica has no Arabic glyphs, so Arabic/Kurdish product and
/// store names printed as empty boxes. Noto Sans Arabic covers Arabic and
/// Kurdish Sorani; a small Latin subset of Noto Sans covers English text,
/// digits and symbols. Bundled (not downloaded) so printing works offline.
class PdfFonts {
  const PdfFonts._();

  static pw.ThemeData? _theme;
  static pw.ThemeData? _rtlTheme;

  /// [rtl]: the document is Arabic/Kurdish. Arabic letters only join up
  /// (shaping) when the Arabic font is the main font, so it leads there and
  /// Latin falls back; otherwise Latin leads.
  static Future<pw.ThemeData> theme({bool rtl = false}) async {
    final cached = rtl ? _rtlTheme : _theme;
    if (cached != null) return cached;
    Future<pw.Font> load(String name) async => pw.Font.ttf(await rootBundle.load('assets/fonts/$name.ttf'));
    final arabic = await load('NotoSansArabic-Regular');
    final arabicBold = await load('NotoSansArabic-Bold');
    final latin = await load('NotoSansLatin-Regular');
    final latinBold = await load('NotoSansLatin-Bold');
    if (rtl) {
      return _rtlTheme = pw.ThemeData.withFont(base: arabic, bold: arabicBold, fontFallback: [latin, latinBold]);
    }
    return _theme = pw.ThemeData.withFont(base: latin, bold: latinBold, fontFallback: [arabic, arabicBold]);
  }

  static final RegExp _rtlChars = RegExp(r'[֐-ࣿיִ-﷿ﹰ-﻿]');

  static bool hasRtl(String text) => _rtlChars.hasMatch(text);

  /// Right-to-left for text containing Arabic script, so mixed lines like
  /// "شاي x2" read in the right order.
  static pw.TextDirection directionFor(String text) => hasRtl(text) ? pw.TextDirection.rtl : pw.TextDirection.ltr;
}
