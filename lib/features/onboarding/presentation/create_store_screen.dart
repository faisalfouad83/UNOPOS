import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/routing/route_paths.dart';

class CreateStoreScreen extends ConsumerStatefulWidget {
  const CreateStoreScreen({super.key});

  @override
  ConsumerState<CreateStoreScreen> createState() => _CreateStoreScreenState();
}

class _CreateStoreScreenState extends ConsumerState<CreateStoreScreen> {
  final _formKey = GlobalKey<FormState>();
  final _storeIdController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _storeIdController.dispose();
    _ownerNameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      final gate = ref.read(licenseGateServiceProvider);
      final pendingCodeId = await gate.getPendingActivationCodeId();

      final store = await ref.read(authRepositoryProvider).createStore(
            storeLoginId: _storeIdController.text.trim(),
            password: _passwordController.text,
            displayName: _storeIdController.text.trim(),
            activationCodeId: pendingCodeId,
            ownerName: _ownerNameController.text.trim(),
            phone: _phoneController.text.trim(),
          );

      if (pendingCodeId != null) {
        await ref.read(licensingRepositoryProvider).redeemCode(pendingCodeId, store.id);
        await gate.clearPendingActivation();
      }

      if (mounted) {
        context.go(RoutePaths.onboardingManager, extra: store);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.errorGeneric)));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
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
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(l10n.onboardingCreateStoreTitle,
                        style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _storeIdController,
                      decoration: InputDecoration(labelText: l10n.onboardingStoreId),
                      validator: (v) => (v == null || v.trim().isEmpty) ? l10n.errorRequired : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _ownerNameController,
                      decoration: InputDecoration(labelText: l10n.onboardingOwnerName),
                      validator: (v) => (v == null || v.trim().isEmpty) ? l10n.errorRequired : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(labelText: l10n.commonPhone),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(labelText: l10n.onboardingStorePassword),
                      validator: (v) => (v == null || v.length < 4) ? l10n.errorRequired : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmController,
                      obscureText: true,
                      decoration: InputDecoration(labelText: l10n.onboardingConfirmPassword),
                      validator: (v) => v != _passwordController.text ? l10n.errorRequired : null,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _submitting ? null : _submit,
                      child: _submitting
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(l10n.actionNext),
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
