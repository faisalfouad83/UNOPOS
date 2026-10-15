import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/utils/formatters.dart';
import '../domain/support_models.dart';

String supportPresenceLabel(AppLocalizations l10n, SupportPresence p) => switch (p) {
      SupportPresence.online => l10n.supportPresenceOnline,
      SupportPresence.onBreak => l10n.supportPresenceBreak,
      SupportPresence.signedOut => l10n.supportPresenceSignedOut,
      SupportPresence.disconnected => l10n.supportPresenceDisconnected,
    };

String supportEmploymentLabel(AppLocalizations l10n, SupportEmployment e) => switch (e) {
      SupportEmployment.active => l10n.supportEmploymentActive,
      SupportEmployment.suspended => l10n.supportEmploymentSuspended,
      SupportEmployment.terminated => l10n.supportEmploymentTerminated,
    };

/// Developer console › Support Employee Accounts: create and manage the
/// support team's accounts, salaries and deductions, and see who is online
/// (from a recent report, not an old record).
class SupportAgentsTab extends ConsumerStatefulWidget {
  const SupportAgentsTab({super.key});

  @override
  ConsumerState<SupportAgentsTab> createState() => _SupportAgentsTabState();
}

class _SupportAgentsTabState extends ConsumerState<SupportAgentsTab> {
  late Future<List<SupportAgentRecord>> _agents = _load();
  DateTime _checkedAt = DateTime.now();

  Future<List<SupportAgentRecord>> _load() => ref.read(supportRepositoryProvider)!.listAgents();

  void _refresh() => setState(() {
        _agents = _load();
        _checkedAt = DateTime.now();
      });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: FutureBuilder<List<SupportAgentRecord>>(
        future: _agents,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) {
            return Center(
              child:
                  TextButton.icon(onPressed: _refresh, icon: const Icon(Icons.refresh), label: Text(l10n.actionRetry)),
            );
          }
          final agents = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
            children: [
              Row(
                children: [
                  Expanded(child: Text(l10n.supportAgentsTitle, style: Theme.of(context).textTheme.titleMedium)),
                  Text(l10n.supportCheckedAt(AppDateFormat.time(_checkedAt)),
                      style: Theme.of(context).textTheme.labelSmall),
                  IconButton(tooltip: l10n.actionRefresh, icon: const Icon(Icons.refresh), onPressed: _refresh),
                ],
              ),
              if (agents.isEmpty) Padding(padding: const EdgeInsets.all(24), child: Text(l10n.supportNoAgents)),
              for (final a in agents)
                Card(
                  child: ListTile(
                    leading: _PresenceDot(presence: a.presence(_checkedAt)),
                    title: Text('${a.fullName} · ${a.jobTitle}'),
                    subtitle: Text(
                      [
                        a.email,
                        if (a.phone.isNotEmpty) a.phone,
                        supportEmploymentLabel(l10n, a.employment),
                        supportPresenceLabel(l10n, a.presence(_checkedAt)),
                        if (a.lastSeenAt != null) l10n.supportLastSeen(AppDateFormat.dateTime(a.lastSeenAt!)),
                      ].join(' · '),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      await showDialog<void>(context: context, builder: (_) => _AgentDialog(agent: a));
                      _refresh();
                    },
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.person_add_alt),
        label: Text(l10n.supportAddAgent),
        onPressed: () async {
          await showDialog<void>(context: context, builder: (_) => const _AgentDialog());
          _refresh();
        },
      ),
    );
  }
}

class _PresenceDot extends StatelessWidget {
  const _PresenceDot({required this.presence});
  final SupportPresence presence;

  @override
  Widget build(BuildContext context) {
    final color = switch (presence) {
      SupportPresence.online => Colors.green,
      SupportPresence.onBreak => Colors.orange,
      SupportPresence.signedOut => Colors.grey,
      SupportPresence.disconnected => Colors.red,
    };
    return CircleAvatar(radius: 8, backgroundColor: color);
  }
}

/// Create a support employee, or view and manage one: details, salary,
/// deductions (dated, with a reason, never editing past salary), password
/// reset, suspend / reactivate / end employment.
class _AgentDialog extends ConsumerStatefulWidget {
  const _AgentDialog({this.agent});
  final SupportAgentRecord? agent;

  @override
  ConsumerState<_AgentDialog> createState() => _AgentDialogState();
}

