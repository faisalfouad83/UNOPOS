import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../settings/domain/settings_models.dart';
import '../data/receipt_pdf.dart';
import '../domain/receipt_models.dart';
import 'sale_receipt.dart';

/// Shows [doc] exactly as it will print with the store's template (paper,
/// style, logo, branding), with the system print/share actions.
Future<void> showReceiptPreview(BuildContext context, ReceiptDocument doc, AppSettingsRecord settings) {
  final l10n = AppLocalizations.of(context);
  final layout = doc.layout;
  final format = ReceiptPdf.pageFormat(layout, paperWidthMm: settings.printerConfig.paperWidthMm);
  return showDialog<void>(
    context: context,
    builder: (context) => Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: layout.isThermal ? 480 : 820, maxHeight: 900),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.preview_outlined),
              title: Text(l10n.printPreview),
              trailing: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
            ),
            Expanded(
              child: PdfPreview(
                build: (_) => ReceiptPdf.build(doc, paperWidthMm: settings.printerConfig.paperWidthMm),
                initialPageFormat: format,
                canChangePageFormat: false,
                canChangeOrientation: false,
                canDebug: false,
                pdfFileName: '${doc.saleNumber}.pdf',
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// A sample receipt in the store's template and branding, for previewing
/// in Settings before printing anything real. Marked as a sample.
ReceiptDocument sampleReceipt(AppSettingsRecord settings, {required String storeName, required AppLocalizations l10n}) {
  final config = settings.printerConfig;
  String? nonEmpty(String? v) => (v?.trim().isEmpty ?? true) ? null : v!.trim();
  return ReceiptDocument(
    storeName: nonEmpty(config.brandName) ?? storeName,
    branchName: '',
    branchPhone: nonEmpty(config.brandPhone) ?? '',
    branchAddress: nonEmpty(config.brandAddress) ?? '',
    saleNumber: l10n.printSample,
    dateTime: DateTime.now(),
    cashierName: '—',
    lines: [
      ReceiptLine(name: '${l10n.receiptItem} 1', quantity: 2, unitPriceMinorUnits: 150000, lineTotalMinorUnits: 300000),
      ReceiptLine(
        name: '${l10n.receiptItem} 2',
        quantity: 1,
        unitPriceMinorUnits: 525000,
        lineTotalMinorUnits: 500000,
        discountMinorUnits: 25000,
      ),
    ],
    subtotalMinorUnits: 825000,
    discountTotalMinorUnits: 25000,
    taxTotalMinorUnits: 0,
    grandTotalMinorUnits: 800000,
    paymentMethodLabel: l10n.receiptCash,
    amountTenderedMinorUnits: 1000000,
    changeGivenMinorUnits: 200000,
    currencySymbol: settings.currencySymbol,
    footerText: nonEmpty(config.brandFooter) ?? l10n.receiptThankYou,
    labels: receiptLabelsFor(l10n),
    logoPng: config.showLogo && config.logoBase64 != null ? base64Decode(config.logoBase64!) : null,
    layout: config.layout,
  );
}
