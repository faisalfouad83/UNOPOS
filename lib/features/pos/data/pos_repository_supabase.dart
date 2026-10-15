import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/offline/offline_cache.dart';
import '../../../core/offline/outbox.dart';
import '../../../core/offline/sync_service.dart';
import '../../../core/utils/id_generator.dart';
import '../../debts/domain/debts_models.dart';
import '../domain/invoice_query.dart';
import '../domain/pos_models.dart';
import '../domain/pos_repository.dart';

/// Ordinary (non-atomic-composite) implementation of [PosRepository] itself
/// — still needed directly for `holdSale` (no other side effects to make
/// atomic) and any other direct caller outside the checkout flow. The
/// money-critical path (`checkout`/`processReturn`) goes through the
/// `checkout_sale`/`process_sale_return` RPCs instead, wired up in
/// `SupabaseAtomicCompleteSaleUseCase`/`SupabaseAtomicProcessSaleReturnUseCase`
/// — see complete_sale_use_case.dart / process_sale_return_use_case.dart.
class SupabasePosRepository implements PosRepository {
  SupabasePosRepository(this._client, this._writer);

  final SupabaseClient _client;
  final OfflineWriter _writer;

  SaleLineRecord _mapLine(Map<String, dynamic> row) => SaleLineRecord(
        id: row['id'] as String,
        saleId: row['sale_id'] as String,
        productId: row['product_id'] as String,
        quantity: (row['quantity'] as num).toInt(),
        unitPriceMinorUnits: (row['unit_price_minor_units'] as num).toInt(),
        discountAmountMinorUnits: (row['discount_amount_minor_units'] as num?)?.toInt() ?? 0,
        taxAmountMinorUnits: (row['tax_amount_minor_units'] as num?)?.toInt() ?? 0,
        lineTotalMinorUnits: (row['line_total_minor_units'] as num).toInt(),
        costPriceSnapshotMinorUnits: (row['cost_price_snapshot_minor_units'] as num?)?.toInt() ?? 0,
        quantityReturned: (row['quantity_returned'] as num?)?.toInt() ?? 0,
      );

  SaleRecord _mapSale(Map<String, dynamic> row, List<SaleLineRecord> lines) => SaleRecord(
        id: row['id'] as String,
        storeId: row['store_id'] as String,
        branchId: row['branch_id'] as String,
        saleNumber: row['sale_number'] as String,
        status: SaleStatus.values.firstWhere((s) => s.name == row['status']),
        customerId: row['customer_id'] as String?,
        holdLabel: row['hold_label'] as String?,
        subtotalMinorUnits: (row['subtotal_minor_units'] as num?)?.toInt() ?? 0,
        discountTotalMinorUnits: (row['discount_total_minor_units'] as num?)?.toInt() ?? 0,
        taxTotalMinorUnits: (row['tax_total_minor_units'] as num?)?.toInt() ?? 0,
        grandTotalMinorUnits: (row['grand_total_minor_units'] as num?)?.toInt() ?? 0,
        paymentMethod: row['payment_method'] == null
            ? null
            : SalePaymentMethod.values.firstWhere((p) => p.name == row['payment_method']),
        amountTenderedMinorUnits: (row['amount_tendered_minor_units'] as num?)?.toInt(),
        changeGivenMinorUnits: (row['change_given_minor_units'] as num?)?.toInt(),
        shiftId: row['shift_id'] as String?,
        cashierId: row['cashier_id'] as String,
        journalEntryId: row['journal_entry_id'] as String?,
        createdAt: DateTime.parse(row['created_at'] as String).toLocal(),
        completedAt: row['completed_at'] == null ? null : DateTime.parse(row['completed_at'] as String).toLocal(),
        lines: lines,
      );

