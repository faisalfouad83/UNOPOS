import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/l10n/l10n_ext.dart';
import '../../../core/providers.dart';
import '../../../core/security/activation_code_codec.dart';
import '../../../core/utils/formatters.dart';
import '../../licensing/presentation/license_console.dart';
import '../../support/presentation/support_agents_tab.dart';
import '../domain/developer_models.dart';
import 'theme_assignments_tab.dart';

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
  late final TabController _tabController = TabController(length: 8, vsync: this);

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
            isScrollable: true,
            tabs: [
              Tab(text: context.l10n.navDashboard),
              Tab(text: context.l10n.devStores),
              Tab(text: context.l10n.devPlans),
              Tab(text: context.l10n.devLicenses),
              Tab(text: context.l10n.notificationsTitle),
              Tab(text: context.l10n.devAuditLog),
              Tab(text: context.l10n.supportAgentsTitle),
              Tab(text: context.l10n.themeDevTab),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              _DashboardTab(),
              _StoresTab(),
              _PlansTab(),
              LicenseConsole(),
              _NotificationsTab(),
              _AuditLogTab(),
              SupportAgentsTab(),
              ThemeAssignmentsTab(),
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

final _plansStreamProvider = StreamProvider.autoDispose<List<SubscriptionPlanRecord>>((ref) {
  return ref.watch(developerRepositoryProvider)!.watchPlans();
});

class _PlansTab extends ConsumerWidget {
  const _PlansTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(_plansStreamProvider);
    return plansAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text(context.l10n.errorWithDetails('$e'))),
      data: (plans) => ListView(
        padding: const EdgeInsets.all(12),
        children: plans.map((p) => _PlanCard(plan: p)).toList(),
      ),
    );
  }
}

class _PlanCard extends ConsumerWidget {
  const _PlanCard({required this.plan});
  final SubscriptionPlanRecord plan;

  Future<void> _editLimits(BuildContext context, WidgetRef ref) async {
    final employees = TextEditingController(text: '${plan.maxEmployees}');
    final branches = TextEditingController(text: '${plan.maxBranches}');
    final products = TextEditingController(text: '${plan.maxProducts}');
    final users = TextEditingController(text: '${plan.maxUsers}');
    final warehouses = TextEditingController(text: '${plan.maxWarehouses}');
    final storage = TextEditingController(text: '${plan.maxStorageMb}');
    final dailyTx = TextEditingController(text: '${plan.maxDailyTransactions}');

    Widget field(String label, TextEditingController c) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: TextField(
            controller: c,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: label),
          ),
        );

    final save = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.devEditPlanLimits(plan.name)),
        content: SizedBox(
          width: 340,
          child: SingleChildScrollView(
            child: Column(
              children: [
                field(context.l10n.devMaxEmployees, employees),
                field(context.l10n.devMaxBranches, branches),
                field(context.l10n.devMaxProducts, products),
                field(context.l10n.devMaxUsers, users),
                field(context.l10n.devMaxWarehouses, warehouses),
                field(context.l10n.devMaxStorage, storage),
                field(context.l10n.devMaxDailyTransactions, dailyTx),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: Text(context.l10n.actionCancel)),
          FilledButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: Text(context.l10n.actionSave)),
        ],
      ),
    );
    if (save != true) return;

    int parse(TextEditingController c, int fallback) => int.tryParse(c.text) ?? fallback;
    await ref.read(developerRepositoryProvider)!.updatePlanLimits(SubscriptionPlanRecord(
          id: plan.id,
          name: plan.name,
          maxEmployees: parse(employees, plan.maxEmployees),
          maxBranches: parse(branches, plan.maxBranches),
          maxProducts: parse(products, plan.maxProducts),
          maxUsers: parse(users, plan.maxUsers),
          maxWarehouses: parse(warehouses, plan.maxWarehouses),
          maxStorageMb: parse(storage, plan.maxStorageMb),
          maxDailyTransactions: parse(dailyTx, plan.maxDailyTransactions),
          isActive: plan.isActive,
        ));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: ListTile(
        title: Text(plan.name),
        subtitle: Text(
          context.l10n.devPlanSummary(
            plan.maxEmployees,
            plan.maxBranches,
            plan.maxProducts,
            plan.maxDailyTransactions,
            plan.maxStorageMb,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit_outlined),
          onPressed: () => _editLimits(context, ref),
        ),
      ),
    );
  }
}

