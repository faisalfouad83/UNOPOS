import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/l10n/gen/app_localizations.dart';
import '../../../core/providers.dart';
import '../../../core/utils/formatters.dart';
import '../../printing/data/pdf_fonts.dart';
import '../domain/barcode_generator.dart';
import '../domain/inventory_models.dart';

/// The label encodes the product's barcode (falling back to its SKU) so a
/// label scan resolves the same way a barcode scan would elsewhere in the
/// app. It's printed as a linear barcode — what handheld POS scanners read —
/// and only falls back to a QR code when the value can't be encoded
/// linearly (e.g. a SKU with Arabic characters).
///
/// A product with no barcode at all gets a "Generate barcode" button that
/// assigns it an in-store EAN-13 and saves it on the product.
Future<void> showQrLabelDialog(BuildContext context, WidgetRef ref, ProductRecord product) async {
  var current = product;
  var generating = false;

  await showDialog<void>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        final l10n = AppLocalizations.of(context);
        final hasBarcode = current.barcode?.isNotEmpty ?? false;
        final payload = hasBarcode ? current.barcode! : current.sku;
        final symbology = _symbologyFor(payload);

        return AlertDialog(
          title: Text(current.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (payload.isEmpty)
                const SizedBox(height: 80, child: Icon(Icons.qr_code_2, size: 64))
              else if (symbology == null)
                QrImageView(data: payload, size: 200, backgroundColor: Colors.white)
              else
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: CustomPaint(size: const Size(260, 90), painter: _BarcodePainter(symbology, payload)),
                ),
              const SizedBox(height: 12),
              Text(payload, style: const TextStyle(fontFamily: 'monospace')),
              const SizedBox(height: 4),
              Text(Money.format(current.sellPriceMinorUnits)),
              if (!hasBarcode) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  icon: generating
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.auto_awesome),
                  label: Text(l10n.inventoryGenerateBarcode),
                  onPressed: generating
                      ? null
                      : () async {
                          setState(() => generating = true);
                          try {
                            final updated = await assignGeneratedBarcode(ref, current);
                            setState(() => current = updated);
                          } finally {
                            if (context.mounted) setState(() => generating = false);
                          }
                        },
                ),
              ],
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.actionClose)),
            FilledButton.icon(
              icon: const Icon(Icons.print),
              label: Text(l10n.inventoryPrintLabel),
              onPressed: payload.isEmpty ? null : () => _printLabel(current, payload),
            ),
          ],
        );
      },
    ),
  );
}

/// Gives [product] a fresh in-store barcode (and uses it as the SKU too if
/// the SKU is blank), persists it, and returns the updated record.
Future<ProductRecord> assignGeneratedBarcode(WidgetRef ref, ProductRecord product) async {
  final repo = ref.read(inventoryRepositoryProvider);
  final code = await BarcodeGenerator.newUniqueBarcode(repo, product.storeId);
  final updated = product.copyWith(barcode: code, sku: product.sku.trim().isEmpty ? code : product.sku);
  await repo.updateProduct(updated);
  return updated;
}

pw.Barcode? _symbologyFor(String payload) {
  if (payload.isEmpty) return null;
  if (BarcodeGenerator.isValidEan13(payload)) return pw.Barcode.ean13();
  final code128 = pw.Barcode.code128();
  return code128.isValid(payload) ? code128 : null;
}

class _BarcodePainter extends CustomPainter {
  _BarcodePainter(this.barcode, this.data);

  final pw.Barcode barcode;
  final String data;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black;
    for (final element in barcode.make(data, width: size.width, height: size.height)) {
      if (element is pw.BarcodeBar && element.black) {
        canvas.drawRect(Rect.fromLTWH(element.left, element.top, element.width, element.height), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_BarcodePainter oldDelegate) => oldDelegate.data != data;
}

Future<void> _printLabel(ProductRecord product, String payload) async {
  final doc = pw.Document(theme: await PdfFonts.theme(rtl: PdfFonts.hasRtl(product.name)));
  final symbology = _symbologyFor(payload);

  final pw.Widget code;
  if (symbology != null) {
    code = pw.BarcodeWidget(
      barcode: symbology,
      data: payload,
      height: 14 * PdfPageFormat.mm,
      textStyle: const pw.TextStyle(fontSize: 7),
    );
  } else {
    final qrImage = await QrPainter(data: payload, version: QrVersions.auto, gapless: true)
        .toImageData(300)
        .then((byteData) => byteData!.buffer.asUint8List());
    code = pw.Image(pw.MemoryImage(qrImage), width: 16 * PdfPageFormat.mm, height: 16 * PdfPageFormat.mm);
  }

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat(50 * PdfPageFormat.mm, 30 * PdfPageFormat.mm, marginAll: 2 * PdfPageFormat.mm),
      build: (context) => pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(product.name,
              style: const pw.TextStyle(fontSize: 7), maxLines: 1, textDirection: PdfFonts.directionFor(product.name)),
          code,
          pw.Text(Money.format(product.sellPriceMinorUnits),
              style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    ),
  );

  await Printing.layoutPdf(onLayout: (_) async => doc.save());
}
