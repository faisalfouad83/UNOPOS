import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/routing/route_paths.dart';
import '../../../core/supabase/supabase_config.dart';
import '../../licensing/domain/license_watch.dart';

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
  final _codeController = TextEditingController();
  String? _codeError;
  bool _submitting = false;

  @override
  void dispose() {
    _storeIdController.dispose();
    _ownerNameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _codeError = null;
    });
    try {
      // On the shared backend every new store starts from an activation
      // code (a two-week trial code included). Check it before creating
      // anything so a used or mistyped code costs nothing.
      final licensing = ref.read(licensingRepositoryProvider);
      String? cloudCode;
      if (kUseSupabaseBackend) {
        cloudCode = _codeController.text.trim().toUpperCase();
        final status = await licensing.codeStatus(cloudCode);
        if (status != 'unused') {
          setState(() => _codeError = status == 'used' ? l10n.activationAlreadyUsed : l10n.activationInvalid);
          return;
        }
      }

      final gate = ref.read(licenseGateServiceProvider);
      final pendingCodeId = await gate.getPendingActivationCodeId();

      final store = await ref
          .read(authRepositoryProvider)
          .createStore(
            storeLoginId: _storeIdController.text.trim(),
            password: _passwordController.text,
            displayName: _storeIdController.text.trim(),
            activationCodeId: pendingCodeId,
            ownerName: _ownerNameController.text.trim(),
            phone: _phoneController.text.trim(),
          );

      if (pendingCodeId != null) {
        await licensing.redeemCode(pendingCodeId, store.id);
        await gate.clearPendingActivation();
      }
      if (cloudCode != null) {
        try {
          await licensing.redeemCode(cloudCode, store.id);
        } catch (_) {
          // The store exists either way; without a redeemed code it opens on
          // the "enter a code" screen, where the owner can try again.
        }
        await ref.read(licenseRefresherProvider)();
      }

      if (mounted) {
        context.go(RoutePaths.onboardingManager, extra: store);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_signUpErrorMessage(l10n, e))));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go(RoutePaths.activation)),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
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
                      Text(
                        l10n.onboardingCreateStoreTitle,
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      if (kUseSupabaseBackend) ...[
                        TextFormField(
                          controller: _codeController,
                          textCapitalization: TextCapitalization.characters,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: InputDecoration(
                            labelText: l10n.activationCodeLabel,
                            hintText: l10n.activationCodeHint,
                            errorText: _codeError,
                            prefixIcon: const Icon(Icons.confirmation_number_outlined),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty) ? l10n.errorRequired : null,
                        ),
                        const SizedBox(height: 16),
                      ],
                      TextFormField(
                        controller: _storeIdController,
                        decoration: InputDecoration(labelText: l10n.onboardingStoreId),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? l10n.errorRequired
                            : _storeIdPattern.hasMatch(v.trim())
                            ? null
                            : l10n.errorStoreIdFormat,
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
                        validator: (v) => (v == null || v.length < 6) ? l10n.errorPasswordTooShort : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmController,
                        obscureText: true,
                        decoration: InputDecoration(labelText: l10n.onboardingConfirmPassword),
                        validator: (v) => v != _passwordController.text ? l10n.errorPasswordMismatch : null,
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
      ),
    );
  }
}

/// Store IDs become part of the sign-in address, so keep them to plain
/// ASCII letters, digits and . _ -.
final _storeIdPattern = RegExp(r'^[A-Za-z0-9._-]+$');

String _signUpErrorMessage(AppLocalizations l10n, Object e) {
  if (e is AuthException) {
    final code = e.code ?? '';
    final msg = e.message.toLowerCase();
    if (code == 'weak_password' || msg.contains('password')) return l10n.errorPasswordTooShort;
    if (code == 'user_already_exists' || code == 'email_exists' || msg.contains('already')) {
      return l10n.errorStoreIdTaken;
    }
    if (code == 'email_address_invalid' || msg.contains('email')) return l10n.errorStoreIdFormat;
  }
  if (e is PostgrestException && (e.code == '23505' || e.message.contains('duplicate'))) {
    return l10n.errorStoreIdTaken;
  }
  if (e is SocketException || e.toString().contains('SocketException') || e.toString().contains('ClientException')) {
    return l10n.errorNoConnection;
  }
  return l10n.errorGeneric;
}