class _DashboardTab extends ConsumerWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storesAsync = ref.watch(_storesStreamProvider);
    return storesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text(context.l10n.errorWithDetails('$e'))),
      data: (stores) {
        final stats = DashboardStats.fromStores(stores);
        final cards = [
          (context.l10n.devTotalStores, stats.totalStores, Icons.storefront_outlined),
          (context.l10n.devOnTrial, stats.trialStores, Icons.hourglass_empty),
          (context.l10n.devActiveSubscriptions, stats.activeStores, Icons.verified_outlined),
          (context.l10n.devExpired, stats.expiredStores, Icons.error_outline),
          (context.l10n.devDisabled, stats.disabledStores, Icons.block),
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
      error: (e, st) => Center(child: Text(context.l10n.errorWithDetails('$e'))),
      data: (stores) {
        if (stores.isEmpty) return Center(child: Text(context.l10n.devNoStores));
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
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: Text(context.l10n.actionCancel)),
          FilledButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: Text(context.l10n.actionConfirm)),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await action();
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.commonDone)));
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.errorWithDetails('$e'))));
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
        title: Text(context.l10n.devEditStore),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: InputDecoration(labelText: context.l10n.developerStoreName)),
              TextField(controller: ownerController, decoration: InputDecoration(labelText: context.l10n.devOwnerName)),
              TextField(controller: phoneController, decoration: InputDecoration(labelText: context.l10n.commonPhone)),
              TextField(controller: addressController, decoration: InputDecoration(labelText: context.l10n.commonAddress)),
              TextField(controller: currencyController, decoration: InputDecoration(labelText: context.l10n.settingsCurrency)),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: Text(context.l10n.actionCancel)),
          FilledButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: Text(context.l10n.actionSave)),
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

  Future<void> _changePlan(BuildContext context, WidgetRef ref) async {
    final plans = ref.read(_plansStreamProvider).valueOrNull ?? const <SubscriptionPlanRecord>[];
    if (plans.isEmpty) return;
    var selected = plans.firstWhere((p) => p.id == store.planId, orElse: () => plans.first).id;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          title: Text(context.l10n.devChangePlan),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: plans
                .map((p) => RadioListTile<String>(
                      title: Text(p.name),
                      value: p.id,
                      groupValue: selected,
                      onChanged: (v) => setState(() => selected = v!),
                    ))
                .toList(),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: Text(context.l10n.actionCancel)),
            FilledButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: Text(context.l10n.actionSave)),
          ],
        ),
      ),
    );
    if (confirmed != true) return;
    await ref.read(developerRepositoryProvider)!.assignPlan(store.id, selected);
  }

  Future<void> _resetPassword(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.devResetStorePassword),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: InputDecoration(labelText: context.l10n.devNewPassword),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: Text(context.l10n.actionCancel)),
          FilledButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: Text(context.l10n.devReset)),
        ],
      ),
    );
    if (confirmed != true || controller.text.length < 4) return;
    try {
      await ref.read(developerRepositoryProvider)!.resetStorePassword(store.id, controller.text);
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.devPasswordWasReset)));
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.errorWithDetails('$e'))));
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
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.devSubscriptionExtended)));
  }

  Future<void> _generateLicense(BuildContext context, WidgetRef ref) async {
    var tier = LicenseTier.trial1Month;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          title: Text(context.l10n.devGenerateAssignLicense),
          content: Wrap(
            spacing: 8,
            children: LicenseTier.values
                .map((t) => ChoiceChip(
                      label: Text(licenseTierLabel(context.l10n, t)),
                      selected: tier == t,
                      onSelected: (_) => setState(() => tier = t),
                    ))
                .toList(),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: Text(context.l10n.actionCancel)),
            FilledButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: Text(context.l10n.developerGenerateCode)),
          ],
        ),
      ),
    );
    if (confirmed != true) return;
    try {
      final record = await ref.read(developerRepositoryProvider)!.generateAndAssignLicense(storeId: store.id, tier: tier);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.devLicenseAssigned(record.code))));
      }
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.errorWithDetails('$e'))));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: ExpansionTile(
        title: Text(store.displayName),
        subtitle: Text('${store.storeLoginId} · ${store.planId} · ${devStatusLabel(context.l10n, store.subscriptionStatus)}'
            '${store.isDisabled ? ' · ${context.l10n.devDisabled}' : ''}${store.isSuspended ? ' · ${context.l10n.devSuspended}' : ''}'),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${context.l10n.devOwnerName}: ${store.ownerName}   ${context.l10n.commonPhone}: ${store.phone}'),
                Text('${context.l10n.devLicenseKey}: ${store.licenseKey ?? '—'}   ${context.l10n.settingsActivation}: ${devStatusLabel(context.l10n, store.activationStatus)}'),
                Text('${context.l10n.devExpires}: ${store.expiresAt == null ? context.l10n.devNever : AppDateFormat.shortDate(store.expiresAt!)}'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _editStore(context, ref),
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: Text(context.l10n.actionEdit),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => ref.read(developerRepositoryProvider)!.setStoreDisabled(store.id, !store.isDisabled),
                      icon: Icon(store.isDisabled ? Icons.check_circle_outline : Icons.block, size: 18),
                      label: Text(store.isDisabled ? context.l10n.devEnable : context.l10n.devDisable),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => ref.read(developerRepositoryProvider)!.setStoreSuspended(store.id, !store.isSuspended),
                      icon: Icon(store.isSuspended ? Icons.play_circle_outline : Icons.pause_circle_outline, size: 18),
                      label: Text(store.isSuspended ? context.l10n.devUnsuspend : context.l10n.devSuspend),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _extendSubscription(context, ref),
                      icon: const Icon(Icons.calendar_month_outlined, size: 18),
                      label: Text(context.l10n.devExtendSubscription),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _changePlan(context, ref),
                      icon: const Icon(Icons.swap_horiz, size: 18),
                      label: Text(context.l10n.devChangePlan),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _generateLicense(context, ref),
                      icon: const Icon(Icons.confirmation_number_outlined, size: 18),
                      label: Text(context.l10n.devGenerateLicense),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _resetPassword(context, ref),
                      icon: const Icon(Icons.password_outlined, size: 18),
                      label: Text(context.l10n.devResetPassword),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _confirmAndRun(
                        context,
                        ref,
                        context.l10n.devDeleteStore,
                        context.l10n.devDeleteStoreWarning(store.displayName),
                        () => ref.read(developerRepositoryProvider)!.deleteStore(store.id),
                      ),
                      icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                      label: Text(context.l10n.actionDelete, style: const TextStyle(color: Colors.red)),
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
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.devNotificationSent)));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.errorWithDetails('$e'))));
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
            TextField(controller: _titleController, decoration: InputDecoration(labelText: context.l10n.devTitle)),
            const SizedBox(height: 12),
            TextField(controller: _bodyController, maxLines: 4, decoration: InputDecoration(labelText: context.l10n.devMessage)),
            const SizedBox(height: 12),
            storesAsync.maybeWhen(
              data: (stores) => DropdownButtonFormField<String?>(
                initialValue: _targetStoreId,
                decoration: InputDecoration(labelText: context.l10n.devTarget),
                items: [
                  DropdownMenuItem(value: null, child: Text(context.l10n.devAllStores)),
                  ...stores.map((s) => DropdownMenuItem(value: s.id, child: Text(s.displayName))),
                ],
                onChanged: (v) => setState(() => _targetStoreId = v),
              ),
              orElse: () => const SizedBox.shrink(),
            ),
            const SizedBox(height: 20),
            FilledButton(onPressed: _sending ? null : _send, child: Text(context.l10n.whatsappSend)),
          ],
        ),
      ),
    );
  }
}

