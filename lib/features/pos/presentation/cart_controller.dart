import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/domain/session_controller.dart';
import '../../debts/domain/debts_models.dart';
import '../../inventory/domain/inventory_models.dart';
import '../domain/pos_models.dart';

class CartLine {
  const CartLine({
    required this.product,
    required this.quantity,
    this.discountAmountMinorUnits = 0,
    this.taxRatePercent = 0,
    this.wholesale = false,
    this.heldUnitPriceMinorUnits,
  });

  final ProductRecord product;
  final int quantity;
  final int discountAmountMinorUnits;
  final double taxRatePercent;

  /// Priced at the product's wholesale price (when it has one).
  final bool wholesale;

  /// The price this line was held at, kept when a suspended sale is resumed
  /// (the product's price may have changed since). Cleared by switching
  /// between retail and wholesale.
  final int? heldUnitPriceMinorUnits;

  int get unitPriceMinorUnits => heldUnitPriceMinorUnits ?? unitPriceFor(product, wholesale: wholesale);

  static int unitPriceFor(ProductRecord product, {required bool wholesale}) =>
      wholesale ? (product.wholesalePriceMinorUnits ?? product.sellPriceMinorUnits) : product.sellPriceMinorUnits;
  int get grossMinorUnits => unitPriceMinorUnits * quantity;
  int get taxMinorUnits => ((grossMinorUnits - discountAmountMinorUnits) * taxRatePercent / 100).round();
  int get lineTotalMinorUnits => grossMinorUnits - discountAmountMinorUnits + taxMinorUnits;

  /// The lowest this line may go under a full discount when the store keeps
  /// a margin: cost + 5% (never more than the line's own price).
  int get marginFloorMinorUnits {
    final floor = (product.costPriceMinorUnits * quantity * 105 + 99) ~/ 100;
    return floor > grossMinorUnits ? grossMinorUnits : floor;
  }

  /// The discount amount for a cashier-entered percent or amount, with the
  /// optional cost + 5% floor applied to a full discount.
  int discountFor({required bool isPercent, required num value, bool keepMargin = false}) {
    final requested =
        isPercent ? (grossMinorUnits * value.clamp(0, 100) / 100).round() : value.round().clamp(0, grossMinorUnits);
    final full = isPercent ? value >= 100 : value >= grossMinorUnits;
    if (keepMargin && full) return grossMinorUnits - marginFloorMinorUnits;
    return requested;
  }

  CartLine copyWith({int? quantity, int? discountAmountMinorUnits, bool? wholesale}) => CartLine(
        product: product,
        quantity: quantity ?? this.quantity,
        discountAmountMinorUnits: discountAmountMinorUnits ?? this.discountAmountMinorUnits,
        taxRatePercent: taxRatePercent,
        wholesale: wholesale ?? this.wholesale,
        heldUnitPriceMinorUnits: wholesale == null ? heldUnitPriceMinorUnits : null,
      );

  SaleLineInput toSaleLineInput() => SaleLineInput(
        productId: product.id,
        quantity: quantity,
        unitPriceMinorUnits: unitPriceMinorUnits,
        discountAmountMinorUnits: discountAmountMinorUnits,
        taxAmountMinorUnits: taxMinorUnits,
        costPriceSnapshotMinorUnits: product.costPriceMinorUnits,
      );
}

/// A discount on the whole invoice, entered by the cashier: either a
/// percentage or a fixed amount (minor units).
class InvoiceDiscount {
  const InvoiceDiscount.percent(this.value, {this.keepMargin = false}) : isPercent = true;
  const InvoiceDiscount.amount(this.value, {this.keepMargin = false}) : isPercent = false;

  final bool isPercent;
  final num value;

  /// A full (100%) discount still charges cost + 5% (store setting).
  final bool keepMargin;

  int amountFor(int payableMinorUnits) =>
      isPercent ? (payableMinorUnits * value.clamp(0, 100) / 100).round() : value.round().clamp(0, payableMinorUnits);

  bool isFullFor(int payableMinorUnits) => isPercent ? value >= 100 : value >= payableMinorUnits;
}

class CartState {
  const CartState({
    this.lines = const [],
    this.holdLabel,
    this.resumingHeldSale,
    this.wholesale = false,
    this.invoiceDiscount,
    this.customer,
  });

  /// Lines as entered, each with its own line discount.
  final List<CartLine> lines;
  final String? holdLabel;
  final SaleRecord? resumingHeldSale;

