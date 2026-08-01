import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/utils/formatters.dart';
import '../domain/inventory_models.dart';

/// The QR payload encodes the product's barcode (falling back to its SKU)
/// so a label scan resolves the same way a barcode scan would elsewhere in
/// the app.
Future<void> showQrLabelDialog(BuildContext context, ProductRecord product) async {
  final l10n = AppLocalizations.of(context);
  final payload = (product.barcode?.isNotEmpty ?? false) ? product.barcode! : product.sku;

  await showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(product.name),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          QrImageView(data: payload, size: 200, backgroundColor: Colors.white),
          const SizedBox(height: 12),
          Text(payload, style: const TextStyle(fontFamily: 'monospace')),
          const SizedBox(height: 4),
          Text(Money.format(product.sellPriceMinorUnits, currencySymbol: r'$')),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.actionClose)),
        FilledButton.icon(
          icon: const Icon(Icons.print),
          label: Text(l10n.actionPrint),
          onPressed: () => _printLabel(product, payload),
        ),
      ],
    ),
  );
}

Future<void> _printLabel(ProductRecord product, String payload) async {
  final doc = pw.Document();
  final qrImage = await QrPainter(data: payload, version: QrVersions.auto, gapless: true)
      .toImageData(300)
      .then((byteData) => byteData!.buffer.asUint8List());

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat(50 * PdfPageFormat.mm, 30 * PdfPageFormat.mm, marginAll: 2 * PdfPageFormat.mm),
      build: (context) => pw.Row(
        children: [
          pw.Image(pw.MemoryImage(qrImage), width: 24 * PdfPageFormat.mm, height: 24 * PdfPageFormat.mm),
          pw.SizedBox(width: 4),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(product.name, style: const pw.TextStyle(fontSize: 8), maxLines: 2),
                pw.Text(Money.format(product.sellPriceMinorUnits, currencySymbol: r'$'), style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  await Printing.layoutPdf(onLayout: (_) async => doc.save());
}
