import 'package:flutter/widgets.dart';

import '../../../core/l10n/gen/app_localizations.dart';

/// Stored on [ProductRecord.unit] as a stable code (never the translated
/// label, which changes with the app language) — 'pcs' is the existing
/// default every product already had before this list existed.
const productUnitOptions = ['pcs', 'bottle', 'carton', 'box', 'pack', 'kg', 'l'];

String productUnitLabel(BuildContext context, String code) {
  final l10n = AppLocalizations.of(context);
  return switch (code) {
    'pcs' => l10n.unitPiece,
    'bottle' => l10n.unitBottle,
    'carton' => l10n.unitCarton,
    'box' => l10n.unitBox,
    'pack' => l10n.unitPack,
    'kg' => l10n.unitKilogram,
    'l' => l10n.unitLiter,
    _ => code,
  };
}
