import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/offline/sync_service.dart';
import '../../../core/providers.dart';
import '../../../core/routing/route_paths.dart';
import '../../../core/constants/roles.dart';
import '../../home/presentation/home_shell.dart';
import '../domain/auth_models.dart';
import '../domain/session_controller.dart';

class TilePickerScreen extends ConsumerWidget {
  const TilePickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(sessionControllerProvider);
    final store = session.store;
    final employeesAsync =
        store == null ? const AsyncValue<List<EmployeeRecord>>.data([]) : ref.watch(storeEmployeesProvider(store.id));
    final branches = store == null
        ? const <BranchRecord>[]
        : (ref.watch(storeBranchesProvider(store.id)).value ?? const <BranchRecord>[])
            .where((b) => b.isActive)
            .toList();
    final multiBranch = branches.length > 1;
    final branchId = session.currentBranchId;
    final choosingBranch = multiBranch && (branchId == null || !branches.any((b) => b.id == branchId));
    final currentBranch = branches.where((b) => b.id == branchId).firstOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          choosingBranch
              ? l10n.pickBranchTitle
              : currentBranch == null
                  ? l10n.pickAccountTitle
                  : '${l10n.pickAccountTitle} · ${currentBranch.name}',
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: l10n.actionSignOut,
          onPressed: () async {
            // Leaving here signs the whole store out of this device: ask
            // first, and warn when changes made here are still unsent.
            final pending = ref.read(outboxProvider).hasPending;
            final ok = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(l10n.actionSignOut),
                content: Text(pending ? l10n.storeSignOutPendingWarning : l10n.storeSignOutConfirm),
                actions: [
                  TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.actionCancel)),
                  FilledButton(onPressed: () => Navigator.of(context).pop(true), child: Text(l10n.actionSignOut)),
                ],
              ),
            );
            if (ok != true) return;
            await ref.read(sessionControllerProvider.notifier).signOutStore();
            if (context.mounted) context.go(RoutePaths.activation);
          },
        ),
        actions: [
          if (multiBranch && !choosingBranch)
            TextButton.icon(
              icon: const Icon(Icons.storefront_outlined),
              label: Text(l10n.pickBranchChange),
              onPressed: () => ref.read(sessionControllerProvider.notifier).clearCurrentBranch(),
            ),
        ],
      ),
      body: choosingBranch
          ? _BranchPicker(
              branches: branches,
              onPick: (b) => ref.read(sessionControllerProvider.notifier).setCurrentBranch(b.id),
            )
          : employeesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.tilePickerLoadFailed, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: Text(l10n.actionRetry),
                      onPressed: () => ref.invalidate(storeEmployeesProvider(store!.id)),
                    ),
                  ],
                ),
              ),
              data: (all) {
                // With several branches, show the chosen branch's staff plus
                // anyone not tied to a branch (e.g. the owner).
                final employees =
                    multiBranch ? all.where((e) => e.branchId == null || e.branchId == branchId).toList() : all;
                if (employees.isEmpty) {
                  return Center(child: Text(l10n.tilePickerNoEmployees));
                }
                // Two tiles a row on a phone, three on wider screens.
                final phone = MediaQuery.sizeOf(context).width < 520;
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: GridView.builder(
                      padding: EdgeInsets.all(phone ? 16 : 32),
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: phone ? 2 : 3,
                        mainAxisSpacing: phone ? 12 : 20,
                        crossAxisSpacing: phone ? 12 : 20,
                        childAspectRatio: 0.9,
                      ),
                      itemCount: employees.length,
                      itemBuilder: (context, index) {
                        final employee = employees[index];
                        return _EmployeeTile(
                          employee: employee,
                          onTap: () {
                            ref.read(selectedEmployeeForPinProvider.notifier).state = employee;
                            context.go(RoutePaths.pinPad);
                          },
                        );
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _BranchPicker extends StatelessWidget {
  const _BranchPicker({required this.branches, required this.onPick});

  final List<BranchRecord> branches;
  final ValueChanged<BranchRecord> onPick;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final sorted = [...branches]..sort((a, b) => (b.isMainBranch ? 1 : 0).compareTo(a.isMainBranch ? 1 : 0));
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: ListView.separated(
          padding: const EdgeInsets.all(32),
          shrinkWrap: true,
          itemCount: sorted.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final b = sorted[i];
            return Material(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              child: ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: Icon(Icons.storefront, color: theme.colorScheme.primary, size: 32),
                title: Text(b.name, style: theme.textTheme.titleMedium),
                subtitle: Text(
                  [if (b.isMainBranch) l10n.pickBranchMain, if (b.address.isNotEmpty) b.address].join(' · '),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => onPick(b),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// The store's accounts for the picker. Disposed when the picker closes, so
/// signing out and into a store (the same one or another) always opens a
/// fresh, correctly-authenticated list instead of a cached one that broke
/// when the previous session ended.
final storeEmployeesProvider = StreamProvider.autoDispose.family<List<EmployeeRecord>, String>((ref, storeId) {
  return ref.watch(authRepositoryProvider).watchEmployees(storeId);
});

class _EmployeeTile extends StatelessWidget {
  const _EmployeeTile({required this.employee, required this.onTap});

  final EmployeeRecord employee;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = Color(int.parse(employee.avatarColorHex.replaceFirst('#', '0xFF')));
    final initials = employee.name.trim().isEmpty
        ? '?'
        : employee.name.trim().split(RegExp(r'\s+')).map((w) => w[0]).take(2).join().toUpperCase();

    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: color,
                child: Text(
                  initials,
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                employee.name,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                roleLabel(AppLocalizations.of(context), SessionRole.fromStoreRole(employee.role)),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
