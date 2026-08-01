import '../../pos/domain/pos_models.dart';
import 'receipt_models.dart';

class ReceiptTemplateBuilder {
  const ReceiptTemplateBuilder._();

  static ReceiptDocument build({
    required SaleRecord sale,
    required Map<String, String> productNamesById,
    required String storeName,
    required String branchName,
    String branchPhone = '',
    String branchAddress = '',
    required String cashierName,
    String? customerName,
    required String currencySymbol,
    String footerText = 'Thank you for shopping with us!',
  }) {
    return ReceiptDocument(
      storeName: storeName,
      branchName: branchName,
      branchPhone: branchPhone,
      branchAddress: branchAddress,
      saleNumber: sale.saleNumber,
      dateTime: sale.completedAt ?? sale.createdAt,
      cashierName: cashierName,
      customerName: customerName,
      lines: sale.lines
          .map((l) => ReceiptLine(
                name: productNamesById[l.productId] ?? l.productId,
                quantity: l.quantity,
                unitPriceMinorUnits: l.unitPriceMinorUnits,
                lineTotalMinorUnits: l.lineTotalMinorUnits,
              ))
          .toList(),
      subtotalMinorUnits: sale.subtotalMinorUnits,
      discountTotalMinorUnits: sale.discountTotalMinorUnits,
      taxTotalMinorUnits: sale.taxTotalMinorUnits,
      grandTotalMinorUnits: sale.grandTotalMinorUnits,
      paymentMethodLabel: switch (sale.paymentMethod) {
        SalePaymentMethod.cash => 'Cash',
        SalePaymentMethod.card => 'Card',
        SalePaymentMethod.payLater => 'Pay Later',
        null => '-',
      },
      amountTenderedMinorUnits: sale.amountTenderedMinorUnits,
      changeGivenMinorUnits: sale.changeGivenMinorUnits,
      isPayLater: sale.paymentMethod == SalePaymentMethod.payLater,
      currencySymbol: currencySymbol,
      footerText: footerText,
    );
  }
}