  @override
  Future<SaleRecord> createSale({
    required String storeId,
    required String branchId,
    required String cashierId,
    String? shiftId,
    String? customerId,
    String? holdLabel,
    required SaleStatus status,
    required List<SaleLineInput> lines,
  }) async {
    // Works offline too (held sales): the sale is made on this device and
    // sent later; its number comes from the server when it can be asked.
    String saleNumber;
    try {
      if (!_writer.sendsNow) throw const NeedsConnectionException();
      saleNumber = await _client.rpc('next_sale_number').timeout(const Duration(seconds: 6)) as String;
    } catch (e) {
      if (e is! NeedsConnectionException && !isTransientError(e)) rethrow;
      saleNumber = 'H-${IdGenerator.newId().substring(0, 6).toUpperCase()}';
    }

    final subtotal = lines.fold<int>(0, (s, l) => s + l.unitPriceMinorUnits * l.quantity);
    final discountTotal = lines.fold<int>(0, (s, l) => s + l.discountAmountMinorUnits);
    final taxTotal = lines.fold<int>(0, (s, l) => s + l.taxAmountMinorUnits);
    final grandTotal = subtotal - discountTotal + taxTotal;

    final header = await _writer.insert('sales', {
      'store_id': storeId,
      'branch_id': branchId,
      'sale_number': saleNumber,
      'status': status.name,
      'customer_id': customerId,
      'hold_label': holdLabel,
      'subtotal_minor_units': subtotal,
      'discount_total_minor_units': discountTotal,
      'tax_total_minor_units': taxTotal,
      'grand_total_minor_units': grandTotal,
      'shift_id': shiftId,
      'cashier_id': cashierId,
      'created_at': DateTime.now().toUtc().toIso8601String(),
    });
    final saleId = header['id'] as String;

    final mappedLines = <SaleLineRecord>[];
    for (final l in lines) {
      final row = await _writer.insert('sale_lines', {
        'store_id': storeId,
        'sale_id': saleId,
        'product_id': l.productId,
        'quantity': l.quantity,
        'unit_price_minor_units': l.unitPriceMinorUnits,
        'discount_amount_minor_units': l.discountAmountMinorUnits,
        'tax_amount_minor_units': l.taxAmountMinorUnits,
        'line_total_minor_units': l.lineTotalMinorUnits,
        'cost_price_snapshot_minor_units': l.costPriceSnapshotMinorUnits,
      });
      mappedLines.add(_mapLine(row));
    }
    return _mapSale(header, mappedLines);
  }

  @override
  Future<void> completeSale({
    required String saleId,
    required SalePaymentMethod paymentMethod,
    int? amountTenderedMinorUnits,
    int? changeGivenMinorUnits,
    String? journalEntryId,
  }) async {
    await _writer.update(
        'sales',
        {
          'status': 'completed',
          'payment_method': paymentMethod.name,
          'amount_tendered_minor_units': amountTenderedMinorUnits,
          'change_given_minor_units': changeGivenMinorUnits,
          'journal_entry_id': journalEntryId,
          'completed_at': DateTime.now().toUtc().toIso8601String(),
        },
        value: saleId);
  }

  @override
  Future<SaleRecord?> getSale(String saleId) async {
    var rows = await fetchRowsOrCached(
      'sale.$saleId',
      () async => (await _client.from('sales').select().eq('id', saleId)).cast<Map<String, dynamic>>(),
      table: 'sales',
      where: (r) => r['id'] == saleId,
    );
    if (rows == null || rows.isEmpty) {
      // Never opened on its own while online (a held sale being resumed
      // offline, say): the copies of the held and sold lists on this device.
      final cached = await _cachedSaleRow(saleId);
      if (cached == null) return null;
      rows = Outbox.shared.applyTo('sales', [cached], where: (r) => r['id'] == saleId);
      if (rows.isEmpty) return null;
    }
    return (await _withLines(rows)).first;
  }

  /// Stores whose held and sold lists this device keeps a copy of.
  static final _knownStores = <String>{};

  Future<Map<String, dynamic>?> _cachedSaleRow(String saleId) async {
    for (final storeId in _knownStores) {
      for (final key in [_heldKey(storeId), _completedKey(storeId)]) {
        final rows = await OfflineCache.readRows(key) ?? const [];
        final row = rows.where((r) => r['id'] == saleId).firstOrNull;
        if (row != null) return row;
      }
    }
    return null;
  }

