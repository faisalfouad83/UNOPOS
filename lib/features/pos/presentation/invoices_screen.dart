import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/permissions.dart';
import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/utils/formatters.dart';
import '../../accounting/presentation/account_labels.dart';
import '../../auth/domain/auth_models.dart';
import '../../auth/domain/session_controller.dart';
import '../../auth/presentation/tile_picker_screen.dart';
import '../../debts/domain/debts_models.dart';
import '../domain/invoice_query.dart';
import '../domain/pos_models.dart';
import '../domain/pos_repository.dart';
import 'invoice_details_dialog.dart';
import '../../../core/theming/store_themes.dart';

final _customersProvider = StreamProvider.autoDispose.family<List<CustomerRecord>, String>((ref, storeId) {
  return ref.watch(debtsRepositoryProvider).watchCustomers(storeId);
});

/// Names shown next to ids on invoices.
class InvoiceNames {
  const InvoiceNames({this.branches = const {}, this.cashiers = const {}, this.customers = const {}});
  final Map<String, String> branches;
  final Map<String, String> cashiers;
  final Map<String, CustomerRecord> customers;

  String branch(String id) => branches[id] ?? '—';
  String cashier(String id) => cashiers[id] ?? '—';
}

String invoiceStatusLabel(AppLocalizations l10n, InvoiceStatus status) => switch (status) {
      InvoiceStatus.completed => l10n.invoiceStatusCompleted,
      InvoiceStatus.partiallyRefunded => l10n.returnStatusPartial,
      InvoiceStatus.refunded => l10n.returnStatusRefunded,
      InvoiceStatus.cancelled => l10n.invoiceStatusCancelled,
      InvoiceStatus.unpaid => l10n.invoiceStatusUnpaid,
      InvoiceStatus.partiallyPaid => l10n.invoiceStatusPartiallyPaid,
      InvoiceStatus.paid => l10n.invoiceStatusPaid,
    };

Color invoiceStatusColor(ThemeData theme, InvoiceStatus status) => switch (status) {
      InvoiceStatus.completed || InvoiceStatus.paid => theme.extension<StatusColors>()?.success ?? ThemePalettes.light.success,
      InvoiceStatus.unpaid || InvoiceStatus.cancelled => theme.colorScheme.error,
      InvoiceStatus.partiallyPaid || InvoiceStatus.partiallyRefunded =>
        theme.extension<StatusColors>()?.warning ?? ThemePalettes.light.warning,
      InvoiceStatus.refunded => theme.colorScheme.outline,
    };

/// Every invoice of the store: search by number or customer, filter by
/// date, branch, cashier, payment and status, sort, and open one for its
/// lines, payments, reprint and returns. Loads a page at a time.
class InvoicesScreen extends ConsumerStatefulWidget {
  const InvoicesScreen({super.key});

