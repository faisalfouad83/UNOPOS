import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/security/activation_code_codec.dart';
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
  LicenseTier _tier = LicenseTier.trial1Month;
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

  static String tierLabel(AppLocalizations l10n, LicenseTier tier) => switch (tier) {
        LicenseTier.trial1Month => l10n.developerTier1Month,
        LicenseTier.months3 => l10n.developerTier3Months,
        LicenseTier.months6 => l10n.developerTier6Months,
        LicenseTier.months12 => l10n.developerTier12Months,
        LicenseTier.lifetime => l10n.developerTierLifetime,
      };

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
                      children: LicenseTier.values.map((tier) {
                        return ChoiceChip(
                          label: Text(tierLabel(l10n, tier)),
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
            ..._recent.map((code) => Card(
                  child: ListTile(
                    title: Text(code.code, style: const TextStyle(fontFamily: 'monospace', fontSize: 13)),
                    subtitle: Text(
                      '${code.storeNameRef} · ${tierLabel(l10n, code.tier)} · ${code.status.name}',
                    ),
                    trailing: Text(
                      code.expiresAt == null ? l10n.activationLifetime : AppDateFormat.shortDate(code.expiresAt!),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
