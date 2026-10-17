import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../backup/data/reset_backup_sink.dart';
import '../../backup/data/store_reset_providers.dart';
import '../../backup/domain/store_reset/reset_scope.dart';
import '../../backup/domain/store_reset/store_reset_service.dart';

/// Resetting the store's data: choose what, see what it removes (first
/// confirmation), confirm naming it (second confirmation), then watch each
/// stage — backup, check, reset, clean-up — and the summary.
class StoreResetDialog extends ConsumerStatefulWidget {
  const StoreResetDialog({super.key, required this.storeId, required this.actorId, this.sink});

  final String storeId;

  /// The owner doing it.
  final String actorId;

  /// Where the backup goes (the platform's save dialog when null).
  final BackupSink? sink;

  static Future<void> show(BuildContext context,
          {required String storeId, required String actorId, BackupSink? sink}) =>
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => StoreResetDialog(storeId: storeId, actorId: actorId, sink: sink),
      );

  @override
  ConsumerState<StoreResetDialog> createState() => _StoreResetDialogState();
}

enum _Page { choose, consequences, confirm, progress }

enum _StageState { waiting, running, done, failed }

class _StoreResetDialogState extends ConsumerState<StoreResetDialog> {
  _Page _page = _Page.choose;
  final Set<ResetScope> _chosen = {};
  Map<String, int>? _preview;
  Object? _previewError;
  final Map<ResetStage, _StageState> _stages = {for (final s in ResetStage.values) s: _StageState.waiting};
  String? _error;
  StoreResetOutcome? _outcome;
  bool _running = false;

  StoreResetService get _service => ref.read(storeResetServiceProvider(widget.storeId));

  List<ResetScope> get _expanded => ResetPlan.expand(_chosen);

  @override
  void initState() {
    super.initState();
    // A reset left half-way earlier is finished (or forgotten) first.
    Future.microtask(() => finishStoreResets(ref, widget.storeId));
  }

  String _scopeTitle(AppLocalizations l10n, ResetScope s) => switch (s) {
        ResetScope.full => l10n.storeResetScopeFull,
        ResetScope.sales => l10n.storeResetScopeSales,
        ResetScope.debts => l10n.storeResetScopeDebts,
        ResetScope.expenses => l10n.storeResetScopeExpenses,
        ResetScope.accounting => l10n.storeResetScopeAccounting,
        ResetScope.customers => l10n.storeResetScopeCustomers,
        ResetScope.inventory => l10n.storeResetScopeInventory,
        ResetScope.suppliers => l10n.storeResetScopeSuppliers,
        ResetScope.shifts => l10n.storeResetScopeShifts,
      };

  String _scopeHelp(AppLocalizations l10n, ResetScope s) => switch (s) {
        ResetScope.full => l10n.storeResetScopeFullHelp,
        ResetScope.sales => l10n.storeResetScopeSalesHelp,
        ResetScope.debts => l10n.storeResetScopeDebtsHelp,
        ResetScope.expenses => l10n.storeResetScopeExpensesHelp,
        ResetScope.accounting => l10n.storeResetScopeAccountingHelp,
        ResetScope.customers => l10n.storeResetScopeCustomersHelp,
        ResetScope.inventory => l10n.storeResetScopeInventoryHelp,
        ResetScope.suppliers => l10n.storeResetScopeSuppliersHelp,
        ResetScope.shifts => l10n.storeResetScopeShiftsHelp,
      };

  static String tableLabel(AppLocalizations l10n, String table) => switch (table) {
        'sales' => l10n.storeResetTableSales,
        'sale_lines' => l10n.storeResetTableSaleLines,
        'sale_returns' => l10n.storeResetTableSaleReturns,
        'sale_return_lines' => l10n.storeResetTableSaleReturnLines,
        'debt_ledger_entries' => l10n.storeResetTableDebts,
        'debt_payments' => l10n.storeResetTableDebtPayments,
        'loyalty_transactions' => l10n.storeResetTableLoyalty,
        'customers_points_adjusted' => l10n.storeResetTablePointsAdjusted,
        'customers' => l10n.storeResetTableCustomers,
        'sales_unlinked_from_customers' => l10n.storeResetTableSalesUnlinked,
        'expense_details' => l10n.storeResetTableExpenses,
        'journal_entries' => l10n.storeResetTableJournalEntries,
        'journal_lines' => l10n.storeResetTableJournalLines,
        'products' => l10n.storeResetTableProducts,
        'stock_items' => l10n.storeResetTableStockItems,
        'stock_movements' => l10n.storeResetTableStockMovements,
        'categories' => l10n.storeResetTableCategories,
        'discounts' => l10n.storeResetTableDiscounts,
        'purchase_orders' => l10n.storeResetTablePurchaseOrders,
        'purchase_order_lines' => l10n.storeResetTablePurchaseOrderLines,
        'stock_transfers' => l10n.storeResetTableTransfers,
        'stock_transfer_lines' => l10n.storeResetTableTransferLines,
        'suppliers' => l10n.storeResetTableSuppliers,
        'supplier_transactions' => l10n.storeResetTableSupplierTransactions,
        'shifts' => l10n.storeResetTableShifts,
        'employee_breaks' => l10n.storeResetTableBreaks,
        _ => table,
      };