  @override
  ConsumerState<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends ConsumerState<InvoicesScreen> {
  static const _pageSize = 40;

  final _scroll = ScrollController();
  final _search = TextEditingController();
  Timer? _debounce;

  DateTimeRange? _range;
  String? _branchId;
  bool _branchChosen = false;
  String? _cashierId;
  SalePaymentMethod? _payment;
  InvoiceStatus? _status;
  InvoiceSort _sort = InvoiceSort.newest;

  final _rows = <InvoiceRecord>[];
  bool _loading = false;
  bool _hasMore = true;
  Object? _error;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.extentAfter < 400) _loadMore();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _reload());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scroll.dispose();
    _search.dispose();
    super.dispose();
  }

  SessionState get _session => ref.read(sessionControllerProvider);

  /// Accounts with the reports permission see every cashier's invoices;
  /// others only their own. An account tied to a branch sees that branch.
  bool get _seesAllCashiers => _session.employee?.can(AppPermission.reports) ?? false;
  String? get _lockedBranch => _session.employee?.branchId;

  InvoiceQuery? _query() {
    final session = _session;
    final storeId = session.store?.id;
    if (storeId == null) return null;
    final text = _search.text.trim();
    final isNumber = text.isNotEmpty && looksLikeSaleNumber(text);
    Set<String>? customerIds;
    if (text.isNotEmpty && !isNumber) {
      final customers = ref.read(_customersProvider(storeId)).valueOrNull ?? const <CustomerRecord>[];
      final q = text.toLowerCase();
      customerIds = customers
          .where((c) => c.name.toLowerCase().contains(q) || (c.phone ?? '').contains(q))
          .map((c) => c.id)
          .toSet();
    }
    return InvoiceQuery(
      storeId: storeId,
      branchId: _lockedBranch ?? (_branchChosen ? _branchId : session.currentBranchId),
      cashierId: _seesAllCashiers ? _cashierId : session.employee?.id,
      paymentMethod: _payment,
      status: _status,
      from: _range?.start,
      to: _range == null ? null : DateTime(_range!.end.year, _range!.end.month, _range!.end.day, 23, 59, 59, 999),
      number: isNumber ? text : null,
      customerIds: customerIds,
      sort: _sort,
      limit: _pageSize,
    );
  }

  Future<void> _reload() async {
    _generation++;
    setState(() {
      _rows.clear();
      _hasMore = true;
      _error = null;
      _loading = false;
    });
    await _loadMore();
  }

  Future<void> _loadMore() async {
    if (_loading || !_hasMore) return;
    final query = _query()?.page(_rows.length);
    if (query == null) return;
    final generation = _generation;
    setState(() => _loading = true);
    try {
      final page = await ref.read(posRepositoryProvider).listInvoices(query);
      // Filters changed while this page was loading: drop it.
      if (!mounted || generation != _generation) return;
      setState(() {
        _rows.addAll(page);
        _hasMore = page.length == query.limit;
      });
    } catch (e) {
      if (mounted && generation == _generation) setState(() => _error = e);
    } finally {
      if (mounted && generation == _generation) setState(() => _loading = false);
    }
  }

  void _onSearchChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _reload);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final session = ref.watch(sessionControllerProvider);
    final storeId = session.store?.id;
    if (storeId == null) return const Scaffold(body: SizedBox.shrink());

    final branches = ref.watch(storeBranchesProvider(storeId)).value ?? const <BranchRecord>[];
    final employees = ref.watch(storeEmployeesProvider(storeId)).value ?? const <EmployeeRecord>[];
    final customers = ref.watch(_customersProvider(storeId)).value ?? const <CustomerRecord>[];
    final names = InvoiceNames(
      branches: {for (final b in branches) b.id: b.name},
      cashiers: {for (final e in employees) e.id: e.name},
      customers: {for (final c in customers) c.id: c},
    );
    final effectiveBranch = _lockedBranch ?? (_branchChosen ? _branchId : session.currentBranchId);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navInvoices),
        actions: [
          IconButton(tooltip: l10n.actionRefresh, icon: const Icon(Icons.refresh), onPressed: _reload),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: TextField(
              controller: _search,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: l10n.invoiceSearchHint,
                suffixIcon: _search.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _search.clear();
                          _reload();
                        },
                      ),
              ),
              onChanged: _onSearchChanged,
              onSubmitted: (_) => _reload(),
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _FilterChip(
                  icon: Icons.date_range,
                  label: _range == null
                      ? l10n.invoiceAnyDate
                      : '${AppDateFormat.shortDate(_range!.start)} – ${AppDateFormat.shortDate(_range!.end)}',
                  active: _range != null,
                  onTap: () async {
                    final now = DateTime.now();
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(now.year - 10),
                      lastDate: DateTime(now.year, now.month, now.day),
                      initialDateRange: _range,
                    );
                    if (picked != null) {
                      _range = picked;
                      _reload();
                    }
                  },
                  onClear: _range == null
                      ? null
                      : () {
                          _range = null;
                          _reload();
                        },
                ),
                if (_lockedBranch == null && branches.length > 1)
                  _MenuChip<String?>(
                    icon: Icons.storefront_outlined,
                    label: effectiveBranch == null ? l10n.invoiceAllBranches : names.branch(effectiveBranch),
                    active: true,
                    items: [
                      (null, l10n.invoiceAllBranches),
                      for (final b in branches) (b.id, b.name),
                    ],
                    onSelected: (v) {
                      _branchChosen = true;
                      _branchId = v;
                      _reload();
                    },
                  ),
                _MenuChip<SalePaymentMethod?>(
                  icon: Icons.payments_outlined,
                  label: _payment == null ? l10n.invoiceAnyPayment : paymentMethodLabel(l10n, _payment),
                  active: _payment != null,
                  items: [
                    (null, l10n.invoiceAnyPayment),
                    for (final m in SalePaymentMethod.values) (m, paymentMethodLabel(l10n, m)),
                  ],
                  onSelected: (v) {
                    _payment = v;
                    _reload();
                  },
                ),
                if (_seesAllCashiers)
                  _MenuChip<String?>(
                    icon: Icons.badge_outlined,
                    label: _cashierId == null ? l10n.invoiceAnyCashier : names.cashier(_cashierId!),
                    active: _cashierId != null,
                    items: [
                      (null, l10n.invoiceAnyCashier),
                      for (final e in employees) (e.id, e.name),
                    ],
                    onSelected: (v) {
                      _cashierId = v;
                      _reload();
                    },
                  ),
                _MenuChip<InvoiceStatus?>(
                  icon: Icons.flag_outlined,
                  label: _status == null ? l10n.invoiceAnyStatus : invoiceStatusLabel(l10n, _status!),
                  active: _status != null,
                  items: [
                    (null, l10n.invoiceAnyStatus),
                    for (final s in InvoiceStatus.values) (s, invoiceStatusLabel(l10n, s)),
                  ],
                  onSelected: (v) {
                    _status = v;
                    _reload();
                  },
                ),
                _MenuChip<InvoiceSort>(
                  icon: Icons.sort,
                  label: _sortLabel(l10n, _sort),
                  active: _sort != InvoiceSort.newest,
                  items: [for (final s in InvoiceSort.values) (s, _sortLabel(l10n, s))],
                  onSelected: (v) {
                    _sort = v;
                    _reload();
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(child: _buildList(context, l10n, names)),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, AppLocalizations l10n, InvoiceNames names) {
    if (_rows.isEmpty) {
      if (_loading) return const Center(child: CircularProgressIndicator());
      if (_error != null) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.errorGeneric),
              const SizedBox(height: 8),
              FilledButton.icon(onPressed: _reload, icon: const Icon(Icons.refresh), label: Text(l10n.actionRetry)),
            ],
          ),
        );
      }
      return Center(child: Text(l10n.invoiceNone));
    }
    return RefreshIndicator(
      onRefresh: _reload,
      child: ListView.separated(
        controller: _scroll,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _rows.length + 1,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          if (i == _rows.length) {
            if (_loading) {
              return const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()));
            }
            if (_error != null) {
              return TextButton.icon(
                  onPressed: _loadMore, icon: const Icon(Icons.refresh), label: Text(l10n.actionRetry));
            }
            return const SizedBox(height: 24);
          }
          final row = _rows[i];
          return _InvoiceTile(
            invoice: row,
            names: names,
            onTap: () async {
              // This screen's context: it stays while the details are open.
              await showInvoiceDetails(this.context, ref, row, names);
              // A return or payment may have changed it.
              if (mounted) _reload();
            },
          );
        },
      ),
    );
  }

  static String _sortLabel(AppLocalizations l10n, InvoiceSort sort) => switch (sort) {
        InvoiceSort.newest => l10n.invoiceSortNewest,
        InvoiceSort.oldest => l10n.invoiceSortOldest,
        InvoiceSort.numberDesc => l10n.invoiceSortNumberDesc,
        InvoiceSort.numberAsc => l10n.invoiceSortNumberAsc,
        InvoiceSort.amountDesc => l10n.invoiceSortAmountDesc,
        InvoiceSort.amountAsc => l10n.invoiceSortAmountAsc,
      };
}