  @override
  Future<SaleRecord> reholdSale({
    required String saleId,
    required List<SaleLineInput> lines,
    String? customerId,
    String? holdLabel,
  }) async {
    if (_writer.sendsNow) {
      try {
        // Runs exactly once on the server (keyed by its operation id).
        final result = await _writer.rpc('rehold_sale', {
          'p_sale_id': saleId,
          'p_lines': lines.map(saleLineJson).toList(),
          'p_customer_id': customerId,
          'p_hold_label': holdLabel,
        });
        final newId = (result as Map?)?['sale_id'] as String?;
        final sale = newId == null ? null : await getSale(newId);
        if (sale != null) return sale;
      } on NeedsConnectionException {
        // Lost the connection: done on this device below.
      } on PostgrestException catch (e) {
        if (e.message.contains('held sale not found')) throw const HeldSaleClosedException();
        if (!isTransientError(e)) rethrow;
      }
    }
    // Offline: the same steps as the server's, made on this device — the
    // old held sale is closed and a new one holds the cart.
    final old = await getSale(saleId);
    if (old == null || old.status != SaleStatus.held) throw const HeldSaleClosedException();
    final suffix = IdGenerator.newId().substring(0, 4);
    await _writer.update('sales', {'status': 'voided', 'sale_number': '${old.saleNumber}-R$suffix'}, value: saleId);
    final created = await createSaleWithNumber(
      old: old,
      lines: lines,
      customerId: customerId,
      holdLabel: holdLabel,
    );
    return created;
  }

  Future<SaleRecord> createSaleWithNumber({
    required SaleRecord old,
    required List<SaleLineInput> lines,
    String? customerId,
    String? holdLabel,
  }) async {
    final subtotal = lines.fold<int>(0, (s, l) => s + l.unitPriceMinorUnits * l.quantity);
    final discountTotal = lines.fold<int>(0, (s, l) => s + l.discountAmountMinorUnits);
    final taxTotal = lines.fold<int>(0, (s, l) => s + l.taxAmountMinorUnits);
    final header = await _writer.insert('sales', {
      'store_id': old.storeId,
      'branch_id': old.branchId,
      'sale_number': old.saleNumber,
      'status': 'held',
      'customer_id': customerId,
      'hold_label': holdLabel,
      'subtotal_minor_units': subtotal,
      'discount_total_minor_units': discountTotal,
      'tax_total_minor_units': taxTotal,
      'grand_total_minor_units': subtotal - discountTotal + taxTotal,
      'shift_id': old.shiftId,
      'cashier_id': old.cashierId,
      'created_at': old.createdAt.toUtc().toIso8601String(),
    });
    final mapped = <SaleLineRecord>[];
    for (final l in lines) {
      mapped.add(
        _mapLine(
          await _writer.insert('sale_lines', {
            'store_id': old.storeId,
            'sale_id': header['id'],
            'product_id': l.productId,
            'quantity': l.quantity,
            'unit_price_minor_units': l.unitPriceMinorUnits,
            'discount_amount_minor_units': l.discountAmountMinorUnits,
            'tax_amount_minor_units': l.taxAmountMinorUnits,
            'line_total_minor_units': l.lineTotalMinorUnits,
            'cost_price_snapshot_minor_units': l.costPriceSnapshotMinorUnits,
          }),
        ),
      );
    }
    return _mapSale(header, mapped);
  }

  @override
  Future<SaleRecord?> findSaleByNumber(String storeId, String number) async {
    _knownStores.add(storeId);
    final wanted = normalizeSaleNumber(number);
    final idPrefix = _offlineIdPrefix(wanted);
    await Outbox.shared.load();
    try {
      var q = _client.from('sales').select().eq('store_id', storeId).neq('status', 'voided');
      // A receipt printed offline: the sale has a server number once it
      // has synced, and is found by the id it was made with.
      q = idPrefix == null
          ? q.eq('sale_number', wanted)
          : q.or('sale_number.eq.$wanted,client_sale_id.ilike.$idPrefix*');
      final row = await q.limit(1).maybeSingle().timeout(const Duration(seconds: 10));
      final shown = Outbox.shared.applyTo(
        'sales',
        [if (row != null) row],
        where: (r) => r['store_id'] == storeId && r['status'] != 'voided' && _matchesNumber(r, wanted),
      );
      return shown.isEmpty ? null : (await _withLines([shown.first])).first;
    } catch (e) {
      if (!isNetworkError(e)) rethrow;
      // Offline: the sales this device has a copy of, and the ones made here.
      final cached = Outbox.shared.applyTo(
        'sales',
        await OfflineCache.readRows(_completedKey(storeId)) ?? const [],
        where: (r) => r['store_id'] == storeId && r['status'] != 'voided',
      );
      final row = cached.where((r) => _matchesNumber(r, wanted)).firstOrNull;
      return row == null ? null : (await _withLines([row])).first;
    }
  }