  /// Wholesale pricing for this sale.
  final bool wholesale;
  final InvoiceDiscount? invoiceDiscount;

  /// The registered customer this sale is for (null = walk-in). Kept on the
  /// cart so holding and resuming a sale keeps its customer.
  final CustomerRecord? customer;

  /// [lines] with the invoice discount spread across them — what is
  /// actually sold, and what every total below is computed from.
  List<CartLine> get pricedLines {
    final discount = invoiceDiscount;
    if (discount == null || lines.isEmpty) return lines;
    final payable = lines.fold(0, (s, l) => s + l.grossMinorUnits - l.discountAmountMinorUnits);
    if (discount.keepMargin && discount.isFullFor(payable)) {
      return [for (final l in lines) l.copyWith(discountAmountMinorUnits: l.grossMinorUnits - l.marginFloorMinorUnits)];
    }
    return spreadDiscount(lines, discount.amountFor(payable));
  }

  /// Discount coming from the invoice discount alone.
  int get invoiceDiscountMinorUnits =>
      pricedLines.fold(0, (s, l) => s + l.discountAmountMinorUnits) -
      lines.fold(0, (s, l) => s + l.discountAmountMinorUnits);

  int get subtotalMinorUnits => pricedLines.fold(0, (s, l) => s + l.grossMinorUnits);
  int get discountTotalMinorUnits => pricedLines.fold(0, (s, l) => s + l.discountAmountMinorUnits);
  int get taxTotalMinorUnits => pricedLines.fold(0, (s, l) => s + l.taxMinorUnits);
  int get grandTotalMinorUnits => pricedLines.fold(0, (s, l) => s + l.lineTotalMinorUnits);
  bool get isEmpty => lines.isEmpty;

  CartState copyWith({
    List<CartLine>? lines,
    String? holdLabel,
    SaleRecord? resumingHeldSale,
    bool clearHeld = false,
    bool? wholesale,
    InvoiceDiscount? invoiceDiscount,
    bool clearInvoiceDiscount = false,
    CustomerRecord? customer,
    bool clearCustomer = false,
  }) {
    return CartState(
      lines: lines ?? this.lines,
      holdLabel: holdLabel ?? this.holdLabel,
      resumingHeldSale: clearHeld ? null : (resumingHeldSale ?? this.resumingHeldSale),
      wholesale: wholesale ?? this.wholesale,
      invoiceDiscount: clearInvoiceDiscount ? null : (invoiceDiscount ?? this.invoiceDiscount),
      customer: clearCustomer ? null : (customer ?? this.customer),
    );
  }
}

/// The session a cart belongs to. A cart never outlives its store, branch
/// or signed-in account: signing out, switching store or switching branch
/// starts an empty cart, so nothing from one store can show up in another.
typedef CartOwner = ({String? storeId, String? branchId, String? employeeId});

class CartController extends Notifier<CartState> {
  late CartOwner _owner;

  @override
  CartState build() {
    _owner = ref.watch(
      sessionControllerProvider.select(
        (s) => (storeId: s.store?.id, branchId: s.currentBranchId, employeeId: s.employee?.id),
      ),
    );
    return const CartState();
  }

  /// The session this cart was opened for. Async work that finishes later
  /// (e.g. loading a held sale) checks it is still the same before writing.
  CartOwner get owner => _owner;

  void addProduct(ProductRecord product, {double taxRatePercent = 0}) {
    final index = state.lines.indexWhere((l) => l.product.id == product.id);
    if (index >= 0) {
      final updated = [...state.lines];
      updated[index] = updated[index].copyWith(quantity: updated[index].quantity + 1);
      state = state.copyWith(lines: updated);
    } else {
      state = state.copyWith(
        lines: [
          ...state.lines,
          CartLine(product: product, quantity: 1, taxRatePercent: taxRatePercent, wholesale: state.wholesale),
        ],
      );
    }
  }

  /// Switches the whole sale between retail and wholesale prices,
  /// repricing lines already in the cart.
  void setWholesale(bool wholesale) {
    state = state.copyWith(
      wholesale: wholesale,
      lines: [
        for (final l in state.lines)
          // A line discount was set against the old price; keep it within
          // the new line total.
          l.copyWith(
            wholesale: wholesale,
            discountAmountMinorUnits: l.discountAmountMinorUnits.clamp(
              0,
              CartLine.unitPriceFor(l.product, wholesale: wholesale) * l.quantity,
            ),
          ),
      ],
    );
  }

