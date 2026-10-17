import '../l10n/gen/app_localizations.dart';
import 'store_themes.dart';
import 'theme_resolution.dart';

/// The name of a theme in the current language.
String themeName(AppLocalizations l10n, StoreThemeKey key) => switch (key) {
      StoreThemeKey.light => l10n.themeNameLight,
      StoreThemeKey.dark => l10n.themeNameDark,
      StoreThemeKey.christmas => l10n.themeNameChristmas,
      StoreThemeKey.halloween => l10n.themeNameHalloween,
      StoreThemeKey.eidAlFitr => l10n.themeNameEidAlFitr,
      StoreThemeKey.eidAlAdha => l10n.themeNameEidAlAdha,
      StoreThemeKey.nowruz => l10n.themeNameNowruz,
      StoreThemeKey.ramadan => l10n.themeNameRamadan,
      StoreThemeKey.summer => l10n.themeNameSummer,
      StoreThemeKey.autumn => l10n.themeNameAutumn,
      StoreThemeKey.spring => l10n.themeNameSpring,
      StoreThemeKey.winter => l10n.themeNameWinter,
    };

/// The name of a store's theme choice: a theme, "follow the device", or
/// "Automatic" (null or unknown).
String themeChoiceName(AppLocalizations l10n, String? choice) {
  if (choice == kFollowDeviceThemeChoice) return l10n.themeFollowDevice;
  final key = StoreThemeKey.fromDb(choice);
  return key == null ? l10n.themeAutomatic : themeName(l10n, key);
}

/// The name of the theme in effect.
String resolvedThemeName(AppLocalizations l10n, ResolvedTheme resolved) =>
    resolved.key == null ? l10n.themeFollowDevice : themeName(l10n, resolved.key!);