final _auditLogStreamProvider = StreamProvider.autoDispose<List<PlatformAuditLogRecord>>((ref) {
  return ref.watch(developerRepositoryProvider)!.watchAuditLog();
});

class _AuditLogTab extends ConsumerWidget {
  const _AuditLogTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logAsync = ref.watch(_auditLogStreamProvider);
    final storesAsync = ref.watch(_storesStreamProvider);
    final storeNames = {for (final s in storesAsync.value ?? const <DeveloperStoreRecord>[]) s.id: s.displayName};

    return logAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text(context.l10n.errorWithDetails('$e'))),
      data: (entries) {
        if (entries.isEmpty) return Center(child: Text(context.l10n.devNoAuditEntries));
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final e = entries[index];
            final target = e.targetStoreId == null ? null : (storeNames[e.targetStoreId] ?? e.targetStoreId);
            return ListTile(
              dense: true,
              leading: const Icon(Icons.history, size: 18),
              title: Text(e.action),
              subtitle: Text([
                if (target != null) target,
                if (e.detailsJson != null) e.detailsJson!,
              ].join(' · ')),
              trailing: Text(AppDateFormat.shortDate(e.createdAt)),
            );
          },
        );
      },
    );
  }
}

/// Store/subscription status values from the backend, in the app language.
String devStatusLabel(AppLocalizations l10n, String status) => switch (status) {
      'active' => l10n.devStatusActive,
      'trial' => l10n.devStatusTrial,
      'pending' => l10n.devStatusPending,
      'expired' => l10n.devExpired,
      'suspended' => l10n.devSuspended,
      'disabled' => l10n.devDisabled,
      'revoked' => l10n.devStatusRevoked,
      _ => status,
    };
