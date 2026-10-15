import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/roles.dart';
import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../home/presentation/home_shell.dart';
import '../../settings/domain/settings_models.dart';
import '../../../core/widgets/adaptive_row.dart';

/// Settings › Breaks (owner/manager): on/off, minutes per break, breaks per
/// employee per day, and which roles may take them.
class BreakSettingsSection extends ConsumerStatefulWidget {
  const BreakSettingsSection({super.key, required this.settings});
  final AppSettingsRecord settings;

  @override
  ConsumerState<BreakSettingsSection> createState() => _BreakSettingsSectionState();
}

class _BreakSettingsSectionState extends ConsumerState<BreakSettingsSection> {
  late final _minutes = TextEditingController(text: '${widget.settings.breakMaxMinutes}');
  late final _perDay = TextEditingController(text: '${widget.settings.breakMaxPerDay}');
  String? _minutesError;
  String? _perDayError;

  @override
  void dispose() {
    _minutes.dispose();
    _perDay.dispose();
    super.dispose();
  }

  Future<void> _save(AppSettingsRecord s) => ref.read(settingsRepositoryProvider).updateSettings(s);

  Future<void> _saveLimits() async {
    final l10n = AppLocalizations.of(context);
    final minutes = int.tryParse(_minutes.text);
    final perDay = int.tryParse(_perDay.text);
    setState(() {
      _minutesError = minutes == null || minutes < 1 || minutes > 240 ? l10n.breakMinutesRange : null;
      _perDayError = perDay == null || perDay < 1 || perDay > 10 ? l10n.breakPerDayRange : null;
    });
    if (_minutesError != null || _perDayError != null) return;
    await _save(widget.settings.copyWith(breakMaxMinutes: minutes, breakMaxPerDay: perDay));
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.settingsSaved)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final s = widget.settings;
    final roles = s.breakRoleNames;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.breakSettingsTitle, style: Theme.of(context).textTheme.titleMedium),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.breakEnable),
              subtitle: Text(l10n.breakEnableHelp),
              value: s.breakEnabled,
              onChanged: (v) => _save(s.copyWith(breakEnabled: v)),
            ),
            if (s.breakEnabled) ...[
              const SizedBox(height: 8),
              AdaptiveRow(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _minutes,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(labelText: l10n.breakMaxMinutes, errorText: _minutesError),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _perDay,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(labelText: l10n.breakMaxPerDay, errorText: _perDayError),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: FilledButton(onPressed: _saveLimits, child: Text(l10n.actionSave)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(l10n.breakRolesTitle, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                children: [
                  for (final role in [StoreRole.cashier, StoreRole.warehouseManager, StoreRole.manager])
                    FilterChip(
                      label: Text(roleLabel(l10n, SessionRole.fromStoreRole(role))),
                      selected: roles.contains(role.name),
                      onSelected: (on) {
                        final next = {...roles};
                        on ? next.add(role.name) : next.remove(role.name);
                        _save(s.copyWith(breakRoles: next.join(',')));
                      },
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
