import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../inventory/domain/inventory_models.dart';
import '../domain/pos_models.dart';

class CartLine {
  const CartLine({
    required this.product,
    required this.quantity,
    this.discountAmountMinorUnits = 0,
    this.taxRatePercent = 0,
    this.wholesale = false,
  });

  final ProductRecord product;
  final int quantity;
  final int discountAmountMinorUnits;
  final double taxRatePercent;

  /// Priced at the product's wholesale price (when it has one).
  final bool wholesale;

  int get unitPriceMinorUnits => unitPriceFor(product, wholesale: wholesale);

  static int unitPriceFor(ProductRecord product, {required bool wholesale}) =>
      wholesale ? (product.wholesalePriceMinorUnits ?? product.sellPriceMinorUnits) : product.sellPriceMinorUnits;
  int get grossMinorUnits => unitPriceMinorUnits * quantity;
  int get taxMinorUnits => ((grossMinorUnits - discountAmountMinorUnits) * taxRatePercent / 100).round();
  int get lineTotalMinorUnits => grossMinorUnits - discountAmountMinorUnits + taxMinorUnits;

  CartLine copyWith({int? quantity, int? discountAmountMinorUnits, bool? wholesale}) => CartLine(
        product: product,
        quantity: quantity ?? this.quantity,
        discountAmountMinorUnits: discountAmountMinorUnits ?? this.discountAmountMinorUnits,
        taxRatePercent: taxRatePercent,
        wholesale: wholesale ?? this.wholesale,
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

class CartState {
  const CartState({this.lines = const [], this.holdLabel, this.resumingHeldSale, this.wholesale = false});

  final List<CartLine> lines;
  final String? holdLabel;
  final SaleRecord? resumingHeldSale;

  /// Wholesale pricing for this sale.
  final bool wholesale;

  int get subtotalMinorUnits => lines.fold(0, (s, l) => s + l.grossMinorUnits);
  int get discountTotalMinorUnits => lines.fold(0, (s, l) => s + l.discountAmountMinorUnits);
  int get taxTotalMinorUnits => lines.fold(0, (s, l) => s + l.taxMinorUnits);
  int get grandTotalMinorUnits => lines.fold(0, (s, l) => s + l.lineTotalMinorUnits);
  bool get isEmpty => lines.isEmpty;

  CartState copyWith({
    List<CartLine>? lines,
    String? holdLabel,
    SaleRecord? resumingHeldSale,
    bool clearHeld = false,
    bool? wholesale,
  }) {
    return CartState(
      lines: lines ?? this.lines,
      holdLabel: holdLabel ?? this.holdLabel,
      resumingHeldSale: clearHeld ? null : (resumingHeldSale ?? this.resumingHeldSale),
      wholesale: wholesale ?? this.wholesale,
    );
  }
}

class CartController extends Notifier<CartState> {
  @override
  CartState build() => const CartState();

  void addProduct(ProductRecord product, {double taxRatePercent = 0}) {
    final index = state.lines.indexWhere((l) => l.product.id == product.id);
    if (index >= 0) {
      final updated = [...state.lines];
      updated[index] = updated[index].copyWith(quantity: updated[index].quantity + 1);
      state = state.copyWith(lines: updated);
    } else {
      state = state.copyWith(lines: [
        ...state.lines,
        CartLine(product: product, quantity: 1, taxRatePercent: taxRatePercent, wholesale: state.wholesale),
      ]);
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
            discountAmountMinorUnits: l.discountAmountMinorUnits
                .clamp(0, CartLine.unitPriceFor(l.product, wholesale: wholesale) * l.quantity),
          ),
      ],
    );
  }

  void setQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeProduct(productId);
      return;
    }
    final updated = state.lines
        .map((l) => l.product.id == productId ? l.copyWith(quantity: quantity) : l)
        .toList();
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

  void loadHeldSale(SaleRecord sale, List<ProductRecord> products) {
    final byId = {for (final p in products) p.id: p};
    final lines = sale.lines
        .where((l) => byId.containsKey(l.productId))
        .map((l) => CartLine(product: byId[l.productId]!, quantity: l.quantity, discountAmountMinorUnits: l.discountAmountMinorUnits))
        .toList();
    state = CartState(lines: lines, resumingHeldSale: sale);
  }

  void clear() {
    state = const CartState();
  }
}

final cartControllerProvider = NotifierProvider<CartController, CartState>(CartController.new);