  /// For a receipt number printed offline ("OFFLINE-3F2A1B"), the start of
  /// the sale's own id it was made from; null for any other number.
  static String? _offlineIdPrefix(String wanted) {
    if (!wanted.startsWith(offlineSaleNumberPrefix)) return null;
    final rest = wanted.substring(offlineSaleNumberPrefix.length).toLowerCase();
    return RegExp(r'^[0-9a-f]{4,}$').hasMatch(rest) ? rest : null;
  }

  /// Whether sales row [r] is the invoice numbered [wanted] (normalised).
  static bool _matchesNumber(Map<String, dynamic> r, String wanted) {
    if (r['sale_number'] == wanted) return true;
    final prefix = _offlineIdPrefix(wanted);
    if (prefix == null) return false;
    final id = (r['client_sale_id'] ?? r['id']) as String?;
    return id != null && id.toLowerCase().startsWith(prefix);
  }

  @override
  Stream<List<SaleRecord>> watchHeldSales(String storeId, String branchId) {
    // .stream() allows one server-side filter; status='held' cuts the
    // payload the most (held sales are always a small fraction of all
    // sales), branch_id is applied client-side below.
    _knownStores.add(storeId);
    return resilientRows(
      _heldKey(storeId),
      () => _client.from('sales').stream(primaryKey: ['id']).eq('status', 'held').order('created_at', ascending: false),
      table: 'sales',
      where: (r) => r['status'] == 'held',
    ).asyncMap((rows) async {
      final filtered = rows.where((r) => r['branch_id'] == branchId).toList();
      return _withLines(filtered);
    });
  }

