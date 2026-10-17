import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/routing/app_bootstrap.dart';
import '../../../core/security/activation_code_codec.dart';
import '../../../core/utils/formatters.dart';
import '../../licensing/domain/license_watch.dart';
import '../../licensing/presentation/plan_summary.dart';
import '../../../core/widgets/adaptive_row.dart';

final _licenseProvider =
    FutureProvider.autoDispose.family<({bool licensed, DateTime? expiresAt}), String>((ref, storeId) {
  return ref.watch(licensingRepositoryProvider).licenseFor(storeId);
});

class ActivationSettingsSection extends ConsumerStatefulWidget {
  const ActivationSettingsSection({super.key, required this.storeId});
  final String storeId;

  @override
  ConsumerState<ActivationSettingsSection> createState() => _ActivationSettingsSectionState();
}

class _ActivationSettingsSectionState extends ConsumerState<ActivationSettingsSection> {
  final _codeController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _reactivate() async {
    final l10n = AppLocalizations.of(context);
    try {
      final record = await ref.read(licensingRepositoryProvider).validateCode(_codeController.text);
      if (record.isExpired()) {
        setState(() => _error = l10n.activationExpired);
        return;
      }
      await ref.read(licensingRepositoryProvider).redeemCode(record.id, widget.storeId);
      ref.read(licenseValidProvider.notifier).state = true;
      ref.invalidate(_licenseProvider(widget.storeId));
      await ref.read(licenseRefresherProvider)();
      setState(() {
        _error = null;
        _codeController.clear();
      });
    } on ActivationCodeException {
      setState(() => _error = l10n.activationInvalid);
    } catch (_) {
      setState(() => _error = l10n.activationAlreadyUsed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final licenseAsync = ref.watch(_licenseProvider(widget.storeId));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.settingsActivation, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            licenseAsync.when(
              loading: () => const CircularProgressIndicator(),
              error: (e, st) => Text(l10n.errorGeneric),
              data: (license) {
                if (!license.licensed) return Text(l10n.licenseExpiredTitle);
                final expiresAt = license.expiresAt;
                if (expiresAt == null) {
                  return Text(l10n.activationLifetime, style: Theme.of(context).textTheme.bodyLarge);
                }
                final days = (expiresAt.difference(DateTime.now()).inHours / 24).ceil();
                return Text(
                  '${l10n.activationDaysRemaining(days)} (${AppDateFormat.shortDate(expiresAt)})',
                  style: Theme.of(context).textTheme.bodyLarge,
                );
              },
            ),
            const SizedBox(height: 8),
            const PlanSummary(),
            const SizedBox(height: 12),
            AdaptiveRow(
              children: [
                Expanded(
                  child: TextField(
                    controller: _codeController,
                    decoration: InputDecoration(labelText: l10n.activationCodeLabel, errorText: _error),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(onPressed: _reactivate, child: Text(l10n.activationButton)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
