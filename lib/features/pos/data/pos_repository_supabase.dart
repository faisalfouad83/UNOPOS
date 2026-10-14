import 'package:supabase_flutter/supabase_flutter.dart';

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
  SupabasePosRepository(this._client);

  final SupabaseClient _client;

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
    final saleNumber = await _client.rpc('next_sale_number') as String;

    final subtotal = lines.fold<int>(0, (s, l) => s + l.unitPriceMinorUnits * l.quantity);
    final discountTotal = lines.fold<int>(0, (s, l) => s + l.discountAmountMinorUnits);
    final taxTotal = lines.fold<int>(0, (s, l) => s + l.taxAmountMinorUnits);
    final grandTotal = subtotal - discountTotal + taxTotal;

    final header = await _client
        .from('sales')
        .insert({
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
        })
        .select()
        .single();
    final saleId = header['id'] as String;

    List<SaleLineRecord> mappedLines = const [];
    if (lines.isNotEmpty) {
      final inserted = await _client
          .from('sale_lines')
          .insert(
            lines
                .map(
                  (l) => {
                    'store_id': storeId,
                    'sale_id': saleId,
                    'product_id': l.productId,
                    'quantity': l.quantity,
                    'unit_price_minor_units': l.unitPriceMinorUnits,
                    'discount_amount_minor_units': l.discountAmountMinorUnits,
                    'tax_amount_minor_units': l.taxAmountMinorUnits,
                    'line_total_minor_units': l.lineTotalMinorUnits,
                    'cost_price_snapshot_minor_units': l.costPriceSnapshotMinorUnits,
                  },
                )
                .toList(),
          )
          .select();
      mappedLines = (inserted as List).cast<Map<String, dynamic>>().map(_mapLine).toList();
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
    await _client.from('sales').update({
      'status': 'completed',
      'payment_method': paymentMethod.name,
      'amount_tendered_minor_units': amountTenderedMinorUnits,
      'change_given_minor_units': changeGivenMinorUnits,
      'journal_entry_id': journalEntryId,
      'completed_at': DateTime.now().toIso8601String(),
    }).eq('id', saleId);
  }

  @override
  Future<SaleRecord?> getSale(String saleId) async {
    final row = await _client.from('sales').select().eq('id', saleId).maybeSingle();
    if (row == null) return null;
    final lineRows = await _client.from('sale_lines').select().eq('sale_id', saleId);
    final lines = (lineRows as List).cast<Map<String, dynamic>>().map(_mapLine).toList();
    return _mapSale(row, lines);
  }

  @override
  Future<SaleRecord> reholdSale({
    required String saleId,
    required List<SaleLineInput> lines,
    String? customerId,
    String? holdLabel,
  }) async {
    final result = await _client.rpc(
      'rehold_sale',
      params: {
        'p_sale_id': saleId,
        'p_lines': lines.map(saleLineJson).toList(),
        'p_customer_id': customerId,
        'p_hold_label': holdLabel,
      },
    ) as Map<String, dynamic>;
    return (await getSale(result['sale_id'] as String))!;
  }

  @override
  Future<SaleRecord?> findSaleByNumber(String storeId, String number) async {
    final row = await _client
        .from('sales')
        .select()
        .eq('store_id', storeId)
        .eq('sale_number', normalizeSaleNumber(number))
        .neq('status', 'voided')
        .limit(1)
        .maybeSingle();
    if (row == null) return null;
    return (await _withLines([row])).first;
  }

  @override
  Stream<List<SaleRecord>> watchHeldSales(String storeId, String branchId) {
    // .stream() allows one server-side filter; status='held' cuts the
    // payload the most (held sales are always a small fraction of all
    // sales), branch_id is applied client-side below.
    return _client
        .from('sales')
        .stream(primaryKey: ['id'])
        .eq('status', 'held')
        .order('created_at', ascending: false)
        .asyncMap((rows) async {
          final filtered = rows.where((r) => r['branch_id'] == branchId).toList();
          return _withLines(filtered);
        });
  }

  @override
  Future<List<InvoiceRecord>> listInvoices(InvoiceQuery query) async {
    if (query.customerIds != null && query.customerIds!.isEmpty) return const [];
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
    if (exact != null) {
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
    final rows =
        await q.order(column, ascending: ascending).order('id').range(query.offset, query.offset + query.limit - 1);

    return (rows as List).cast<Map<String, dynamic>>().map((row) {
      final lines = ((row['sale_lines'] as List?) ?? const []).cast<Map<String, dynamic>>().map(_mapLine).toList();
      final debts = ((row['debt_ledger_entries'] as List?) ?? const []).cast<Map<String, dynamic>>();
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
    return _client
        .from('sales')
        .stream(primaryKey: ['id'])
        .inFilter('status', soldStatuses)
        .order('completed_at', ascending: false)
        .asyncMap((rows) async {
          var filtered = rows;
          if (from != null) {
            filtered = filtered
                .where((r) => r['completed_at'] != null && !DateTime.parse(r['completed_at'] as String).toLocal().isBefore(from))
                .toList();
          }
          if (to != null) {
            filtered = filtered
                .where((r) => r['completed_at'] != null && !DateTime.parse(r['completed_at'] as String).toLocal().isAfter(to))
                .toList();
          }
          return _withLines(filtered);
        });
  }

  Future<List<SaleRecord>> _withLines(List<Map<String, dynamic>> rows) async {
    if (rows.isEmpty) return const [];
    final ids = rows.map((r) => r['id'] as String).toList();
    final lineRows = await _client.from('sale_lines').select().inFilter('sale_id', ids);
    final linesBySale = <String, List<SaleLineRecord>>{};
    for (final lr in (lineRows as List).cast<Map<String, dynamic>>()) {
      final sid = lr['sale_id'] as String;
      (linesBySale[sid] ??= []).add(_mapLine(lr));
    }
    return rows.map((row) => _mapSale(row, linesBySale[row['id']] ?? const [])).toList();
  }

  @override
  Future<void> voidSale(String saleId) async {
    await _client.from('sales').update({'status': 'voided'}).eq('id', saleId);
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