  @override
  Future<List<InvoiceRecord>> listInvoices(InvoiceQuery query) async {
    if (query.customerIds != null && query.customerIds!.isEmpty) return const [];
    _knownStores.add(query.storeId);
    await Outbox.shared.load();
    final status = query.status;
    final debtStatus = switch (status) {
      InvoiceStatus.unpaid => 'open',
      InvoiceStatus.partiallyPaid => 'partiallyPaid',
      InvoiceStatus.paid => 'paid',
      _ => null,
    };
    // A debt-status filter needs an inner join so only matching invoices
    // come back (and the page stays a full page).
    final debtJoin = debtStatus == null ? 'debt_ledger_entries' : 'debt_ledger_entries!inner';
    var q = _client.from('sales').select('*, sale_lines(*), $debtJoin(*)').eq('store_id', query.storeId);

    switch (status) {
      case null:
        q = q.inFilter('status', soldStatuses);
      case InvoiceStatus.completed:
        q = q.eq('status', 'completed').neq('payment_method', 'payLater');
      case InvoiceStatus.partiallyRefunded:
        q = q.eq('status', 'partiallyRefunded');
      case InvoiceStatus.refunded:
        q = q.eq('status', 'refunded');
      case InvoiceStatus.cancelled:
        q = q.eq('status', 'voided').not('payment_method', 'is', null);
      case InvoiceStatus.unpaid || InvoiceStatus.partiallyPaid || InvoiceStatus.paid:
        q = q
            .eq('payment_method', 'payLater')
            .inFilter('status', soldStatuses)
            .eq('debt_ledger_entries.status', debtStatus!);
    }
    if (query.branchId != null) q = q.eq('branch_id', query.branchId!);
    if (query.cashierId != null) q = q.eq('cashier_id', query.cashierId!);
    if (query.paymentMethod != null) q = q.eq('payment_method', query.paymentMethod!.name);
    if (query.from != null) q = q.gte('completed_at', query.from!.toUtc().toIso8601String());
    if (query.to != null) q = q.lte('completed_at', query.to!.toUtc().toIso8601String());
    final exact = query.exactNumber;
    final idPrefix = exact == null ? null : _offlineIdPrefix(exact);
    if (idPrefix != null) {
      q = q.or('sale_number.eq.$exact,client_sale_id.ilike.$idPrefix*');
    } else if (exact != null) {
      q = q.eq('sale_number', exact);
    } else if ((query.number?.trim() ?? '').isNotEmpty) {
      q = q.ilike('sale_number', '%${query.number!.trim()}%');
    }
    if (query.customerIds != null) q = q.inFilter('customer_id', query.customerIds!.toList());

    final (column, ascending) = switch (query.sort) {
      InvoiceSort.newest => ('completed_at', false),
      InvoiceSort.oldest => ('completed_at', true),
      InvoiceSort.numberDesc => ('sale_number', false),
      InvoiceSort.numberAsc => ('sale_number', true),
      InvoiceSort.amountDesc => ('grand_total_minor_units', false),
      InvoiceSort.amountAsc => ('grand_total_minor_units', true),
    };
    final List<dynamic> rows;
    try {
      rows = await q
          .order(column, ascending: ascending)
          .order('id')
          .range(query.offset, query.offset + query.limit - 1)
          .timeout(const Duration(seconds: 12));
    } catch (e) {
      if (!isNetworkError(e)) rethrow;
      return _offlineInvoices(query);
    }

    return rows.cast<Map<String, dynamic>>().map((serverRow) {
      final id = serverRow['id'];
      // Changes made on this device and not sent yet (a return, say).
      final row = Outbox.shared.applyTo('sales', [serverRow], where: (r) => r['id'] == id).firstOrNull ?? serverRow;
      final lines = Outbox.shared
          .applyTo(
            'sale_lines',
            ((serverRow['sale_lines'] as List?) ?? const []).cast<Map<String, dynamic>>(),
            where: (l) => l['sale_id'] == id,
          )
          .map(_mapLine)
          .toList();
      final debts = Outbox.shared.applyTo(
        'debt_ledger_entries',
        ((serverRow['debt_ledger_entries'] as List?) ?? const []).cast<Map<String, dynamic>>(),
        where: (d) => d['sale_id'] == id,
      );
      return InvoiceRecord(sale: _mapSale(row, lines), debt: debts.isEmpty ? null : _mapDebt(debts.first));
    }).toList();
  }

  DebtLedgerEntryRecord _mapDebt(Map<String, dynamic> row) => DebtLedgerEntryRecord(
        id: row['id'] as String,
        storeId: row['store_id'] as String,
        branchId: row['branch_id'] as String,
        customerId: row['customer_id'] as String,
        saleId: row['sale_id'] as String?,
        journalEntryId: row['journal_entry_id'] as String?,
        originalAmountMinorUnits: (row['original_amount_minor_units'] as num).toInt(),
        amountPaidMinorUnits: (row['amount_paid_minor_units'] as num?)?.toInt() ?? 0,
        receiptRef: row['receipt_ref'] as String?,
        status: DebtStatus.values.firstWhere((s) => s.name == row['status']),
        createdAt: DateTime.parse(row['created_at'] as String).toLocal(),
      );

  @override
  Future<Map<String, int>> salesTotalsByCustomer(String storeId) async {
    final key = 'sales_totals_by_customer.$storeId';
    try {
      final totals = await _salesTotalsByCustomer(storeId).timeout(const Duration(seconds: 20));
      await OfflineCache.write(key, totals);
      return totals;
    } catch (e) {
      if (!isNetworkError(e)) rethrow;
      final cached = await OfflineCache.read(key);
      return cached is Map ? cached.map((k, v) => MapEntry(k as String, (v as num).toInt())) : const {};
    }
  }

