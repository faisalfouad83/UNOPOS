import 'dart:convert';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/offline/offline_cache.dart';
import '../../../core/providers.dart';
import '../../auth/domain/auth_models.dart';
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
      invoice: l10n.invoiceTitle,
      item: l10n.receiptItem,
      quantity: l10n.commonQuantity,
      unitPrice: l10n.commonPrice,
      lineTotal: l10n.commonTotal,
      date: l10n.invoiceDate,
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
  String? customerName,
  String? cashierName,
  BranchRecord? branch,
  List<(String, String)> extraRows = const [],
}) async {
  final productNames = <String, String>{};
  for (final productId in sale.lines.map((l) => l.productId).toSet()) {
    try {
      final product = await inventory.getProduct(productId);
      productNames[productId] = product?.name ?? productId;
    } catch (_) {
      // Offline: names come from the cached product list instead.
      productNames[productId] = productId;
    }
  }
  if (productNames.entries.any((e) => e.key == e.value) && session.store != null) {
    final cached = await OfflineCache.readRows('products.${session.store!.id}') ?? const [];
    for (final row in cached) {
      final id = row['id'] as String?;
      if (id != null && productNames[id] == id) productNames[id] = row['name'] as String? ?? id;
    }
  }
  final config = settings.printerConfig;
  String? nonEmpty(String? v) => (v?.trim().isEmpty ?? true) ? null : v!.trim();
  return ReceiptTemplateBuilder.build(
    sale: sale,
    productNamesById: productNames,
    storeName: nonEmpty(config.brandName) ?? session.store?.displayName ?? '',
    branchName: branch?.name ?? '',
    branchPhone: nonEmpty(config.brandPhone) ?? branch?.phone ?? '',
    branchAddress: nonEmpty(config.brandAddress) ?? branch?.address ?? '',
    cashierName: cashierName ?? session.employee?.name ?? '',
    customerName: customerName,
    currencySymbol: settings.currencySymbol,
    footerText: nonEmpty(config.brandFooter) ?? l10n.receiptThankYou,
    labels: receiptLabelsFor(l10n),
    extraRows: extraRows,
    logoPng: config.showLogo && config.logoBase64 != null ? base64Decode(config.logoBase64!) : null,
    layout: config.layout,
  );
}

/// Prints [doc] on the store's configured printer.
Future<void> printReceiptDocument(ReceiptDocument doc, AppSettingsRecord settings) async {
  final printer = buildPrinterService(
    settings.printerConfig.driverType,
    paperWidthMm: settings.printerConfig.paperWidthMm,
  );
  // The system printer takes the chosen printer's name (empty = ask).
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
