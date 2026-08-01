import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/routing/app_bootstrap.dart';
import '../../../core/security/activation_code_codec.dart';
import '../../licensing/domain/licensing_models.dart';

final _activeCodeProvider = FutureProvider.autoDispose.family<ActivationCodeRecord?, String>((ref, storeId) {
  return ref.watch(licensingRepositoryProvider).getActiveCodeForStore(storeId);
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
      ref.invalidate(_activeCodeProvider(widget.storeId));
      setState(() {
        _error = null;
        _codeController.clear();
      });
    } on ActivationCodeException {
      setState(() => _error = l10n.activationInvalid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final codeAsync = ref.watch(_activeCodeProvider(widget.storeId));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.settingsActivation, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            codeAsync.when(
              loading: () => const CircularProgressIndicator(),
              error: (e, st) => Text(l10n.errorGeneric),
              data: (code) {
                if (code == null) return Text(l10n.activationInvalid);
                final days = code.daysRemaining();
                return Text(
                  days == null ? l10n.activationLifetime : l10n.activationDaysRemaining(days),
                  style: Theme.of(context).textTheme.bodyLarge,
                );
              },
            ),
            const SizedBox(height: 12),
            Row(
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