  Future<Map<String, int>> _salesTotalsByCustomer(String storeId) async {
    final totals = <String, int>{};
    const pageSize = 1000;
    for (var from = 0;; from += pageSize) {
      final page = await _client
          .from('sales')
          .select(
            'customer_id, grand_total_minor_units, sale_lines(quantity, line_total_minor_units, quantity_returned)',
          )
          .eq('store_id', storeId)
          .inFilter('status', soldStatuses)
          .not('customer_id', 'is', null)
          .order('id')
          .range(from, from + pageSize - 1);
      for (final r in (page as List).cast<Map<String, dynamic>>()) {
        final id = r['customer_id'] as String;
        var refunded = 0;
        for (final l in ((r['sale_lines'] as List?) ?? const []).cast<Map<String, dynamic>>()) {
          final qty = (l['quantity'] as num).toInt();
          if (qty == 0) continue;
          refunded +=
              ((l['line_total_minor_units'] as num).toInt() ~/ qty) * ((l['quantity_returned'] as num?)?.toInt() ?? 0);
        }
        totals[id] = (totals[id] ?? 0) + (r['grand_total_minor_units'] as num).toInt() - refunded;
      }
      if (page.length < pageSize) break;
    }
    return totals;
  }

  @override
  Stream<List<SaleRecord>> watchCompletedSales(String storeId, {DateTime? from, DateTime? to}) {
    return resilientRows(
      _completedKey(storeId),
      () => _client
          .from('sales')
          .stream(primaryKey: ['id'])
          .inFilter('status', soldStatuses)
          .order('completed_at', ascending: false),
      table: 'sales',
      where: (r) => soldStatuses.contains(r['status']),
      cacheTake: 2000,
    ).asyncMap((rows) async {
      _knownStores.add(storeId);
      var filtered = from == null ? rows : [...rows, ...await _olderSold(storeId, rows, from)];
      if (from != null) {
        filtered = filtered
            .where((r) =>
                r['completed_at'] != null && !DateTime.parse(r['completed_at'] as String).toLocal().isBefore(from))
            .toList();
      }
      if (to != null) {
        filtered = filtered
            .where(
                (r) => r['completed_at'] != null && !DateTime.parse(r['completed_at'] as String).toLocal().isAfter(to))
            .toList();
      }
      return _withLines(filtered);
    });
  }

  /// The live list holds the newest sales only (the server sends at most
  /// 1,000 rows at a time). For a period reaching further back — a busy
  /// store's month — the older sales in it are fetched page by page,
  /// re-used for a few minutes, and kept for offline use.
  Future<List<Map<String, dynamic>>> _olderSold(String storeId, List<Map<String, dynamic>> rows, DateTime from) async {
    if (rows.length < 1000) return const [];
    DateTime? oldest;
    for (final r in rows) {
      final at = r['completed_at'] == null ? null : DateTime.tryParse(r['completed_at'] as String);
      if (at != null && (oldest == null || at.isBefore(oldest))) oldest = at;
    }
    if (oldest == null || !oldest.isAfter(from)) return const [];
    final key = 'sales.older.$storeId.${from.toUtc().toIso8601String()}';
    final cached = _olderMemory[key];
    final List<Map<String, dynamic>> older;
    if (cached != null && DateTime.now().difference(cached.$1) < const Duration(minutes: 5)) {
      older = cached.$2;
    } else {
      try {
        final fetched = <Map<String, dynamic>>[];
        const pageSize = 1000;
        for (var start = 0;; start += pageSize) {
          final page = (await _client
                  .from('sales')
                  .select()
                  .eq('store_id', storeId)
                  .inFilter('status', soldStatuses)
                  .gte('completed_at', from.toUtc().toIso8601String())
                  .lt('completed_at', oldest.toUtc().toIso8601String())
                  .order('completed_at', ascending: false)
                  .range(start, start + pageSize - 1)
                  .timeout(const Duration(seconds: 20)))
              .cast<Map<String, dynamic>>();
          fetched.addAll(page);
          if (page.length < pageSize) break;
        }
        older = fetched;
        _olderMemory[key] = (DateTime.now(), older);
        await OfflineCache.write(key, older);
      } catch (e) {
        if (!isNetworkError(e) && e is! TimeoutException) rethrow;
        return await OfflineCache.readRows(key) ?? const [];
      }
    }
    final seen = {for (final r in rows) r['id']};
    return older.where((r) => !seen.contains(r['id'])).toList();
  }

