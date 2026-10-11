import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/security/activation_code_codec.dart';
import '../../../core/supabase/supabase_config.dart';
import '../../../core/utils/formatters.dart';
import '../domain/licensing_models.dart';

/// Generates activation codes and lists recently-issued ones. Works
/// unchanged on both backends since licensingRepositoryProvider already
/// switches between Drift and Supabase (Phase H1) — this is the entire
/// Developer Console on the local build, and the "Licenses" tab of the
/// full console on the Supabase build (see developer_console_screen.dart).
class LicenseConsole extends ConsumerStatefulWidget {
  const LicenseConsole({super.key});

  @override
  ConsumerState<LicenseConsole> createState() => _LicenseConsoleState();
}

class _LicenseConsoleState extends ConsumerState<LicenseConsole> {
  final _storeNameController = TextEditingController();
  LicenseTier _tier = LicenseTier.trial2Weeks;
  String? _lastGeneratedCode;
  List<ActivationCodeRecord> _recent = [];

  @override
  void initState() {
    super.initState();
    _loadRecent();
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    super.dispose();
  }

  Future<void> _loadRecent() async {
    final codes = await ref.read(licensingRepositoryProvider).listRecentCodes();
    if (mounted) setState(() => _recent = codes);
  }

  Future<void> _generate() async {
    final l10n = AppLocalizations.of(context);
    if (_storeNameController.text.trim().isEmpty) return;
    final record = await ref.read(licensingRepositoryProvider).generateCode(
          tier: _tier,
          storeNameRef: _storeNameController.text.trim(),
        );
    setState(() => _lastGeneratedCode = record.code);
    await _loadRecent();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.developerCodeGenerated)));
    }
  }

  /// Shortest first, so the trial options lead.
  static const _tierOrder = [
    LicenseTier.trial2Weeks,
    LicenseTier.trial1Month,
    LicenseTier.months3,
    LicenseTier.months6,
    LicenseTier.months12,
    LicenseTier.lifetime,
  ];


  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.developerGenerateCode, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _storeNameController,
                      decoration: InputDecoration(labelText: l10n.developerStoreName),
                    ),
                    const SizedBox(height: 16),
                    Text(l10n.developerLicenseTier, style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _tierOrder.map((tier) {
                        return ChoiceChip(
                          label: Text(licenseTierLabel(l10n, tier)),
                          selected: _tier == tier,
                          onSelected: (_) => setState(() => _tier = tier),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(onPressed: _generate, child: Text(l10n.developerGenerateCode)),
                    ),
                    if (_lastGeneratedCode != null) ...[
                      const SizedBox(height: 16),
                      SelectableText(
                        _lastGeneratedCode!,
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(l10n.developerRecentCodes, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (!kUseSupabaseBackend)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(l10n.developerLocalStatusNote, style: Theme.of(context).textTheme.bodySmall),
              ),
            ..._recent.map((code) => _CodeTile(code: code)),
          ],
        ),
      ),
    );
  }
}

/// One issued code: who it's for, whether it has been activated (and by
/// which store), and how long until it expires — counted from when it was
/// issued, whether or not it has been activated yet.
class _CodeTile extends StatelessWidget {
  const _CodeTile({required this.code});
  final ActivationCodeRecord code;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final days = code.daysRemaining();
    final expired = code.isExpired();
    final activated = code.isActivated;

    final (statusText, statusColor, statusIcon) = activated
        ? (
            l10n.developerCodeActivatedBy(code.redeemedByStoreName ?? code.storeNameRef),
            Colors.green.shade700,
            Icons.check_circle_outline,
          )
        : (l10n.developerCodeNotActivated, Colors.orange.shade800, Icons.hourglass_empty);
    final expiryText = code.expiresAt == null
        ? l10n.activationLifetime
        : expired
            ? l10n.developerCodeExpiredOn(AppDateFormat.shortDate(code.expiresAt!))
            : l10n.developerCodeExpiresIn(days ?? 0, AppDateFormat.shortDate(code.expiresAt!));

    return Card(
      child: ListTile(
        leading: Icon(statusIcon, color: statusColor),
        title: Text('${code.storeNameRef} · ${licenseTierLabel(l10n, code.tier)}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.w600)),
            if (activated && code.redeemedAt != null)
              Text(l10n.developerCodeActivatedOn(AppDateFormat.shortDate(code.redeemedAt!))),
            Text(expiryText, style: TextStyle(color: expired ? theme.colorScheme.error : null)),
            SelectableText(code.code, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}

String licenseTierLabel(AppLocalizations l10n, LicenseTier tier) => switch (tier) {
      LicenseTier.trial1Month => l10n.developerTier1Month,
      LicenseTier.months3 => l10n.developerTier3Months,
      LicenseTier.months6 => l10n.developerTier6Months,
      LicenseTier.months12 => l10n.developerTier12Months,
      LicenseTier.lifetime => l10n.developerTierLifetime,
      LicenseTier.trial2Weeks => l10n.developerTier2Weeks,
    };
