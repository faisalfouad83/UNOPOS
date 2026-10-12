import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/gen/app_localizations.dart';
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
    final employeesAsync = store == null
        ? const AsyncValue<List<EmployeeRecord>>.data([])
        : ref.watch(_employeesStreamProvider(store.id));
    final branches = store == null
        ? const <BranchRecord>[]
        : (ref.watch(_branchesProvider(store.id)).value ?? const <BranchRecord>[]).where((b) => b.isActive).toList();
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
          onPressed: () async {
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
              error: (e, st) => Center(child: Text(l10n.errorGeneric)),
              data: (all) {
                // With several branches, show the chosen branch's staff plus
                // anyone not tied to a branch (e.g. the owner).
                final employees = multiBranch
                    ? all.where((e) => e.branchId == null || e.branchId == branchId).toList()
                    : all;
                if (employees.isEmpty) {
                  return Center(child: Text(l10n.tilePickerNoEmployees));
                }
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: GridView.builder(
                      padding: const EdgeInsets.all(32),
                      shrinkWrap: true,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 20,
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

final _branchesProvider = FutureProvider.autoDispose.family<List<BranchRecord>, String>((ref, storeId) {
  return ref.watch(authRepositoryProvider).listBranches(storeId);
});

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

final _employeesStreamProvider = StreamProvider.family<List<EmployeeRecord>, String>((ref, storeId) {
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
