import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../auth/domain/auth_models.dart';
import '../../auth/domain/session_controller.dart';

final _branchesProvider = FutureProvider.autoDispose.family<List<BranchRecord>, String>((ref, storeId) {
  return ref.watch(authRepositoryProvider).listBranches(storeId);
});

Future<void> _showBranchDialog(BuildContext context, WidgetRef ref, String storeId, {BranchRecord? existing}) async {
  final l10n = AppLocalizations.of(context);
  final nameController = TextEditingController(text: existing?.name);
  final addressController = TextEditingController(text: existing?.address);
  final phoneController = TextEditingController(text: existing?.phone);

  await showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(existing == null ? l10n.settingsAddBranch : existing.name),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: l10n.onboardingBranchName)),
            const SizedBox(height: 12),
            TextField(controller: addressController, decoration: InputDecoration(labelText: l10n.onboardingBranchLocation)),
            const SizedBox(height: 12),
            TextField(controller: phoneController, decoration: InputDecoration(labelText: l10n.commonPhone)),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.actionCancel)),
        FilledButton(
          onPressed: () async {
            final name = nameController.text.trim();
            if (name.isEmpty) return;
            final repo = ref.read(authRepositoryProvider);
            if (existing == null) {
              await repo.createBranch(
                storeId: storeId,
                name: name,
                address: addressController.text.trim(),
                phone: phoneController.text.trim(),
              );
            } else {
              await repo.updateBranch(BranchRecord(
                id: existing.id,
                storeId: existing.storeId,
                name: name,
                address: addressController.text.trim(),
                phone: phoneController.text.trim(),
                isMainBranch: existing.isMainBranch,
                isActive: existing.isActive,
              ));
            }
            ref.invalidate(_branchesProvider(storeId));
            if (context.mounted) Navigator.of(context).pop();
          },
          child: Text(l10n.actionSave),
        ),
      ],
    ),
  );
}

class BranchSettingsSection extends ConsumerWidget {
  const BranchSettingsSection({super.key, required this.storeId});
  final String storeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final branchesAsync = ref.watch(_branchesProvider(storeId));
    final currentBranchId = ref.watch(sessionControllerProvider).currentBranchId;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(l10n.settingsBranches, style: Theme.of(context).textTheme.titleMedium)),
                TextButton.icon(
                  onPressed: () => _showBranchDialog(context, ref, storeId),
                  icon: const Icon(Icons.add),
                  label: Text(l10n.settingsAddBranch),
                ),
              ],
            ),
            const SizedBox(height: 8),
            branchesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Text(l10n.errorGeneric),
              data: (branches) => Column(
                children: branches.map((b) {
                  final isCurrent = b.id == currentBranchId;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    color: isCurrent ? Theme.of(context).colorScheme.primaryContainer : null,
                    child: ListTile(
                      title: Text(b.name),
                      subtitle: Text([
                        if (b.address.isNotEmpty) b.address,
                        if (b.phone.isNotEmpty) b.phone,
                        if (!b.isActive) l10n.settingsBranchDeactivated,
                        if (isCurrent) l10n.settingsActiveBranch,
                      ].join(' · ')),
                      trailing: Wrap(
                        spacing: 4,
                        children: [
                          if (!isCurrent && b.isActive)
                            TextButton(
                              onPressed: () => ref.read(sessionControllerProvider.notifier).setCurrentBranch(b.id),
                              child: Text(l10n.settingsSetActiveBranch),
                            ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () => _showBranchDialog(context, ref, storeId, existing: b),
                          ),
                          IconButton(
                            icon: Icon(b.isActive ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                            tooltip: b.isActive ? l10n.settingsBranchDeactivate : l10n.settingsBranchActivate,
                            onPressed: () async {
                              await ref.read(authRepositoryProvider).updateBranch(BranchRecord(
                                    id: b.id,
                                    storeId: b.storeId,
                                    name: b.name,
                                    address: b.address,
                                    phone: b.phone,
                                    isMainBranch: b.isMainBranch,
                                    isActive: !b.isActive,
                                  ));
                              ref.invalidate(_branchesProvider(storeId));
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