class _AgentDialogState extends ConsumerState<_AgentDialog> {
  late final a = widget.agent;
  late final _name = TextEditingController(text: a?.fullName);
  late final _email = TextEditingController(text: a?.email);
  final _password = TextEditingController();
  late final _phone = TextEditingController(text: a?.phone);
  late final _address = TextEditingController(text: a?.address);
  late final _job = TextEditingController(text: a?.jobTitle);
  late final _salary = TextEditingController(text: a == null ? '' : Money.inputText(a!.salaryMinorUnits));
  late final _notes = TextEditingController(text: a?.notes);
  late Future<List<SalaryAdjustmentRecord>> _adjustments =
      a == null ? Future.value(const []) : ref.read(supportRepositoryProvider)!.salaryAdjustments(a!.id);
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_name, _email, _password, _phone, _address, _job, _salary, _notes]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action, {bool close = false}) async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
      if (!mounted) return;
      if (close) {
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.settingsSaved)));
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final repo = ref.read(supportRepositoryProvider)!;
    final salary = Money.toMinorUnits(double.tryParse(_salary.text) ?? 0);
    if (_name.text.trim().isEmpty) {
      setState(() => _error = l10n.errorRequired);
      return;
    }
    if (a == null) {
      if (!_email.text.contains('@') || _password.text.length < 8) {
        setState(() => _error = l10n.supportAgentCredentialsHint);
        return;
      }
      await _run(
        () => repo.createAgent(
          fullName: _name.text.trim(),
          email: _email.text.trim(),
          password: _password.text,
          phone: _phone.text.trim(),
          address: _address.text.trim(),
          jobTitle: _job.text.trim(),
          salaryMinorUnits: salary,
          notes: _notes.text.trim(),
        ),
        close: true,
      );
    } else {
      await _run(
        () => repo.updateAgent(
          SupportAgentRecord(
            id: a!.id,
            fullName: _name.text.trim(),
            email: a!.email,
            phone: _phone.text.trim(),
            address: _address.text.trim(),
            jobTitle: _job.text.trim(),
            salaryMinorUnits: salary,
            createdAt: a!.createdAt,
            notes: _notes.text.trim(),
          ),
        ),
        close: true,
      );
    }
  }

  Future<void> _resetPassword() async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    final password = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.supportResetPassword),
        content: TextField(
          controller: controller,
          obscureText: true,
          autofocus: true,
          decoration: InputDecoration(labelText: l10n.developerSignInPassword, helperText: l10n.supportPasswordRule),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.actionCancel)),
          FilledButton(onPressed: () => Navigator.of(context).pop(controller.text), child: Text(l10n.actionSave)),
        ],
      ),
    );
    controller.dispose();
    if (password == null) return;
    if (password.length < 8) {
      setState(() => _error = l10n.supportPasswordRule);
      return;
    }
    await _run(() => ref.read(supportRepositoryProvider)!.resetAgentPassword(a!.id, password));
  }

  Future<void> _setEmployment(SupportEmployment status) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(supportEmploymentLabel(l10n, status)),
        content: Text(l10n.supportEmploymentConfirm(a!.fullName, supportEmploymentLabel(l10n, status))),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.actionCancel)),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: Text(l10n.actionConfirm)),
        ],
      ),
    );
    if (ok != true) return;
    await _run(() => ref.read(supportRepositoryProvider)!.setAgentEmployment(a!.id, status), close: true);
  }

  Future<void> _addAdjustment() async {
    final l10n = AppLocalizations.of(context);
    final amount = TextEditingController();
    final reason = TextEditingController();
    var deduction = true;
    var date = DateTime.now();
    final save = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l10n.supportSalaryAdjustment),
          content: SizedBox(
            width: 360,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SegmentedButton<bool>(
                  segments: [
                    ButtonSegment(value: true, label: Text(l10n.supportDeduction)),
                    ButtonSegment(value: false, label: Text(l10n.supportBonus)),
                  ],
                  selected: {deduction},
                  onSelectionChanged: (s) => setState(() => deduction = s.first),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amount,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                  decoration: InputDecoration(labelText: l10n.commonAmount),
                ),
                const SizedBox(height: 12),
                TextField(controller: reason, decoration: InputDecoration(labelText: l10n.supportReason)),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.event),
                  title: Text(AppDateFormat.shortDate(date)),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: date,
                      firstDate: DateTime(date.year - 2),
                      lastDate: DateTime(date.year + 1),
                    );
                    if (picked != null) setState(() => date = picked);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.actionCancel)),
            FilledButton(onPressed: () => Navigator.of(context).pop(true), child: Text(l10n.actionSave)),
          ],
        ),
      ),
    );
    final minor = Money.toMinorUnits(double.tryParse(amount.text) ?? 0);
    final why = reason.text.trim();
    amount.dispose();
    reason.dispose();
    if (save != true) return;
    if (minor <= 0 || why.isEmpty) {
      setState(() => _error = l10n.supportAdjustmentRule);
      return;
    }
    await _run(() async {
      await ref.read(supportRepositoryProvider)!.addSalaryAdjustment(
            agentId: a!.id,
            deduction: deduction,
            amountMinorUnits: minor,
            reason: why,
            effectiveDate: date,
          );
      setState(() => _adjustments = ref.read(supportRepositoryProvider)!.salaryAdjustments(a!.id));
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final agent = a;
    return AlertDialog(
      title: Text(agent == null ? l10n.supportAddAgent : agent.fullName),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (agent != null)
                Text(
                  '${supportEmploymentLabel(l10n, agent.employment)} · ${l10n.supportCreatedOn(AppDateFormat.shortDate(agent.createdAt))}',
                  style: theme.textTheme.bodySmall,
                ),
              const SizedBox(height: 8),
              TextField(controller: _name, decoration: InputDecoration(labelText: l10n.supportFullName)),
              const SizedBox(height: 8),
              TextField(
                controller: _email,
                enabled: agent == null,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: l10n.developerSignInEmail),
              ),
              if (agent == null) ...[
                const SizedBox(height: 8),
                TextField(
                  controller: _password,
                  obscureText: true,
                  decoration:
                      InputDecoration(labelText: l10n.developerSignInPassword, helperText: l10n.supportPasswordRule),
                ),
              ],
              const SizedBox(height: 8),
              TextField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(labelText: l10n.commonPhone)),
              const SizedBox(height: 8),
              TextField(controller: _address, decoration: InputDecoration(labelText: l10n.commonAddress)),
              const SizedBox(height: 8),
              TextField(controller: _job, decoration: InputDecoration(labelText: l10n.supportJobTitle)),
              const SizedBox(height: 8),
              TextField(
                controller: _salary,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                decoration: InputDecoration(labelText: l10n.hrSalary),
              ),
              const SizedBox(height: 8),
              TextField(controller: _notes, maxLines: 2, decoration: InputDecoration(labelText: l10n.supportNotes)),
              if (agent != null) ...[
                const Divider(height: 24),
                Row(
                  children: [
                    Expanded(child: Text(l10n.supportSalaryAdjustments, style: theme.textTheme.titleSmall)),
                    TextButton.icon(
                        onPressed: _busy ? null : _addAdjustment,
                        icon: const Icon(Icons.add),
                        label: Text(l10n.actionAdd)),
                  ],
                ),
                FutureBuilder<List<SalaryAdjustmentRecord>>(
                  future: _adjustments,
                  builder: (context, snapshot) {
                    final rows = snapshot.data ?? const <SalaryAdjustmentRecord>[];
                    if (rows.isEmpty) return Text('—', style: theme.textTheme.bodySmall);
                    return Column(
                      children: [
                        for (final r in rows)
                          ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(r.isDeduction ? Icons.remove_circle_outline : Icons.add_circle_outline,
                                color: r.isDeduction ? theme.colorScheme.error : Colors.green.shade700),
                            title:
                                Text('${r.isDeduction ? '-' : '+'}${Money.format(r.amountMinorUnits)} · ${r.reason}'),
                            subtitle: Text(AppDateFormat.shortDate(r.effectiveDate)),
                          ),
                      ],
                    );
                  },
                ),
                const Divider(height: 24),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _busy ? null : _resetPassword,
                      icon: const Icon(Icons.key),
                      label: Text(l10n.supportResetPassword),
                    ),
                    if (agent.employment != SupportEmployment.active)
                      OutlinedButton(
                        onPressed: _busy ? null : () => _setEmployment(SupportEmployment.active),
                        child: Text(l10n.supportReactivate),
                      ),
                    if (agent.employment == SupportEmployment.active)
                      OutlinedButton(
                        onPressed: _busy ? null : () => _setEmployment(SupportEmployment.suspended),
                        child: Text(l10n.supportSuspend),
                      ),
                    if (agent.employment != SupportEmployment.terminated)
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(foregroundColor: theme.colorScheme.error),
                        onPressed: _busy ? null : () => _setEmployment(SupportEmployment.terminated),
                        child: Text(l10n.supportTerminate),
                      ),
                  ],
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: _busy ? null : () => Navigator.of(context).pop(), child: Text(l10n.actionClose)),
        FilledButton(
          onPressed: _busy ? null : _save,
          child: _busy
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(l10n.actionSave),
        ),
      ],
    );
  }
}
