import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/routing/app_bootstrap.dart';
import '../../../core/routing/route_paths.dart';
import '../../../core/security/activation_code_codec.dart';
import '../../../core/widgets/numeric_pin_pad.dart';
import '../../../core/widgets/receipt_card.dart';
import '../../../core/widgets/unopos_logo.dart';
import '../../auth/domain/session_controller.dart';

class ActivationScreen extends ConsumerStatefulWidget {
  const ActivationScreen({super.key});

  @override
  ConsumerState<ActivationScreen> createState() => _ActivationScreenState();
}

class _ActivationScreenState extends ConsumerState<ActivationScreen> {
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
      await ref.read(licenseGateServiceProvider).savePendingActivation(record.id);
      ref.read(licenseValidProvider.notifier).state = true;
      if (mounted) context.go(RoutePaths.onboardingStore);
    } on ActivationCodeException {
      setState(() => _error = l10n.activationInvalid);
    } catch (_) {
      setState(() => _error = l10n.activationInvalid);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _showDeveloperGate() async {
    var pin = '';
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          content: SizedBox(
            width: 320,
            child: NumericPinPad(
              value: pin,
              onChanged: (v) => setDialogState(() => pin = v),
              onSubmit: () async {
                // Must go through SessionController so session.developerMode
                // actually flips to true — RouteGuard only lets the
                // Developer console through once that flag is set, it does
                // not react to a bare context.go() call.
                final result = await ref.read(sessionControllerProvider.notifier).submitPin(pin);
                if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                if (result == PinResult.developerGate && mounted) {
                  context.go(RoutePaths.developerHome);
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onLongPress: _showDeveloperGate,
                      child: Column(
                        children: [
                          const UnoposLogo(size: 72),
                          const SizedBox(height: 16),
                          Text(
                            l10n.appName,
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: scheme.primary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.splashTagline,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: scheme.onSurface.withValues(alpha: 0.65)),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 36),
                    ReceiptCard(
                      color: scheme.surfaceContainerLowest,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            l10n.activationTitle,
                            style: Theme.of(context).textTheme.titleLarge,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.activationSubtitle,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: scheme.onSurface.withValues(alpha: 0.65)),
                          ),
                          const SizedBox(height: 24),
                          TextField(
                            controller: _controller,
                            textAlign: TextAlign.center,
                            textCapitalization: TextCapitalization.characters,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 17,
                              letterSpacing: 1.4,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: InputDecoration(
                              labelText: l10n.activationCodeLabel,
                              hintText: l10n.activationCodeHint,
                              errorText: _error,
                              prefixIcon: Icon(Icons.confirmation_number_outlined, color: scheme.secondary),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: _submitting ? null : _activate,
                              child: _submitting
                                  ? const SizedBox(
                                      width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                  : Text(l10n.activationButton),
                            ),
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
      ),
    );
  }
}
