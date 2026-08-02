import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/security/activation_code_codec.dart';
import '../../../core/utils/formatters.dart';
import '../../licensing/presentation/license_console.dart';
import '../domain/developer_models.dart';

// This whole console is internal admin/operator tooling, never seen by a
// store — plain English literal strings throughout rather than the app's
// usual full AppLocalizations coverage (the l10n keys reused below,
// developerTitle/etc., already existed from the local-only console).

class DeveloperConsoleScreen extends StatefulWidget {
  const DeveloperConsoleScreen({super.key});

  @override
  State<DeveloperConsoleScreen> createState() => _DeveloperConsoleScreenState();
}

class _DeveloperConsoleScreenState extends State<DeveloperConsoleScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(length: 4, vsync: this);

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          child: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Dashboard'),
              Tab(text: 'Stores'),
              Tab(text: 'Licenses'),
              Tab(text: 'Notifications'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              _DashboardTab(),
              _StoresTab(),
              LicenseConsole(),
              _NotificationsTab(),
            ],
          ),
        ),
      ],
    );
  }
}

final _storesStreamProvider = StreamProvider.autoDispose<List<DeveloperStoreRecord>>((ref) {
  return ref.watch(developerRepositoryProvider)!.watchStores();
});

class _DashboardTab extends ConsumerWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storesAsync = ref.watch(_storesStreamProvider);
    return storesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: $e')),
      data: (stores) {
        final stats = DashboardStats.fromStores(stores);
        final cards = [
          ('Total stores', stats.totalStores, Icons.storefront_outlined),
          ('On trial', stats.trialStores, Icons.hourglass_empty),
          ('Active subscriptions', stats.activeStores, Icons.verified_outlined),
          ('Expired', stats.expiredStores, Icons.error_outline),
          ('Disabled', stats.disabledStores, Icons.block),
        ];
        return GridView.count(
          padding: const EdgeInsets.all(20),
          crossAxisCount: 3,
          childAspectRatio: 1.6,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: cards
              .map((c) => Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(c.$3, color: Theme.of(context).colorScheme.primary),
                          const Spacer(),
                          Text('${c.$2}', style: Theme.of(context).textTheme.headlineMedium),
                          Text(c.$1, style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ))
              .toList(),
        );
      },
    );
  }
}

class _StoresTab extends ConsumerWidget {
  const _StoresTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storesAsync = ref.watch(_storesStreamProvider);
    return storesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: $e')),
      data: (stores) {
        if (stores.isEmpty) return const Center(child: Text('No stores yet'));
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: stores.length,
          itemBuilder: (context, index) => _StoreCard(store: stores[index]),
        );
      },
    );
  }
}

class _StoreCard extends ConsumerWidget {
  const _StoreCard({required this.store});
  final DeveloperStoreRecord store;