  static final _olderMemory = <String, (DateTime, List<Map<String, dynamic>>)>{};

  static String _completedKey(String storeId) => 'sales.completed.$storeId';
  static String _heldKey(String storeId) => 'sales.held.$storeId';

  /// Lines of the sales already seen, by sale id, kept for offline use.
  static Map<String, List<Map<String, dynamic>>>? _linesIndex;
  static const _linesIndexKey = 'sale_lines.index';

  Future<Map<String, List<Map<String, dynamic>>>> _loadLinesIndex() async {
    if (_linesIndex != null) return _linesIndex!;
    final raw = await OfflineCache.read(_linesIndexKey);
    _linesIndex = raw is Map
        ? raw.map((k, v) => MapEntry(k as String, (v as List).cast<Map<String, dynamic>>()))
        : <String, List<Map<String, dynamic>>>{};
    return _linesIndex!;
  }

  Future<List<SaleRecord>> _withLines(List<Map<String, dynamic>> rows) async {
    if (rows.isEmpty) return const [];
    final linesBySale = <String, List<Map<String, dynamic>>>{};
    // A sale made on this device carries its lines.
    for (final r in rows) {
      final own = r['_lines'];
      if (own is List) linesBySale[r['id'] as String] = own.cast<Map<String, dynamic>>();
    }
    final ids = rows.map((r) => r['id'] as String).where((id) => !linesBySale.containsKey(id)).toList();
    final index = await _loadLinesIndex();
    if (ids.isNotEmpty) {
      try {
        final lineRows = <Map<String, dynamic>>[];
        // In chunks: a long list of ids makes the request too long.
        for (var i = 0; i < ids.length; i += 150) {
          final chunk = ids.sublist(i, i + 150 > ids.length ? ids.length : i + 150);
          lineRows.addAll(
            (await _client.from('sale_lines').select().inFilter('sale_id', chunk).timeout(const Duration(seconds: 12)))
                .cast<Map<String, dynamic>>(),
          );
        }
        final fetched = <String, List<Map<String, dynamic>>>{for (final id in ids) id: []};
        for (final lr in lineRows) {
          fetched[lr['sale_id'] as String]!.add(lr);
        }
        index.addAll(fetched);
        // Keep the newest few thousand (oldest entries were added first).
        if (index.length > 3000) {
          final drop = index.keys.where((k) => !fetched.containsKey(k)).take(index.length - 2500).toList();
          drop.forEach(index.remove);
        }
        await OfflineCache.write(_linesIndexKey, index);
      } catch (e) {
        if (!isNetworkError(e)) rethrow;
      }
      for (final id in ids) {
        linesBySale[id] = Outbox.shared.applyTo('sale_lines', index[id] ?? const [], where: (l) => l['sale_id'] == id);
      }
    }
    return rows.map((row) => _mapSale(row, (linesBySale[row['id']] ?? const []).map(_mapLine).toList())).toList();
  }