  String _scopesLabel(AppLocalizations l10n) {
    if (_chosen.contains(ResetScope.full)) return _scopeTitle(l10n, ResetScope.full);
    return _expanded.map((s) => _scopeTitle(l10n, s)).join(' · ');
  }

  String _errorText(AppLocalizations l10n, Object e) {
    if (e is StoreResetCancelled) return l10n.storeResetErrorCancelled;
    if (e is StoreResetFailure) {
      final cause = '${e.cause ?? ''}';
      return switch (e.reason) {
        StoreResetFailureReason.offline => l10n.storeResetErrorOffline,
        StoreResetFailureReason.unsentChanges => l10n.storeResetErrorUnsent,
        StoreResetFailureReason.backupFailed => l10n.storeResetErrorBackup(cause),
        StoreResetFailureReason.verifyFailed => l10n.storeResetErrorVerify,
        StoreResetFailureReason.refused => l10n.storeResetErrorRefused(cause),
        StoreResetFailureReason.unknown => l10n.storeResetErrorUnknown,
      };
    }
    return l10n.storeResetErrorRefused('$e');
  }

  Future<void> _loadPreview() async {
    setState(() {
      _page = _Page.consequences;
      _preview = null;
      _previewError = null;
    });
    try {
      final counts = await _service.preview(_chosen.toList());
      if (mounted) setState(() => _preview = counts);
    } catch (e) {
      if (mounted) setState(() => _previewError = e);
    }
  }

