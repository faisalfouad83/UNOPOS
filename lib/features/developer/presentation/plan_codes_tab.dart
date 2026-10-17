import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestException;

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/security/activation_code_codec.dart';
import '../../../core/utils/formatters.dart';
import '../../licensing/domain/entitlement.dart';
import '../../licensing/presentation/license_console.dart';
import '../../licensing/presentation/plan_summary.dart';
import '../domain/developer_models.dart';

final _plansProvider = StreamProvider.autoDispose<List<SubscriptionPlanRecord>>((ref) {
  return ref.watch(developerRepositoryProvider)!.watchPlans();
});

final _storesProvider = StreamProvider.autoDispose<List<DeveloperStoreRecord>>((ref) {
  return ref.watch(developerRepositoryProvider)!.watchStores();
});

/// Shortest first, so the trials lead.
const _tierOrder = [
  LicenseTier.trial2Weeks,
  LicenseTier.trial1Month,
  LicenseTier.months3,
  LicenseTier.months6,
  LicenseTier.months12,
  LicenseTier.lifetime,
];

/// When a code of [tier] issued today ends (null = never), as the code
/// itself records it.
DateTime? codeEndDate(LicenseTier tier, [DateTime? now]) {
  if (tier.days == null) return null;
  final today = now ?? DateTime.now();
  return DateTime(today.year, today.month, today.day + tier.days!);
}

/// Developer Console: issue codes that carry a plan (optionally for one
/// store only, optionally activated there at once), and choose which
/// sections each plan includes and how many tills it allows.
class PlanCodesTab extends ConsumerWidget {
  const PlanCodesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plans = ref.watch(_plansProvider);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const _IssueCodeCard(),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context).devPlanFeaturesTitle, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...plans.when(
              loading: () => [const Center(child: CircularProgressIndicator())],
              error: (e, _) => [Text(AppLocalizations.of(context).errorWithDetails('$e'))],
              data: (list) => [for (final p in list) _PlanFeaturesCard(plan: p)],
            ),
          ],
        ),
      ),
    );
  }
}

class _IssueCodeCard extends ConsumerStatefulWidget {
  const _IssueCodeCard();

  @override
  ConsumerState<_IssueCodeCard> createState() => _IssueCodeCardState();
}

class _IssueCodeCardState extends ConsumerState<_IssueCodeCard> {
  final _name = TextEditingController();
  LicenseTier _tier = LicenseTier.months12;
  String? _planId;
  String? _storeId;
  bool _busy = false;
  String? _code;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _issue({required bool activateNow}) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final repo = ref.read(developerRepositoryProvider)!;
    final name = _name.text.trim();
    if (name.isEmpty && _storeId == null) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.devPlanNameNeeded)));
      return;
    }
    setState(() => _busy = true);
    try {
      final record = activateNow && _storeId != null
          ? await repo.generateAndAssignLicense(storeId: _storeId!, tier: _tier, planId: _planId)
          : await repo.issueCode(tier: _tier, storeNameRef: name, planId: _planId, targetStoreId: _storeId);
      setState(() => _code = record.code);
      messenger.showSnackBar(
        SnackBar(content: Text(activateNow ? l10n.devLicenseAssigned(record.code) : l10n.developerCodeGenerated)),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.errorWithDetails(_serverMessage(e)))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final plans = ref.watch(_plansProvider).valueOrNull ?? const <SubscriptionPlanRecord>[];
    final stores = ref.watch(_storesProvider).valueOrNull ?? const <DeveloperStoreRecord>[];
    final end = codeEndDate(_tier);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.devPlanIssueTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              initialValue: _storeId,
              isExpanded: true,
              decoration: InputDecoration(labelText: l10n.devPlanTargetStore, helperText: l10n.devPlanTargetStoreHelp),
              items: [
                DropdownMenuItem(value: null, child: Text(l10n.devPlanAnyStore)),
                for (final s in stores)
                  DropdownMenuItem(
                    value: s.id,
                    child: Text('${s.displayName} · ${s.storeLoginId}', overflow: TextOverflow.ellipsis),
                  ),
              ],
              onChanged: (id) => setState(() {
                _storeId = id;
                final store = stores.where((s) => s.id == id).firstOrNull;
                if (store != null) {
                  _name.text = store.displayName;
                  _planId ??= store.planId;
                }
              }),
            ),
            const SizedBox(height: 12),
            TextField(controller: _name, decoration: InputDecoration(labelText: l10n.developerStoreName)),
            const SizedBox(height: 12),
            DropdownButtonFormField<String?>(
              initialValue: _planId,
              isExpanded: true,
              decoration: InputDecoration(labelText: l10n.devPlanPlan),
              items: [
                DropdownMenuItem(value: null, child: Text(l10n.devPlanKeepPlan)),
                for (final p in plans.where((p) => p.isActive)) DropdownMenuItem(value: p.id, child: Text(p.name)),
              ],
              onChanged: (id) => setState(() => _planId = id),
            ),
            const SizedBox(height: 12),
            Text(l10n.developerLicenseTier, style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final t in _tierOrder)
                  ChoiceChip(
                    label: Text(licenseTierLabel(l10n, t)),
                    selected: _tier == t,
                    onSelected: (_) => setState(() => _tier = t),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              end == null ? l10n.devPlanEndsNever : l10n.devPlanEndsOn(AppDateFormat.shortDate(end)),
              style: theme.textTheme.bodyMedium,
            ),
            Text(l10n.devPlanEndsHelp, style: theme.textTheme.bodySmall),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: _busy ? null : () => _issue(activateNow: false),
                  icon: const Icon(Icons.confirmation_number_outlined),
                  label: Text(l10n.developerGenerateCode),
                ),
                if (_storeId != null)
                  FilledButton.icon(
                    onPressed: _busy ? null : () => _issue(activateNow: true),
                    icon: const Icon(Icons.bolt_outlined),
                    label: Text(l10n.devPlanIssueAndActivate),
                  ),
              ],
            ),
            if (_code != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: SelectableText(
                      _code!,
                      style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.devPlanCopy,
                    icon: const Icon(Icons.copy),
                    onPressed: () => Clipboard.setData(ClipboardData(text: _code!)),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// One plan: which sections it includes and its till limit.
class _PlanFeaturesCard extends ConsumerStatefulWidget {
  const _PlanFeaturesCard({required this.plan});
  final SubscriptionPlanRecord plan;

  @override
  ConsumerState<_PlanFeaturesCard> createState() => _PlanFeaturesCardState();
}

class _PlanFeaturesCardState extends ConsumerState<_PlanFeaturesCard> {
  late Map<String, bool> _features = _initial();
  late final _devices = TextEditingController(text: widget.plan.maxDevices?.toString() ?? '');
  bool _dirty = false;

  Map<String, bool> _initial() => {for (final m in PlanModules.all) m: widget.plan.features[m] ?? true};

  @override
  void didUpdateWidget(covariant _PlanFeaturesCard old) {
    super.didUpdateWidget(old);
    if (!_dirty) {
      _features = _initial();
      _devices.text = widget.plan.maxDevices?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _devices.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final text = _devices.text.trim();
    final devices = text.isEmpty ? null : int.tryParse(text);
    if (text.isNotEmpty && (devices == null || devices < 1)) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.devPlanDevicesInvalid)));
      return;
    }
    try {
      await ref.read(developerRepositoryProvider)!.updatePlanEntitlements(
            widget.plan.id,
            // Only what is switched off needs saving; anything else is on.
            features: {
              for (final e in _features.entries)
                if (!e.value) e.key: false
            },
            maxDevices: devices,
          );
      setState(() => _dirty = false);
      messenger.showSnackBar(SnackBar(content: Text(l10n.settingsSaved)));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.errorWithDetails(_serverMessage(e)))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: ExpansionTile(
        title: Text(widget.plan.name),
        subtitle: Text(
          l10n.devPlanFeaturesSummary(
            _features.values.where((v) => v).length,
            PlanModules.all.length,
            widget.plan.maxDevices?.toString() ?? l10n.planUnlimited,
          ),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final m in PlanModules.all)
                FilterChip(
                  label: Text(planModuleLabel(l10n, m)),
                  selected: _features[m] ?? true,
                  onSelected: (v) => setState(() {
                    _features[m] = v;
                    _dirty = true;
                  }),
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _devices,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(labelText: l10n.devPlanMaxDevices, helperText: l10n.devPlanMaxDevicesHelp),
            onChanged: (_) => _dirty = true,
          ),
          const SizedBox(height: 12),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: FilledButton(onPressed: _save, child: Text(l10n.actionSave)),
          ),
        ],
      ),
    );
  }
}

