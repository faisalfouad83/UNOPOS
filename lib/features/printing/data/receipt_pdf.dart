import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../core/utils/formatters.dart';
import '../domain/receipt_models.dart';
import 'pdf_fonts.dart';

/// The receipt laid out as a PDF page, with Arabic-capable fonts. Used as-is
/// by the system-printer driver, and rasterized into an image for thermal
/// printers when the receipt has text their built-in fonts can't print.
class ReceiptPdf {
  const ReceiptPdf._();

  /// Printable width of common roll paper (the print head is narrower than
  /// the paper itself): 48mm on 58mm rolls, 72mm on 80mm rolls.
  static double printableWidthMm(int paperWidthMm) => paperWidthMm >= 80 ? 72 : 48;

  static Future<Uint8List> build(ReceiptDocument doc, {required int paperWidthMm, double marginMm = 2}) async {
    final theme = await PdfFonts.theme();
    final rtl = doc.allText.any(PdfFonts.hasRtl);
    final labels = doc.labels;
    String money(int minor) => Money.format(minor, currencySymbol: doc.currencySymbol);
    const small = pw.TextStyle(fontSize: 9);

    pw.Widget row(String label, String value, {bool bold = false}) {
      final style = pw.TextStyle(fontSize: bold ? 11 : 9, fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal);
      return pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [pw.Text(label, style: style), pw.Text(value, style: style)],
      );
    }

    final pdf = pw.Document(theme: theme);
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(
          printableWidthMm(paperWidthMm) * PdfPageFormat.mm,
          double.infinity,
          marginAll: marginMm * PdfPageFormat.mm,
        ),
        textDirection: rtl ? pw.TextDirection.rtl : pw.TextDirection.ltr,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            pw.Center(
              child: pw.Text(doc.storeName,
                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center),
            ),
            for (final extra in [doc.branchName, doc.branchAddress, doc.branchPhone])
              if (extra.isNotEmpty) pw.Center(child: pw.Text(extra, style: small, textAlign: pw.TextAlign.center)),
            pw.SizedBox(height: 6),
            pw.Text('${labels.sale}: ${doc.saleNumber}', style: small),
            pw.Text(_formatDateTime(doc.dateTime), style: small),
            pw.Text('${labels.cashier}: ${doc.cashierName}', style: small),
            if (doc.customerName?.isNotEmpty ?? false) pw.Text('${labels.customer}: ${doc.customerName}', style: small),
            pw.Divider(thickness: 0.5),
            for (final line in doc.lines) ...[
              pw.Text(line.name, style: small),
              row('${line.quantity} x ${money(line.unitPriceMinorUnits)}', money(line.lineTotalMinorUnits)),
            ],
            pw.Divider(thickness: 0.5),
            row(labels.subtotal, money(doc.subtotalMinorUnits)),
            if (doc.discountTotalMinorUnits > 0) row(labels.discount, '-${money(doc.discountTotalMinorUnits)}'),
            if (doc.taxTotalMinorUnits > 0) row(labels.tax, money(doc.taxTotalMinorUnits)),
            row(labels.total, money(doc.grandTotalMinorUnits), bold: true),
            pw.SizedBox(height: 4),
            row(labels.payment, doc.paymentMethodLabel),
            if (doc.amountTenderedMinorUnits != null) row(labels.tendered, money(doc.amountTenderedMinorUnits!)),
            if ((doc.changeGivenMinorUnits ?? 0) > 0) row(labels.change, money(doc.changeGivenMinorUnits!)),
            for (final (label, value) in doc.extraRows) row(label, value),
            if (doc.isPayLater) ...[
              pw.SizedBox(height: 4),
              pw.Center(
                child: pw.Text(labels.payLaterBanner, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
              ),
            ],
            pw.SizedBox(height: 8),
            pw.Center(child: pw.Text(doc.footerText, style: small, textAlign: pw.TextAlign.center)),
          ],
        ),
      ),
    );
    return pdf.save();
  }

  /// ESC/POS "GS v 0" raster bytes for the receipt, at the printer's native
  /// 203 dpi, ready to send after `ESC @`.
  static Future<Uint8List> escPosRaster(ReceiptDocument doc, {required int paperWidthMm}) async {
    final pdfBytes = await build(doc, paperWidthMm: paperWidthMm);
    final out = BytesBuilder();
    await for (final page in Printing.raster(pdfBytes, dpi: 203)) {
      out.add(rasterToEscPos(page.pixels, page.width, page.height));
    }
    return out.toBytes();
  }

  /// Packs RGBA pixels into 1-bit rows (dark pixel = printed dot) wrapped
  /// in GS v 0 commands. Sent in bands of [bandHeight] rows, since some
  /// printers' buffers can't take a whole long receipt as one image.
  static Uint8List rasterToEscPos(Uint8List rgba, int width, int height, {int bandHeight = 256}) {
    final bytesPerRow = (width + 7) ~/ 8;
    final out = BytesBuilder();
    for (var top = 0; top < height; top += bandHeight) {
      final rows = (height - top) < bandHeight ? height - top : bandHeight;
      final bits = Uint8List(bytesPerRow * rows);
      for (var y = 0; y < rows; y++) {
        for (var x = 0; x < width; x++) {
          final i = ((top + y) * width + x) * 4;
          final alpha = rgba[i + 3];
          // Transparent counts as paper-white.
          final luminance = alpha == 0 ? 255 : (rgba[i] * 299 + rgba[i + 1] * 587 + rgba[i + 2] * 114) ~/ 1000;
          if (luminance < 128) bits[y * bytesPerRow + (x >> 3)] |= 0x80 >> (x & 7);
        }
      }
      out
        ..add([0x1D, 0x76, 0x30, 0x00, bytesPerRow & 0xFF, bytesPerRow >> 8, rows & 0xFF, rows >> 8])
        ..add(bits);
    }
    return out.toBytes();
  }

  static String _formatDateTime(DateTime dt) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${dt.year}-${two(dt.month)}-${two(dt.day)} ${two(dt.hour)}:${two(dt.minute)}';
  }
}