class _InvoiceTile extends StatelessWidget {
  const _InvoiceTile({required this.invoice, required this.names, required this.onTap});

  final InvoiceRecord invoice;
  final InvoiceNames names;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final sale = invoice.sale;
    final status = invoice.status;
    final customer = sale.customerId == null ? null : names.customers[sale.customerId];
    final customerLabel = customer?.name ?? (invoice.isPayLater ? l10n.invoiceCreditCustomer : l10n.customerWalkIn);
    final wide = MediaQuery.sizeOf(context).width >= 760;

    final statusChip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: invoiceStatusColor(theme, status).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        invoiceStatusLabel(l10n, status),
        style: theme.textTheme.labelSmall?.copyWith(color: invoiceStatusColor(theme, status)),
      ),
    );

    final amounts = Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(Money.format(invoice.totalMinorUnits), style: theme.textTheme.titleMedium),
        if (invoice.remainingMinorUnits > 0)
          Text(
            '${l10n.payRemaining}: ${Money.format(invoice.remainingMinorUnits)}',
            style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.error),
          ),
      ],
    );

    final meta = [
      AppDateFormat.dateTime(sale.completedAt ?? sale.createdAt),
      names.branch(sale.branchId),
      names.cashier(sale.cashierId),
      paymentMethodLabel(l10n, sale.paymentMethod),
    ].join(' · ');

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Icon(Icons.receipt_long_outlined, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(sale.saleNumber, style: theme.textTheme.titleSmall),
                      statusChip,
                      Text(customerLabel, style: theme.textTheme.bodySmall),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(meta, style: theme.textTheme.bodySmall, maxLines: wide ? 1 : 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(width: 12),
            amounts,
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.icon, required this.label, required this.active, required this.onTap, this.onClear});

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: InputChip(
        avatar: Icon(icon, size: 18),
        label: Text(label),
        selected: active,
        showCheckmark: false,
        onPressed: onTap,
        onDeleted: onClear,
      ),
    );
  }
}

class _MenuChip<T> extends StatelessWidget {
  const _MenuChip({
    required this.icon,
    required this.label,
    required this.active,
    required this.items,
    required this.onSelected,
  });

  final IconData icon;
  final String label;
  final bool active;
  final List<(T, String)> items;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: Builder(
        builder: (chipContext) => InputChip(
          avatar: Icon(icon, size: 18),
          label:
              Row(mainAxisSize: MainAxisSize.min, children: [Text(label), const Icon(Icons.arrow_drop_down, size: 18)]),
          selected: active,
          showCheckmark: false,
          onPressed: () async {
            final box = chipContext.findRenderObject() as RenderBox;
            final overlay = Overlay.of(chipContext).context.findRenderObject() as RenderBox;
            final position = RelativeRect.fromRect(
              Rect.fromPoints(
                box.localToGlobal(Offset(0, box.size.height), ancestor: overlay),
                box.localToGlobal(box.size.bottomRight(Offset.zero), ancestor: overlay),
              ),
              Offset.zero & overlay.size,
            );
            final picked = await showMenu<(T,)>(
              context: chipContext,
              position: position,
              items: [for (final (value, text) in items) PopupMenuItem(value: (value,), child: Text(text))],
            );
            if (picked != null) onSelected(picked.$1);
          },
        ),
      ),
    );
  }
}
