import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../auth/domain/session_controller.dart';
import '../../inventory/domain/inventory_repository.dart';
import '../../pos/domain/pos_models.dart';
import '../../settings/domain/settings_models.dart';
import '../domain/receipt_models.dart';
import '../domain/receipt_template_builder.dart';

ReceiptLabels receiptLabelsFor(AppLocalizations l10n) => ReceiptLabels(
      sale: l10n.receiptSale,
      cashier: l10n.receiptCashier,
      customer: l10n.receiptCustomer,
      subtotal: l10n.receiptSubtotal,
      discount: l10n.commonDiscount,
      tax: l10n.receiptTax,
      total: l10n.commonTotal,
      payment: l10n.receiptPayment,
      tendered: l10n.receiptTendered,
      change: l10n.posChangeDue,
      payLaterBanner: '*** ${l10n.posPayLater} ***',
      cash: l10n.receiptCash,
      card: l10n.receiptCard,
      payLater: l10n.posPayLater,
    );

/// The receipt for [sale] in the store's language, with real product names
/// (sale lines only carry product ids). Takes its dependencies explicitly
/// so it can run after the screen that started it has closed.
Future<ReceiptDocument> buildSaleReceipt({
  required InventoryRepository inventory,
  required SessionState session,
  required SaleRecord sale,
  required AppSettingsRecord settings,
  required AppLocalizations l10n,
}) async {
  final productNames = <String, String>{};
  for (final productId in sale.lines.map((l) => l.productId).toSet()) {
    final product = await inventory.getProduct(productId);
    productNames[productId] = product?.name ?? productId;
  }
  return ReceiptTemplateBuilder.build(
    sale: sale,
    productNamesById: productNames,
    storeName: session.store?.displayName ?? '',
    branchName: '',
    cashierName: session.employee?.name ?? '',
    currencySymbol: settings.currencySymbol,
    footerText: l10n.receiptThankYou,
    labels: receiptLabelsFor(l10n),
  );
}

/// Prints [doc] on the store's configured printer.
Future<void> printReceiptDocument(ReceiptDocument doc, AppSettingsRecord settings) async {
  final printer = buildPrinterService(
    settings.printerConfig.driverType,
    paperWidthMm: settings.printerConfig.paperWidthMm,
  );
  final address = settings.printerConfig.connectionAddress;
  if (address != null && address.isNotEmpty) {
    await printer.connect(address);
  }
  try {
    await printer.printReceipt(doc);
  } finally {
    await printer.disconnect();
  }
}
