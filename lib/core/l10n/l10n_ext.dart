import 'package:flutter/widgets.dart';

import 'gen/app_localizations.dart';

extension AppLocalizationsContext on BuildContext {
  /// Shorthand for `AppLocalizations.of(context)`.
  AppLocalizations get l10n => AppLocalizations.of(this);
}
