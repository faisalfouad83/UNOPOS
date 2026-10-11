import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/routing/app_bootstrap.dart';
import '../../../core/security/activation_code_codec.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/receipt_card.dart';
import '../../../core/widgets/unopos_logo.dart';
import '../../auth/domain/session_controller.dart';
import '../domain/license_watch.dart';
import 'developer_gate.dart';

/// Shown instead of the whole app once the store's activation code (or
/// trial) has run out. Entering a new code unlocks it straight away. The
/// developer entry (long-press the logo) stays reachable to issue a code.
class LicenseExpiredScreen extends ConsumerStatefulWidget {
  const LicenseExpiredScreen({super.key});

  @override
  ConsumerState<LicenseExpiredScreen> createState() => _LicenseExpiredScreenState();
}

class _LicenseExpiredScreenState extends ConsumerState<LicenseExpiredScreen> {
  final _controller = TextEditingController();
  String? _error;
  bool _submitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _activate() async {
    final l10n = AppLocalizations.of(context);
    final storeId = ref.read(sessionControllerProvider).store?.id;
    if (storeId == null) return;
    setState(() {
      _error = null;
      _submitting = true;
    });
    try {
      final repo = ref.read(licensingRepositoryProvider);
      final record = await repo.validateCode(_controller.text);
      if (record.isExpired()) {
        setState(() => _error = l10n.activationExpired);
        return;
      }
      await repo.redeemCode(record.id, storeId);
      ref.read(licenseValidProvider.notifier).state = true;
      await ref.read(licenseRefresherProvider)();
    } on ActivationCodeException {
      setState(() => _error = l10n.activationInvalid);
    } catch (_) {
      // e.g. the code was already used by another store.
      setState(() => _error = l10n.activationAlreadyUsed);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final store = ref.watch(sessionControllerProvider).store;
    final expiredAt = ref.watch(licenseExpiresAtProvider);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onLongPress: () => showDeveloperGate(context, ref),
                    child: const UnoposLogo(size: 72),
                  ),
                  const SizedBox(height: 16),
                  Icon(Icons.lock_clock_outlined, size: 40, color: theme.colorScheme.error),
                  const SizedBox(height: 8),
                  Text(l10n.licenseExpiredTitle, style: theme.textTheme.headlineSmall, textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text(
                    [
                      if (store != null) store.displayName,
                      if (expiredAt != null) l10n.licenseExpiredOn(AppDateFormat.shortDate(expiredAt)),
                    ].join(' · '),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(l10n.licenseExpiredHelp, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 24),
                  ReceiptCard(
                    color: theme.colorScheme.surfaceContainerLowest,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            labelText: l10n.activationCodeLabel,
                            hintText: 'UNPS-…',
                            errorText: _error,
                          ),
                          onSubmitted: (_) => _activate(),
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: _submitting ? null : _activate,
                          child: _submitting
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                              : Text(l10n.activationButton),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
