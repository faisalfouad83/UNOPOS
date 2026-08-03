import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Flutter's own bundled Material/Cupertino/Widgets translations don't cover
/// Kurdish Sorani ('ckb') — GlobalMaterialLocalizations.delegate.load(ckb)
/// (and the Widgets/Cupertino equivalents) unconditionally end in
/// `getXTranslation(...)!`, and that lookup returns null for any language
/// outside the SDK's own supported-language list, so the `!` throws a
/// null-check error the instant a user picks Kurdish — inside
/// Localizations' own internal Future, where no try/catch in app code can
/// reach it, taking down the whole widget tree (a blank screen, no error
/// UI). Our own AppLocalizations strings ARE fully translated for 'ckb'
/// (see app_ckb.arb) — only Flutter's small set of built-in widget strings
/// (date picker "OK"/"CANCEL", etc.) have no Kurdish translation to fall
/// back to, so those degrade to Arabic (same RTL script, closest available)
/// instead of crashing.
class KurdishFallbackMaterialLocalizationsDelegate extends LocalizationsDelegate<MaterialLocalizations> {
  const KurdishFallbackMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      locale.languageCode == 'ckb' || GlobalMaterialLocalizations.delegate.isSupported(locale);

  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      GlobalMaterialLocalizations.delegate.load(locale.languageCode == 'ckb' ? const Locale('ar') : locale);

  @override
  bool shouldReload(covariant LocalizationsDelegate<MaterialLocalizations> old) => false;
}

class KurdishFallbackCupertinoLocalizationsDelegate extends LocalizationsDelegate<CupertinoLocalizations> {
  const KurdishFallbackCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      locale.languageCode == 'ckb' || GlobalCupertinoLocalizations.delegate.isSupported(locale);

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      GlobalCupertinoLocalizations.delegate.load(locale.languageCode == 'ckb' ? const Locale('ar') : locale);

  @override
  bool shouldReload(covariant LocalizationsDelegate<CupertinoLocalizations> old) => false;
}

class KurdishFallbackWidgetsLocalizationsDelegate extends LocalizationsDelegate<WidgetsLocalizations> {
  const KurdishFallbackWidgetsLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      locale.languageCode == 'ckb' || GlobalWidgetsLocalizations.delegate.isSupported(locale);

  @override
  Future<WidgetsLocalizations> load(Locale locale) =>
      GlobalWidgetsLocalizations.delegate.load(locale.languageCode == 'ckb' ? const Locale('ar') : locale);

  @override
  bool shouldReload(covariant LocalizationsDelegate<WidgetsLocalizations> old) => false;
}
