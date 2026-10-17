import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/theming/store_themes.dart';
import '../../../core/theming/theme_assignment_repository.dart';
import '../../../core/theming/theme_l10n.dart';
import '../../../core/theming/theme_resolution.dart';
import '../../../core/theming/theme_swatch.dart';
import '../domain/developer_models.dart';

// Developer-managed themes: a theme for every store and for single stores,
// each optionally locked so the store can't choose another one. How the
// store's app combines these with its own choice is documented on
// resolveStoreTheme() (theme_resolution.dart). There is no grouping of
// stores in UNOPOS, so assignments are global or per store only.

final _assignmentsProvider = StreamProvider.autoDispose<List<ThemeAssignment>>((ref) {
  final repo = ref.watch(themeAssignmentRepositoryProvider);
  if (repo == null) return Stream.value(const []);
  return repo.watchAll();
});

final _storeChoicesProvider = FutureProvider.autoDispose<Map<String, String?>>((ref) async {
  final repo = ref.watch(themeAssignmentRepositoryProvider);
  if (repo == null) return const {};
  final rows = await repo.fetchStoreChoices();
  return {for (final r in rows) r.storeId: r.choice};
});

final _themeStoresProvider = StreamProvider.autoDispose<List<DeveloperStoreRecord>>((ref) {
  final repo = ref.watch(developerRepositoryProvider);
  if (repo == null) return Stream.value(const []);
  return repo.watchStores();
});

class ThemeAssignmentsTab extends ConsumerStatefulWidget {
  const ThemeAssignmentsTab({super.key});

  @override
  ConsumerState<ThemeAssignmentsTab> createState() => _ThemeAssignmentsTabState();
}

class _ThemeAssignmentsTabState extends ConsumerState<ThemeAssignmentsTab> {
  String _query = '';

  Future<void> _run(Future<void> Function() action) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await action();
      messenger.showSnackBar(SnackBar(content: Text(l10n.themeDevSaved)));
      ref.invalidate(_storeChoicesProvider);
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.errorWithDetails('$e'))));
    }
  }

  Future<void> _assign(String scope, ThemeAssignment? current) async {
    final repo = ref.read(themeAssignmentRepositoryProvider);
    if (repo == null) return;
    final picked = await showDialog<(StoreThemeKey, bool)>(
      context: context,
      builder: (_) => _AssignThemeDialog(initialKey: current?.key, initialLocked: current?.locked ?? false),
    );
    if (picked == null) return;
    await _run(() => repo.setAssignment(scope: scope, key: picked.$1, locked: picked.$2));
  }

  Future<void> _clear(String scope) async {
    final repo = ref.read(themeAssignmentRepositoryProvider);
    if (repo == null) return;
    await _run(() => repo.clearAssignment(scope));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final assignmentsAsync = ref.watch(_assignmentsProvider);
    final storesAsync = ref.watch(_themeStoresProvider);
    final choices = ref.watch(_storeChoicesProvider).valueOrNull ?? const {};

    if (assignmentsAsync.hasError) return Center(child: Text(l10n.errorWithDetails('${assignmentsAsync.error}')));
    if (storesAsync.hasError) return Center(child: Text(l10n.errorWithDetails('${storesAsync.error}')));
    final assignments = assignmentsAsync.valueOrNull;
    final stores = storesAsync.valueOrNull;
    if (assignments == null || stores == null) return const Center(child: CircularProgressIndicator());

    final byScope = {for (final a in assignments) a.scope: a};
    final global = byScope[ThemeAssignment.globalScope];
    final q = _query.trim().toLowerCase();
    final shown = q.isEmpty
        ? stores
        : stores
            .where((s) => s.displayName.toLowerCase().contains(q) || s.storeLoginId.toLowerCase().contains(q))
            .toList();

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(_storeChoicesProvider),
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _AssignmentCard(
            title: l10n.themeDevGlobal,
            subtitle: l10n.themeDevGlobalHelp,
            assignment: global,
            onAssign: () => _assign(ThemeAssignment.globalScope, global),
            onClear: global == null ? null : () => _clear(ThemeAssignment.globalScope),
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: l10n.themeDevSearch),
            onChanged: (v) => setState(() => _query = v),
          ),
          const SizedBox(height: 12),
          for (final store in shown) ...[
            _StoreThemeCard(
              store: store,
              assignment: byScope[store.id],
              global: global,
              storeChoice: choices[store.id],
              onAssign: () => _assign(store.id, byScope[store.id]),
              onClear: byScope[store.id] == null ? null : () => _clear(store.id),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _AssignmentCard extends StatelessWidget {
  const _AssignmentCard({
    required this.title,
    required this.subtitle,
    required this.assignment,
    required this.onAssign,
    required this.onClear,
  });

  final String title;
  final String subtitle;
  final ThemeAssignment? assignment;
  final VoidCallback onAssign;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final a = assignment;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 16,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (a != null) ThemeSwatch(palette: a.key.palette, width: 96, height: 62),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleMedium),
                  Text(subtitle, style: theme.textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Text(a == null ? l10n.themeDevNotSet : themeName(l10n, a.key), style: theme.textTheme.bodyLarge),
                  if (a?.locked ?? false) _LockedChip(label: l10n.themeLocked),
                ],
              ),
            ),
            _Actions(onAssign: onAssign, onClear: onClear),
          ],
        ),
      ),
    );
  }
}

