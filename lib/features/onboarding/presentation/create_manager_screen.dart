import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/magic_passcodes.dart';
import '../../../core/constants/roles.dart';
import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/routing/route_paths.dart';
import '../../auth/domain/auth_models.dart';
import '../../auth/domain/session_controller.dart';

class CreateManagerScreen extends ConsumerStatefulWidget {
  const CreateManagerScreen({super.key, this.store});

  /// Null when reached via RouteGuard's redirect (store exists but
  /// onboarding never finished) rather than direct navigation from
  /// CreateStoreScreen — falls back to the session's store in that case,
  /// which AppBootstrap already loaded before any redirect could run.
  final StoreRecord? store;

  @override
  ConsumerState<CreateManagerScreen> createState() => _CreateManagerScreenState();
}

class _BranchInput {
  _BranchInput() : name = TextEditingController(), location = TextEditingController();
  final TextEditingController name;
  final TextEditingController location;
}

class _CreateManagerScreenState extends ConsumerState<CreateManagerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _pinController = TextEditingController();
  int _branchCount = 1;
  List<_BranchInput> _branches = [_BranchInput()];
  bool _submitting = false;
  String? _error;

  void _setBranchCount(int count) {
    setState(() {
      _branchCount = count.clamp(1, 20);
      if (_branches.length < _branchCount) {
        _branches = [..._branches, ...List.generate(_branchCount - _branches.length, (_) => _BranchInput())];
      } else if (_branches.length > _branchCount) {
        _branches = _branches.sublist(0, _branchCount);
      }
    });
  }

  /// [widget.store] is only populated when navigated to directly from
  /// CreateStoreScreen; when RouteGuard redirects here instead, it falls
  /// back to whatever AppBootstrap already loaded into the session.
  StoreRecord get _store => widget.store ?? ref.read(sessionControllerProvider).store!;

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;
    if (MagicPasscodes.isReserved(_pinController.text)) {
      setState(() => _error = l10n.errorRequired);
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final store = _store;
      final authRepo = ref.read(authRepositoryProvider);
      // If a previous attempt at this screen already created the branch(es)
      // but failed on a later step (e.g. employee creation), reuse them
      // instead of creating duplicates — retrying would otherwise trip the
      // plan's branch-limit trigger every time.
      final existingBranches = await authRepo.listBranches(store.id);
      String? firstBranchId;
      if (existingBranches.isNotEmpty) {
        firstBranchId = existingBranches.first.id;
      } else {
        for (var i = 0; i < _branchCount; i++) {
          final branch = await authRepo.createBranch(
            storeId: store.id,
            name: _branches[i].name.text.trim().isEmpty ? 'Branch ${i + 1}' : _branches[i].name.text.trim(),
            address: _branches[i].location.text.trim(),
            isMainBranch: i == 0,
          );
          firstBranchId ??= branch.id;
        }
      }

      final owner = await authRepo.createEmployee(
        storeId: store.id,
        branchId: firstBranchId,
        name: _nameController.text.trim(),
        role: StoreRole.owner.name,
        pin: _pinController.text,
        phone: _phoneController.text.trim(),
      );

      await ref.read(accountingRepositoryProvider).seedDefaultChartOfAccounts(store.id);
      await ref.read(settingsRepositoryProvider).ensureSettings(store.id);

      final sessionNotifier = ref.read(sessionControllerProvider.notifier);
      sessionNotifier.setStore(store);
      await sessionNotifier.signInEmployeeDirectly(owner);

      if (mounted) context.go(RoutePaths.home);
    } catch (e) {
      // TODO(debug): temporarily shows the raw exception instead of a
      // generic message while diagnosing the Supabase onboarding flow —
      // revert to l10n.errorGeneric once this is confirmed working end to
      // end against a real project.
      setState(() => _error = '${l10n.errorGeneric}\n$e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _pinController.dispose();
    for (final b in _branches) {
      b.name.dispose();
      b.location.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.onboardingCreateManagerTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: l10n.onboardingManagerName),
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
                  controller: _pinController,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)],
                  decoration: InputDecoration(labelText: l10n.onboardingManagerPasscode, errorText: _error),
                  validator: (v) => (v == null || v.length != 4) ? l10n.errorRequired : null,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(child: Text(l10n.onboardingBranchCount, style: Theme.of(context).textTheme.titleMedium)),
                    IconButton(
                      onPressed: () => _setBranchCount(_branchCount - 1),
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Text('$_branchCount', style: Theme.of(context).textTheme.titleLarge),
                    IconButton(
                      onPressed: () => _setBranchCount(_branchCount + 1),
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                for (var i = 0; i < _branchCount; i++)
                  Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${l10n.onboardingBranchDetails} ${i + 1}',
                              style: Theme.of(context).textTheme.labelLarge),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _branches[i].name,
                            decoration: InputDecoration(labelText: l10n.onboardingBranchName),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _branches[i].location,
                            decoration: InputDecoration(labelText: l10n.onboardingBranchLocation),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(l10n.onboardingFinish),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