  /// The invoices list from the copy on this device (no connection):
  /// completed sales, filtered and sorted as asked.
  Future<List<InvoiceRecord>> _offlineInvoices(InvoiceQuery query) async {
    final cached = Outbox.shared.applyTo(
      'sales',
      await OfflineCache.readRows(_completedKey(query.storeId)) ?? const [],
      where: (r) => soldStatuses.contains(r['status']),
    );
    final number = query.exactNumber ?? query.number?.trim();
    DateTime? at(Map<String, dynamic> r) =>
        r['completed_at'] == null ? null : DateTime.parse(r['completed_at'] as String).toLocal();
    final rows = cached.where((r) {
      final status = query.status;
      if (status == InvoiceStatus.partiallyRefunded && r['status'] != 'partiallyRefunded') return false;
      if (status == InvoiceStatus.refunded && r['status'] != 'refunded') return false;
      if (status == InvoiceStatus.cancelled) return false;
      if (status == InvoiceStatus.completed && (r['status'] != 'completed' || r['payment_method'] == 'payLater')) {
        return false;
      }
      if ((status == InvoiceStatus.unpaid || status == InvoiceStatus.partiallyPaid || status == InvoiceStatus.paid) &&
          r['payment_method'] != 'payLater') {
        return false;
      }
      if (query.branchId != null && r['branch_id'] != query.branchId) return false;
      if (query.cashierId != null && r['cashier_id'] != query.cashierId) return false;
      if (query.paymentMethod != null && r['payment_method'] != query.paymentMethod!.name) return false;
      final when = at(r);
      if (query.from != null && (when == null || when.isBefore(query.from!))) return false;
      if (query.to != null && (when == null || when.isAfter(query.to!))) return false;
      if (number != null && number.isNotEmpty) {
        final n = r['sale_number'] as String? ?? '';
        if (query.exactNumber != null ? !_matchesNumber(r, number) : !n.contains(number)) return false;
      }
      if (query.customerIds != null && !query.customerIds!.contains(r['customer_id'])) return false;
      return true;
    }).toList();
    int byInt(Map<String, dynamic> r) => (r['grand_total_minor_units'] as num?)?.toInt() ?? 0;
    rows.sort((a, b) => switch (query.sort) {
          InvoiceSort.newest => (at(b) ?? DateTime(0)).compareTo(at(a) ?? DateTime(0)),
          InvoiceSort.oldest => (at(a) ?? DateTime(0)).compareTo(at(b) ?? DateTime(0)),
          InvoiceSort.numberDesc => (b['sale_number'] as String).compareTo(a['sale_number'] as String),
          InvoiceSort.numberAsc => (a['sale_number'] as String).compareTo(b['sale_number'] as String),
          InvoiceSort.amountDesc => byInt(b).compareTo(byInt(a)),
          InvoiceSort.amountAsc => byInt(a).compareTo(byInt(b)),
        });
    final page = rows.skip(query.offset).take(query.limit).toList();
    final sales = await _withLines(page);

    // What pay-later invoices still owe, from the copy of the open debts: a
    // debt no longer among them was paid off (unless its sale hasn't even
    // reached the server yet).
    final openRows = await OfflineCache.readRows('debts.open.${query.storeId}');
    final openBySale = {
      for (final d in Outbox.shared.applyTo('debt_ledger_entries', openRows ?? const []))
        if (d['sale_id'] != null && d['status'] != 'paid') d['sale_id'] as String: d,
    };
    final unsent = {
      for (final o in Outbox.shared.pending)
        if (o.kind == OutboxKind.checkout) o.id,
    };
    return [
      for (final sale in sales)
        if (sale.paymentMethod != SalePaymentMethod.payLater)
          InvoiceRecord(sale: sale)
        else if (openBySale[sale.id] case final debt?)
          InvoiceRecord(sale: sale, debt: _mapDebt(debt))
        else
          InvoiceRecord(sale: sale, debtSettled: openRows != null && !unsent.contains(sale.id)),
    ];
  }

  @override
  Future<void> voidSale(String saleId) async {
    await _writer.update('sales', {'status': 'voided'}, value: saleId);
  }

  @override
  Future<String> createSaleReturn({
    required String storeId,
    required String branchId,
    required String originalSaleId,
    required String refundMethod,
    required String processedByUserId,
    required List<MapEntry<String, int>> saleLineIdToQuantity,
  }) async {
    final header = await _client
        .from('sale_returns')
        .insert({
          'store_id': storeId,
          'branch_id': branchId,
          'original_sale_id': originalSaleId,
          'refund_method': refundMethod,
          'processed_by_user_id': processedByUserId,
        })
        .select('id')
        .single();
    final returnId = header['id'] as String;

    for (final entry in saleLineIdToQuantity) {
      final line = await _client.from('sale_lines').select().eq('id', entry.key).single();
      final quantity = (line['quantity'] as num).toInt();
      final lineTotal = (line['line_total_minor_units'] as num).toInt();
      final unitRefund = quantity == 0 ? 0 : (lineTotal ~/ quantity) * entry.value;
      await _client.from('sale_return_lines').insert({
        'store_id': storeId,
        'sale_return_id': returnId,
        'sale_line_id': entry.key,
        'quantity_returned': entry.value,
        'refund_amount_minor_units': unitRefund,
      });
    }
    return returnId;
  }
}