  void setQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeProduct(productId);
      return;
    }
    final updated = state.lines.map((l) => l.product.id == productId ? l.copyWith(quantity: quantity) : l).toList();
    state = state.copyWith(lines: updated);
  }

  void removeProduct(String productId) {
    state = state.copyWith(lines: state.lines.where((l) => l.product.id != productId).toList());
  }

  void setLineDiscount(String productId, int discountAmountMinorUnits) {
    final updated = state.lines.map((l) {
      if (l.product.id != productId) return l;
      final clamped = discountAmountMinorUnits.clamp(0, l.grossMinorUnits);
      return l.copyWith(discountAmountMinorUnits: clamped);
    }).toList();
    state = state.copyWith(lines: updated);
  }

  /// Loads a held sale back into the cart exactly as it was held: same
  /// items, quantities, prices, discounts, tax and customer. Lines whose
  /// product was since removed from the catalog are still restored from
  /// [products] when the caller found them. Ignored if the sale belongs to
  /// another store/branch than this cart.
  void loadHeldSale(
    SaleRecord sale,
    List<ProductRecord> products, {
    Map<String, double> taxPercentById = const {},
    CustomerRecord? customer,
  }) {
    if (sale.storeId != _owner.storeId || sale.branchId != _owner.branchId) return;
    final lines = heldSaleToCartLines(sale, products, taxPercentById: taxPercentById);
    state = CartState(
      lines: lines,
      wholesale: lines.isNotEmpty && lines.every((l) => l.wholesale),
      resumingHeldSale: sale,
      customer: customer != null && customer.id == sale.customerId ? customer : null,
    );
  }

  void setCustomer(CustomerRecord? customer) {
    state = customer == null ? state.copyWith(clearCustomer: true) : state.copyWith(customer: customer);
  }

  void setInvoiceDiscount(InvoiceDiscount? discount) {
    state = discount == null || discount.value <= 0
        ? state.copyWith(clearInvoiceDiscount: true)
        : state.copyWith(invoiceDiscount: discount);
  }

  void clear() {
    state = const CartState();
  }
}

final cartControllerProvider = NotifierProvider<CartController, CartState>(CartController.new);

/// [lines] with [discountMinorUnits] spread over them in proportion to each
/// line's price after its own discount, so tax and revenue are recomputed
/// exactly as for any other discount. Rounding leftovers go to the largest
/// line; the total is capped at what the lines are worth.
List<CartLine> spreadDiscount(List<CartLine> lines, int discountMinorUnits) {
  if (discountMinorUnits <= 0 || lines.isEmpty) return lines;
  final bases = <int>[for (final l in lines) l.grossMinorUnits - l.discountAmountMinorUnits];
  final total = bases.fold<int>(0, (a, b) => a + b);
  if (total <= 0) return lines;
  final amount = discountMinorUnits > total ? total : discountMinorUnits;

  final shares = <int>[for (final b in bases) amount * b ~/ total];
  final leftover = amount - shares.fold<int>(0, (a, b) => a + b);
  var largest = 0;
  for (var i = 1; i < bases.length; i++) {
    if (bases[i] > bases[largest]) largest = i;
  }
  shares[largest] += leftover;

  return [
    for (var i = 0; i < lines.length; i++)
      lines[i].copyWith(discountAmountMinorUnits: lines[i].discountAmountMinorUnits + shares[i]),
  ];
}

/// The cart lines a held sale was saved from. A line is wholesale when it
/// was held at the product's wholesale price; its tax rate is the product's.
List<CartLine> heldSaleToCartLines(
  SaleRecord sale,
  List<ProductRecord> products, {
  Map<String, double> taxPercentById = const {},
}) {
  final byId = {for (final p in products) p.id: p};
  return [
    for (final l in sale.lines)
      if (byId[l.productId] case final product?)
        CartLine(
          product: product,
          quantity: l.quantity,
          discountAmountMinorUnits: l.discountAmountMinorUnits,
          taxRatePercent: product.taxRateId == null ? 0 : (taxPercentById[product.taxRateId] ?? 0),
          wholesale: product.wholesalePriceMinorUnits != null &&
              product.wholesalePriceMinorUnits != product.sellPriceMinorUnits &&
              l.unitPriceMinorUnits == product.wholesalePriceMinorUnits,
          heldUnitPriceMinorUnits: l.unitPriceMinorUnits,
        ),
  ];
}