class _StoreThemeCard extends StatelessWidget {
  const _StoreThemeCard({
    required this.store,
    required this.assignment,
    required this.global,
    required this.storeChoice,
    required this.onAssign,
    required this.onClear,
  });

  final DeveloperStoreRecord store;
  final ThemeAssignment? assignment;
  final ThemeAssignment? global;
  final String? storeChoice;
  final VoidCallback onAssign;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final resolved = resolveStoreTheme(storeAssignment: assignment, globalAssignment: global, storeChoice: storeChoice);
    final muted = theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 16,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            resolved.key == null
                ? ThemeSwatch.lightDark(width: 80, height: 52)
                : ThemeSwatch(palette: resolved.key!.palette, width: 80, height: 52),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${store.displayName} (${store.storeLoginId})', style: theme.textTheme.titleSmall),
                  Text(
                    l10n.themeDevAssigned(assignment == null ? l10n.themeDevNotSet : themeName(l10n, assignment!.key)),
                    style: muted,
                  ),
                  Text(l10n.themeDevStoreChoice(themeChoiceName(l10n, storeChoice)), style: muted),
                  Text(l10n.themeDevShowing(resolvedThemeName(l10n, resolved)), style: muted),
                  if (assignment?.locked ?? false) _LockedChip(label: l10n.themeLocked),
                ],
              ),
            ),
            _Actions(onAssign: onAssign, onClear: onClear),
          ],
        ),
      ),
    );
  }
}

class _LockedChip extends StatelessWidget {
  const _LockedChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock_outline, size: 16, color: scheme.primary),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({required this.onAssign, required this.onClear});
  final VoidCallback onAssign;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Wrap(
      spacing: 8,
      children: [
        FilledButton.tonalIcon(
            onPressed: onAssign, icon: const Icon(Icons.palette_outlined), label: Text(l10n.themeDevAssign)),
        if (onClear != null) TextButton(onPressed: onClear, child: Text(l10n.themeDevRemove)),
      ],
    );
  }
}

/// Picks a theme and whether it is locked.
class _AssignThemeDialog extends StatefulWidget {
  const _AssignThemeDialog({required this.initialKey, required this.initialLocked});
  final StoreThemeKey? initialKey;
  final bool initialLocked;

  @override
  State<_AssignThemeDialog> createState() => _AssignThemeDialogState();
}

class _AssignThemeDialogState extends State<_AssignThemeDialog> {
  late StoreThemeKey _key = widget.initialKey ?? StoreThemeKey.light;
  late bool _locked = widget.initialLocked;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: Text(l10n.themeDevAssign),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final key in StoreThemeKey.values)
                    InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => setState(() => _key = key),
                      child: Container(
                        width: 108,
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: key == _key ? scheme.primary : Colors.transparent, width: 2.5),
                        ),
                        child: Column(
                          children: [
                            ThemeSwatch(palette: key.palette, width: 98, height: 62),
                            const SizedBox(height: 2),
                            Text(themeName(l10n, key), maxLines: 2, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.themeDevLock),
                value: _locked,
                onChanged: (v) => setState(() => _locked = v),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.actionCancel)),
        FilledButton(onPressed: () => Navigator.pop(context, (_key, _locked)), child: Text(l10n.actionSave)),
      ],
    );
  }
}
