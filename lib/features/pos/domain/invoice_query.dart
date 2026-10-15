import '../../debts/domain/debts_models.dart';
import 'pos_models.dart';
import 'pos_repository.dart';

/// Invoice status as the invoices screen filters it: the sale's own status,
/// or — for pay-later invoices — how much of the debt has been paid.
enum InvoiceStatus { completed, partiallyRefunded, refunded, cancelled, unpaid, partiallyPaid, paid }

enum InvoiceSort { newest, oldest, numberDesc, numberAsc, amountDesc, amountAsc }

/// One page of the invoice list, filtered on the server (or local
/// database), never by loading the whole history.
class InvoiceQuery {
  const InvoiceQuery({
    required this.storeId,
    this.branchId,
    this.cashierId,
    this.paymentMethod,
    this.status,
    this.from,
    this.to,
    this.number,
    this.customerIds,
    this.sort = InvoiceSort.newest,
    this.offset = 0,
    this.limit = 50,
  });

  final String storeId;
  final String? branchId;
  final String? cashierId;
  final SalePaymentMethod? paymentMethod;
  final InvoiceStatus? status;

  /// Inclusive bounds on when the invoice was completed.
  final DateTime? from;
  final DateTime? to;

  /// Invoice number, full ("S-000123") or just its digits ("123").
  final String? number;

  /// Only invoices of these customers (e.g. the ones matching a name
  /// search). An empty set matches nothing; null means any customer.
  final Set<String>? customerIds;

  final InvoiceSort sort;
  final int offset;
  final int limit;

  InvoiceQuery page(int offset) => InvoiceQuery(
        storeId: storeId,
        branchId: branchId,
        cashierId: cashierId,
        paymentMethod: paymentMethod,
        status: status,
        from: from,
        to: to,
        number: number,
        customerIds: customerIds,
        sort: sort,
        offset: offset,
        limit: limit,
      );

  /// The sale number to look up exactly, when [number] is one (see
  /// [looksLikeSaleNumber]).
  String? get exactNumber {
    final n = number?.trim() ?? '';
    if (n.isEmpty || !looksLikeSaleNumber(n)) return null;
    return normalizeSaleNumber(n);
  }
}

/// An invoice with what was paid on it. Cash and card invoices are paid in
/// full at the till; a pay-later invoice is paid through its debt entry.
class InvoiceRecord {
  const InvoiceRecord({required this.sale, this.debt, this.debtSettled = false});

  final SaleRecord sale;
  final DebtLedgerEntryRecord? debt;

  /// A pay-later invoice whose debt is known to be paid off although its
  /// record isn't at hand (offline: it is no longer among the open debts).
  final bool debtSettled;

  bool get isPayLater => sale.paymentMethod == SalePaymentMethod.payLater;

  int get totalMinorUnits => sale.netTotalMinorUnits;

  int get remainingMinorUnits {
    if (!isPayLater || debtSettled) return 0;
    final d = debt;
    // Its debt isn't known here (a sale made offline and not sent yet, or
    // no copy on this device): what wasn't paid up front is still owed.
    final left = d == null ? totalMinorUnits - (sale.amountTenderedMinorUnits ?? 0) : d.balanceRemainingMinorUnits;
    return left < 0 ? 0 : left;
  }

  int get paidMinorUnits => totalMinorUnits - remainingMinorUnits;

  InvoiceStatus get status {
    if (sale.status == SaleStatus.voided) return InvoiceStatus.cancelled;
    if (sale.status == SaleStatus.refunded) return InvoiceStatus.refunded;
    if (isPayLater) {
      final d = debt;
      final paidUp = switch (d?.status) {
        DebtStatus.open => false,
        DebtStatus.partiallyPaid => false,
        DebtStatus.paid => true,
        null => debtSettled || remainingMinorUnits == 0,
      };
      if (paidUp) {
        return sale.status == SaleStatus.partiallyRefunded ? InvoiceStatus.partiallyRefunded : InvoiceStatus.paid;
      }
      final somePaid = d == null ? (sale.amountTenderedMinorUnits ?? 0) > 0 : d.status == DebtStatus.partiallyPaid;
      return somePaid ? InvoiceStatus.partiallyPaid : InvoiceStatus.unpaid;
    }
    if (sale.status == SaleStatus.partiallyRefunded) return InvoiceStatus.partiallyRefunded;
    return InvoiceStatus.completed;
  }
}

/// Applies [query]'s filters, sort and page to invoices already in memory —
/// the local (single-device) database's implementation, and the reference
/// the server query mirrors.
List<InvoiceRecord> filterInvoices(Iterable<InvoiceRecord> all, InvoiceQuery query) {
  final exact = query.exactNumber;
  final text = query.number?.trim().toLowerCase() ?? '';
  final rows = all.where((r) {
    final s = r.sale;
    if (s.storeId != query.storeId) return false;
    // Held sales aren't invoices; a voided sale is only an invoice when it
    // was paid (a discarded held sale never was).
    if (s.status == SaleStatus.held) return false;
    if (s.status == SaleStatus.voided && s.paymentMethod == null) return false;
    if (query.branchId != null && s.branchId != query.branchId) return false;
    if (query.cashierId != null && s.cashierId != query.cashierId) return false;
    if (query.paymentMethod != null && s.paymentMethod != query.paymentMethod) return false;
    final when = s.completedAt ?? s.createdAt;
    if (query.from != null && when.isBefore(query.from!)) return false;
    if (query.to != null && when.isAfter(query.to!)) return false;
    if (exact != null && s.saleNumber != exact) return false;
    if (exact == null && text.isNotEmpty && !s.saleNumber.toLowerCase().contains(text)) return false;
    if (query.customerIds != null && !query.customerIds!.contains(s.customerId)) return false;
    if (query.status == null) return s.status != SaleStatus.voided;
    return r.status == query.status;
  }).toList();

  int byDate(InvoiceRecord a, InvoiceRecord b) =>
      (a.sale.completedAt ?? a.sale.createdAt).compareTo(b.sale.completedAt ?? b.sale.createdAt);
  int byNumber(InvoiceRecord a, InvoiceRecord b) => a.sale.saleNumber.compareTo(b.sale.saleNumber);
  int byAmount(InvoiceRecord a, InvoiceRecord b) => a.sale.grandTotalMinorUnits.compareTo(b.sale.grandTotalMinorUnits);
  rows.sort(switch (query.sort) {
    InvoiceSort.newest => (a, b) => byDate(b, a),
    InvoiceSort.oldest => byDate,
    InvoiceSort.numberDesc => (a, b) => byNumber(b, a),
    InvoiceSort.numberAsc => byNumber,
    InvoiceSort.amountDesc => (a, b) => byAmount(b, a),
    InvoiceSort.amountAsc => byAmount,
  });
  return rows.skip(query.offset).take(query.limit).toList();
}