  Future<void> _run() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _page = _Page.progress;
      _running = true;
      _error = null;
    });
    ResetStage? current;
    try {
      final outcome = await _service.run(
        chosen: _chosen.toList(),
        actorId: widget.actorId,
        sink: widget.sink ?? FileBackupSink(dialogTitle: l10n.storeResetSaveDialogTitle),
        onStage: (stage) {
          if (!mounted) return;
          setState(() {
            if (current != null) _stages[current!] = _StageState.done;
            current = stage;
            _stages[stage] = _StageState.running;
          });
        },
      );
      if (!mounted) return;
      refreshAfterStoreReset(ref, outcome.result.scopes);
      setState(() {
        for (final s in ResetStage.values) {
          _stages[s] = _StageState.done;
        }
        _outcome = outcome;
      });
    } catch (e) {
      if (!mounted) return;
      final failed = e is StoreResetFailure ? e.stage : (current ?? ResetStage.backup);
      setState(() {
        _stages[failed] = _StageState.failed;
        _error = _errorText(l10n, e);
      });
    } finally {
      if (mounted) setState(() => _running = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final size = MediaQuery.sizeOf(context);
    final content = switch (_page) {
      _Page.choose => _buildChoose(l10n),
      _Page.consequences => _buildConsequences(l10n),
      _Page.confirm => _buildConfirm(l10n),
      _Page.progress => _buildProgress(l10n),
    };
    return AlertDialog(
      title: Text(switch (_page) {
        _Page.choose => l10n.storeResetChooseTitle,
        _Page.consequences => l10n.storeResetConsequencesTitle,
        _Page.confirm => l10n.storeResetFinalTitle(_scopesLabel(l10n)),
        _Page.progress => _outcome != null
            ? l10n.storeResetDoneTitle
            : _error != null
                ? l10n.storeResetFailedTitle
                : l10n.settingsFactoryReset,
      }),
      content: SizedBox(
        width: size.width < 600 ? size.width : 560,
        child: SingleChildScrollView(child: content),
      ),
      actions: _actions(l10n),
    );
  }

  List<Widget> _actions(AppLocalizations l10n) {
    final error = Theme.of(context).colorScheme.error;
    void close() => Navigator.of(context).pop();
    switch (_page) {
      case _Page.choose:
        return [
          TextButton(onPressed: close, child: Text(l10n.actionCancel)),
          FilledButton(onPressed: _chosen.isEmpty ? null : _loadPreview, child: Text(l10n.actionNext)),
        ];
      case _Page.consequences:
        return [
          TextButton(onPressed: () => setState(() => _page = _Page.choose), child: Text(l10n.actionBack)),
          FilledButton(
            onPressed: _preview == null ? null : () => setState(() => _page = _Page.confirm),
            child: Text(l10n.actionContinue),
          ),
        ];
      case _Page.confirm:
        return [
          TextButton(onPressed: close, child: Text(l10n.actionCancel)),
          FilledButton(
            key: const ValueKey('store-reset-confirm'),
            style:
                FilledButton.styleFrom(backgroundColor: error, foregroundColor: Theme.of(context).colorScheme.onError),
            onPressed: _run,
            child: Text(l10n.storeResetConfirmButton),
          ),
        ];
      case _Page.progress:
        return [
          if (_error != null && !_running)
            TextButton(onPressed: () => setState(() => _page = _Page.confirm), child: Text(l10n.actionBack)),
          FilledButton(onPressed: _running ? null : close, child: Text(l10n.actionClose)),
        ];
    }
  }

  Widget _buildChoose(AppLocalizations l10n) {
    final implied = _expanded.toSet().difference(_chosen);
    final full = _chosen.contains(ResetScope.full);
    Widget tile(ResetScope s) {
      final included = full && s != ResetScope.full || implied.contains(s);
      return CheckboxListTile(
        key: ValueKey('store-reset-${s.name}'),
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
        value: _chosen.contains(s) || included,
        onChanged: included && !_chosen.contains(s)
            ? null
            : (v) => setState(() {
                  if (v == true) {
                    if (s == ResetScope.full) _chosen.clear();
                    _chosen.add(s);
                  } else {
                    _chosen.remove(s);
                  }
                }),
        title: Text(_scopeTitle(l10n, s)),
        subtitle: Text(
          included && s != ResetScope.full && !full
              ? '${l10n.storeResetImpliedNote}\n${_scopeHelp(l10n, s)}'
              : _scopeHelp(l10n, s),
        ),
        isThreeLine: true,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        tile(ResetScope.full),
        const Divider(),
        for (final s in ResetPlan.parts) tile(s),
        const SizedBox(height: 8),
        Text(l10n.storeResetKeptNote, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _counts(AppLocalizations l10n, Map<String, int> counts) {
    final rows = counts.entries.where((e) => e.value > 0).toList();
    if (rows.isEmpty) return Text(l10n.storeResetNothingToRemove);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final e in rows)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Expanded(child: Text(tableLabel(l10n, e.key))),
                Text('${e.value}', style: const TextStyle(fontFeatures: [FontFeature.tabularFigures()])),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildConsequences(AppLocalizations l10n) {
    final theme = Theme.of(context);
    final preview = _preview;
    final previewError = _previewError;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final s in _chosen.contains(ResetScope.full) ? const [ResetScope.full] : _expanded)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_scopeTitle(l10n, s), style: theme.textTheme.titleSmall),
                Text(_scopeHelp(l10n, s), style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        const Divider(),
        Text(l10n.storeResetWillRemove, style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        if (previewError != null)
          Text(_errorText(l10n, previewError), style: TextStyle(color: theme.colorScheme.error))
        else if (preview == null)
          Row(children: [
            const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            const SizedBox(width: 12),
            Expanded(child: Text(l10n.storeResetLoadingPreview)),
          ])
        else
          _counts(l10n, preview),
        const SizedBox(height: 12),
        Text(l10n.storeResetBackupNote),
        const SizedBox(height: 8),
        Text(l10n.storeResetKeptNote, style: theme.textTheme.bodySmall),
      ],
    );
  }

  Widget _buildConfirm(AppLocalizations l10n) {
    final full = _chosen.contains(ResetScope.full);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          full ? l10n.storeResetFinalFull : l10n.storeResetFinalPartial(_scopesLabel(l10n)),
          style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Text(l10n.storeResetBackupNote),
      ],
    );
  }

  Widget _buildProgress(AppLocalizations l10n) {
    final theme = Theme.of(context);
    final server = _service.backend.isServer;
    String label(ResetStage s) => switch (s) {
          ResetStage.backup => l10n.storeResetStageBackup,
          ResetStage.verify => l10n.storeResetStageVerify,
          ResetStage.reset => server ? l10n.storeResetStageServer : l10n.storeResetStageLocal,
          ResetStage.cleanup => l10n.storeResetStageCleanup,
        };
    Widget icon(_StageState state) => switch (state) {
          _StageState.waiting => Icon(Icons.radio_button_unchecked, color: theme.disabledColor),
          _StageState.running =>
            const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
          _StageState.done => Icon(Icons.check_circle, color: theme.colorScheme.primary),
          _StageState.failed => Icon(Icons.error, color: theme.colorScheme.error),
        };
    final outcome = _outcome;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final s in ResetStage.values)
          if (server || s != ResetStage.cleanup)
            ListTile(
              key: ValueKey('store-reset-stage-${s.name}-${_stages[s]!.name}'),
              contentPadding: EdgeInsets.zero,
              leading: icon(_stages[s]!),
              title: Text(label(s)),
            ),
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
        ],
        if (outcome != null) ...[
          const Divider(),
          Text(
            l10n.storeResetDoneRemoved(outcome.result.counts.values.fold(0, (a, b) => a + b)),
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          _counts(l10n, outcome.result.counts),
          const SizedBox(height: 12),
          if (outcome.backup != null) SelectableText(l10n.storeResetDoneBackup(outcome.backup!.location)),
          if (outcome.droppedChanges > 0) ...[
            const SizedBox(height: 8),
            Text(l10n.storeResetDoneDropped(outcome.droppedChanges)),
          ],
        ],
      ],
    );
  }
}
