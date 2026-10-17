import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/theming/store_themes.dart';
import '../../../core/theming/theme_controller.dart';
import '../../../core/theming/theme_l10n.dart';
import '../../../core/theming/theme_resolution.dart';
import '../../../core/theming/theme_swatch.dart';
import '../../../core/utils/formatters.dart';
import '../domain/settings_models.dart';

/// The store's theme: a picker with a small preview of each of the twelve
/// themes (plus "Automatic" and "Light or Dark, like the device"), and what
/// is in effect — the store's own choice next to what the developer set, as
/// last synced. The choice is saved in the store's settings (sent through
/// the offline writer, so it works without a connection) and applies at
/// once. When the developer locked the theme the picker is read-only.
class ThemeSettingsSection extends ConsumerWidget {
  const ThemeSettingsSection({super.key, required this.settings});

  final AppSettingsRecord settings;

  Future<void> _choose(WidgetRef ref, String? choice) async {
    final dark = StoreThemeKey.fromDb(choice)?.palette.isDark ?? false;
    ref.read(storeThemeControllerProvider.notifier).setStoreChoice(choice);
    await ref.read(settingsRepositoryProvider).updateSettings(settings.withThemeChoice(choice, darkTheme: dark));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final state = ref.watch(storeThemeControllerProvider);
    final locked = state.lockedByDeveloper;
    final choice = settings.themeChoice;
    final developer = state.developerAssignment;
    final muted = theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant);

    Widget option({required String? value, required Widget swatch, required String label}) {
      final selected = choice == value;
      return _ThemeOption(
        selected: selected,
        enabled: !locked,
        label: label,
        swatch: swatch,
        onTap: selected ? null : () => _choose(ref, value),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.settingsTheme, style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(l10n.themeInUse(resolvedThemeName(l10n, state.resolved)), style: theme.textTheme.bodyMedium),
            const SizedBox(height: 2),
            Text(l10n.themeYourChoice(themeChoiceName(l10n, choice)), style: muted),
            Text(
              developer == null
                  ? l10n.themeDeveloperNone
                  : '${l10n.themeDeveloperSet(themeName(l10n, developer.key))}'
                      '${developer.locked ? ' · ${l10n.themeLocked}' : ''}',
              style: muted,
            ),
            Text(
              state.lastSyncedAt == null
                  ? l10n.themeNeverSynced
                  : l10n.themeLastSynced(AppDateFormat.dateTime(state.lastSyncedAt!.toLocal())),
              style: muted,
            ),
            if (locked) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lock_outline, color: theme.colorScheme.onSecondaryContainer),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n.themeLockedNote,
                        style: TextStyle(color: theme.colorScheme.onSecondaryContainer),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                option(
                  value: null,
                  label: l10n.themeAutomatic,
                  swatch: _AutomaticSwatch(tooltip: l10n.themeAutomaticHelp),
                ),
                option(value: kFollowDeviceThemeChoice, label: l10n.themeFollowDevice, swatch: ThemeSwatch.lightDark()),
                for (final key in StoreThemeKey.values)
                  option(value: key.dbKey, label: themeName(l10n, key), swatch: ThemeSwatch(palette: key.palette)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.selected,
    required this.enabled,
    required this.label,
    required this.swatch,
    required this.onTap,
  });

  final bool selected;
  final bool enabled;
  final String label;
  final Widget swatch;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Opacity(
      opacity: enabled || selected ? 1 : 0.45,
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(18),
          child: SizedBox(
            width: 124,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(17),
                    border: Border.all(color: selected ? scheme.primary : Colors.transparent, width: 2.5),
                  ),
                  child: Stack(
                    children: [
                      swatch,
                      if (selected)
                        PositionedDirectional(
                          top: 4,
                          end: 4,
                          child: Container(
                            decoration: BoxDecoration(color: scheme.primary, shape: BoxShape.circle),
                            padding: const EdgeInsets.all(2),
                            child: Icon(Icons.check, size: 14, color: scheme.onPrimary),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// "Automatic": the developer's theme or Light — drawn as a neutral tile.
class _AutomaticSwatch extends StatelessWidget {
  const _AutomaticSwatch({required this.tooltip});
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip,
      child: Container(
        width: 112,
        height: 72,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Icon(Icons.auto_awesome_outlined, color: scheme.onSurfaceVariant, size: 28),
      ),
    );
  }
}