  Future<void> _confirmAndRun(BuildContext context, WidgetRef ref, String title, String message, Future<void> Function() action) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: const Text('Confirm')),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await action();
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Done')));
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
  }

  Future<void> _editStore(BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController(text: store.displayName);
    final ownerController = TextEditingController(text: store.ownerName);
    final phoneController = TextEditingController(text: store.phone);
    final addressController = TextEditingController(text: store.address);
    final currencyController = TextEditingController(text: store.currencyCode);

    final save = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit store'),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Store name')),
              TextField(controller: ownerController, decoration: const InputDecoration(labelText: 'Owner name')),
              TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone')),
              TextField(controller: addressController, decoration: const InputDecoration(labelText: 'Address')),
              TextField(controller: currencyController, decoration: const InputDecoration(labelText: 'Currency code')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: const Text('Save')),
        ],
      ),
    );
    if (save != true) return;
    await ref.read(developerRepositoryProvider)!.updateStoreInfo(
          storeId: store.id,
          displayName: nameController.text.trim(),
          ownerName: ownerController.text.trim(),
          phone: phoneController.text.trim(),
          address: addressController.text.trim(),
          currencyCode: currencyController.text.trim(),
        );
  }

  Future<void> _resetPassword(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reset store password'),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'New password'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: const Text('Reset')),
        ],
      ),
    );
    if (confirmed != true || controller.text.length < 4) return;
    try {
      await ref.read(developerRepositoryProvider)!.resetStorePassword(store.id, controller.text);
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password reset')));
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
  }

  Future<void> _extendSubscription(BuildContext context, WidgetRef ref) async {
    final date = await showDatePicker(
      context: context,
      initialDate: store.expiresAt ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (date == null) return;
    await ref.read(developerRepositoryProvider)!.extendSubscription(store.id, date);
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Subscription extended')));
  }

  Future<void> _generateLicense(BuildContext context, WidgetRef ref) async {
    var tier = LicenseTier.trial1Month;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          title: const Text('Generate & assign license'),
          content: Wrap(
            spacing: 8,
            children: LicenseTier.values
                .map((t) => ChoiceChip(
                      label: Text(t.name),
                      selected: tier == t,
                      onSelected: (_) => setState(() => tier = t),
                    ))
                .toList(),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: const Text('Generate')),
          ],
        ),
      ),
    );
    if (confirmed != true) return;
    try {
      final record = await ref.read(developerRepositoryProvider)!.generateAndAssignLicense(storeId: store.id, tier: tier);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Assigned: ${record.code}')));
      }
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: ExpansionTile(
        title: Text(store.displayName),
        subtitle: Text('${store.storeLoginId} · ${store.planId} · ${store.subscriptionStatus}'
            '${store.isDisabled ? ' · DISABLED' : ''}${store.isSuspended ? ' · SUSPENDED' : ''}'),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Owner: ${store.ownerName}   Phone: ${store.phone}'),
                Text('License: ${store.licenseKey ?? '—'}   Activation: ${store.activationStatus}'),
                Text('Expires: ${store.expiresAt == null ? 'never' : AppDateFormat.shortDate(store.expiresAt!)}'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _editStore(context, ref),
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Edit'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => ref.read(developerRepositoryProvider)!.setStoreDisabled(store.id, !store.isDisabled),
                      icon: Icon(store.isDisabled ? Icons.check_circle_outline : Icons.block, size: 18),
                      label: Text(store.isDisabled ? 'Enable' : 'Disable'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => ref.read(developerRepositoryProvider)!.setStoreSuspended(store.id, !store.isSuspended),
                      icon: Icon(store.isSuspended ? Icons.play_circle_outline : Icons.pause_circle_outline, size: 18),
                      label: Text(store.isSuspended ? 'Unsuspend' : 'Suspend'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _extendSubscription(context, ref),
                      icon: const Icon(Icons.calendar_month_outlined, size: 18),
                      label: const Text('Extend subscription'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _generateLicense(context, ref),
                      icon: const Icon(Icons.confirmation_number_outlined, size: 18),
                      label: const Text('Generate license'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _resetPassword(context, ref),
                      icon: const Icon(Icons.password_outlined, size: 18),
                      label: const Text('Reset password'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _confirmAndRun(
                        context,
                        ref,
                        'Delete store',
                        'This permanently deletes "${store.displayName}" and ALL of its data (sales, inventory, accounting, everything). This cannot be undone.',
                        () => ref.read(developerRepositoryProvider)!.deleteStore(store.id),
                      ),
                      icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                      label: const Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationsTab extends ConsumerStatefulWidget {
  const _NotificationsTab();

  @override
  ConsumerState<_NotificationsTab> createState() => _NotificationsTabState();
}

class _NotificationsTabState extends ConsumerState<_NotificationsTab> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  String? _targetStoreId;
  bool _sending = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_titleController.text.trim().isEmpty || _bodyController.text.trim().isEmpty) return;
    setState(() => _sending = true);
    try {
      await ref.read(developerRepositoryProvider)!.sendNotification(
            title: _titleController.text.trim(),
            body: _bodyController.text.trim(),
            targetStoreIds: _targetStoreId == null ? null : [_targetStoreId!],
          );
      _titleController.clear();
      _bodyController.clear();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notification sent')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final storesAsync = ref.watch(_storesStreamProvider);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Title')),
            const SizedBox(height: 12),
            TextField(controller: _bodyController, maxLines: 4, decoration: const InputDecoration(labelText: 'Message')),
            const SizedBox(height: 12),
            storesAsync.maybeWhen(
              data: (stores) => DropdownButtonFormField<String?>(
                initialValue: _targetStoreId,
                decoration: const InputDecoration(labelText: 'Target'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All stores')),
                  ...stores.map((s) => DropdownMenuItem(value: s.id, child: Text(s.displayName))),
                ],
                onChanged: (v) => setState(() => _targetStoreId = v),
              ),
              orElse: () => const SizedBox.shrink(),
            ),
            const SizedBox(height: 20),
            FilledButton(onPressed: _sending ? null : _send, child: const Text('Send')),
          ],
        ),
      ),
    );
  }
}
