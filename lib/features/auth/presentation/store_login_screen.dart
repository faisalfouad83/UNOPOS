import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/routing/route_paths.dart';
import '../../../core/supabase/supabase_config.dart';
import '../../../core/widgets/unopos_logo.dart';
import '../domain/session_controller.dart';

class StoreLoginScreen extends ConsumerStatefulWidget {
  const StoreLoginScreen({super.key});

  @override
  ConsumerState<StoreLoginScreen> createState() => _StoreLoginScreenState();
}

class _StoreLoginScreenState extends ConsumerState<StoreLoginScreen> {
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final authRepo = ref.read(authRepositoryProvider);
      final ok = await authRepo.verifyStorePassword(_idController.text.trim(), _passwordController.text);
      if (!ok) {
        setState(() => _error = l10n.loginInvalidCredentials);
        return;
      }
      final store = await authRepo.getCurrentStore();
      if (store != null) {
        ref.read(sessionControllerProvider.notifier).setStore(store);
        if (mounted) context.go(RoutePaths.tilePicker);
      } else {
        // Password verified but no matching store row came back — surface
        // this instead of silently sitting on the login screen with no
        // feedback at all.
        setState(() => _error = l10n.errorGeneric);
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
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const UnoposLogo(size: 56),
                  const SizedBox(height: 12),
                  Text(l10n.loginStoreTitle,
                      style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _idController,
                    decoration: InputDecoration(labelText: l10n.loginStoreIdHint),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(labelText: l10n.loginStorePasswordHint, errorText: _error),
                    onSubmitted: (_) => _login(),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _submitting ? null : _login,
                    child: _submitting
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(l10n.loginButton),
                  ),
                  if (kUseSupabaseBackend) ...[
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => context.go(RoutePaths.onboardingStore),
                      child: Text(l10n.loginCreateStoreLink),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