/// Generates a code for [store] only, on the chosen plan and duration, and
/// activates it there straight away (Stores tab → "Generate license").
Future<void> showIssueLicenseDialog(BuildContext context, WidgetRef ref, DeveloperStoreRecord store) async {
  final l10n = AppLocalizations.of(context);
  final plans = await ref.read(developerRepositoryProvider)!.watchPlans().first;
  if (!context.mounted) return;
  var tier = LicenseTier.months12;
  String? planId = plans.any((p) => p.id == store.planId) ? store.planId : null;
  final ok = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setState) {
        final end = codeEndDate(tier);
        return AlertDialog(
          title: Text(l10n.devGenerateAssignLicense),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(store.displayName, style: Theme.of(dialogContext).textTheme.titleSmall),
                const SizedBox(height: 12),
                DropdownButtonFormField<String?>(
                  initialValue: planId,
                  isExpanded: true,
                  decoration: InputDecoration(labelText: l10n.devPlanPlan),
                  items: [
                    DropdownMenuItem(value: null, child: Text(l10n.devPlanKeepPlan)),
                    for (final p in plans.where((p) => p.isActive)) DropdownMenuItem(value: p.id, child: Text(p.name)),
                  ],
                  onChanged: (v) => setState(() => planId = v),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final t in _tierOrder)
                      ChoiceChip(
                        label: Text(licenseTierLabel(l10n, t)),
                        selected: tier == t,
                        onSelected: (_) => setState(() => tier = t),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(end == null ? l10n.devPlanEndsNever : l10n.devPlanEndsOn(AppDateFormat.shortDate(end))),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: Text(l10n.actionCancel)),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.devPlanIssueAndActivate),
            ),
          ],
        );
      },
    ),
  );
  if (ok != true || !context.mounted) return;
  final messenger = ScaffoldMessenger.of(context);
  try {
    final record = await ref
        .read(developerRepositoryProvider)!
        .generateAndAssignLicense(storeId: store.id, tier: tier, planId: planId);
    messenger.showSnackBar(SnackBar(content: Text(l10n.devLicenseAssigned(record.code))));
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(l10n.errorWithDetails(_serverMessage(e)))));
  }
}

/// The server's own words for a refusal (PostgrestException.message), or
/// the error as text.
String _serverMessage(Object e) => e is PostgrestException && e.message.isNotEmpty ? e.message : '$e';
