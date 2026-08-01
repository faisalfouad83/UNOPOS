import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/magic_passcodes.dart';
import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/routing/app_bootstrap.dart';
import '../../../core/routing/route_paths.dart';
import '../../../core/security/activation_code_codec.dart';
import '../../../core/widgets/numeric_pin_pad.dart';

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
              onSubmit: () {
                if (pin == MagicPasscodes.developerGate) {
                  Navigator.of(dialogContext).pop();
                  context.go(RoutePaths.developerHome);
                } else {
                  Navigator.of(dialogContext).pop();
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
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onLongPress: _showDeveloperGate,
                    child: Column(
                      children: [
                        Icon(Icons.storefront_rounded, size: 64, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(height: 12),
                        Text(l10n.appName, style: Theme.of(context).textTheme.headlineMedium),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.splashTagline,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  Text(l10n.activationTitle, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    l10n.activationSubtitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _controller,
                    textAlign: TextAlign.center,
                    textCapitalization: TextCapitalization.characters,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 18, letterSpacing: 1.5),
                    decoration: InputDecoration(
                      labelText: l10n.activationCodeLabel,
                      hintText: l10n.activationCodeHint,
                      errorText: _error,
                    ),
                  ),
                  const SizedBox(height: 24),
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
          ),
        ),
      ),
    );
  }
}
