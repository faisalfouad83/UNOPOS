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

  /// The page the receipt prints on: a roll as long as the receipt (no
  /// blank paper after it), or an A4/A5 sheet.
  static PdfPageFormat pageFormat(ReceiptLayout layout, {int? paperWidthMm, double marginMm = 2}) {
    return switch (layout.paper) {
      ReceiptPaper.a4 => PdfPageFormat.a4.copyWith(
          marginLeft: 14 * PdfPageFormat.mm,
          marginRight: 14 * PdfPageFormat.mm,
          marginTop: 12 * PdfPageFormat.mm,
          marginBottom: 12 * PdfPageFormat.mm,
        ),
      ReceiptPaper.a5 => PdfPageFormat.a5.copyWith(
          marginLeft: 10 * PdfPageFormat.mm,
          marginRight: 10 * PdfPageFormat.mm,
          marginTop: 9 * PdfPageFormat.mm,
          marginBottom: 9 * PdfPageFormat.mm,
        ),
      ReceiptPaper.thermal => PdfPageFormat(
          printableWidthMm(paperWidthMm ?? layout.paperWidthMm) * PdfPageFormat.mm,
          double.infinity,
          marginAll: marginMm * PdfPageFormat.mm,
        ),
    };
  }

  /// The receipt as a PDF in the layout chosen in Settings (paper + style).
  /// [forceThermal] lays an A4/A5 template out on the roll instead — for
  /// thermal printers, which can only print rolls.
  static Future<Uint8List> build(
    ReceiptDocument doc, {
    int? paperWidthMm,
    double marginMm = 2,
    bool forceThermal = false,
  }) async {
    final rtl = doc.allText.any(PdfFonts.hasRtl);
    final theme = await PdfFonts.theme(rtl: rtl);
    final layout = forceThermal
        ? ReceiptLayout(style: doc.layout.style, paperWidthMm: paperWidthMm ?? doc.layout.paperWidthMm)
        : doc.layout;
    final pdf = pw.Document(theme: theme, title: doc.saleNumber);
    final direction = rtl ? pw.TextDirection.rtl : pw.TextDirection.ltr;
    final format = pageFormat(layout, paperWidthMm: paperWidthMm, marginMm: marginMm);
    if (layout.isThermal) {
      pdf.addPage(pw.Page(pageFormat: format, textDirection: direction, build: (_) => _thermal(doc, layout.style)));
    } else {
      pdf.addPage(
        pw.MultiPage(
          pageFormat: format,
          textDirection: direction,
          footer: (context) => context.pagesCount < 2
              ? pw.SizedBox()
              : pw.Align(
                  alignment: pw.Alignment.center,
                  child:
                      pw.Text('${context.pageNumber} / ${context.pagesCount}', style: const pw.TextStyle(fontSize: 8)),
                ),
          build: (_) => _sheet(doc, layout),
        ),
      );
    }
    return pdf.save();
  }

  static String _money(ReceiptDocument doc, int minor) => Money.format(minor, currencySymbol: doc.currencySymbol);

  /// Text laid out in its own direction: Latin-only text (invoice numbers,
  /// English product names) stays left-to-right inside an Arabic receipt
  /// instead of coming out reversed.
  static pw.Text _t(String text, {pw.TextStyle? style, pw.TextAlign? textAlign}) =>
      pw.Text(text, style: style, textAlign: textAlign, textDirection: PdfFonts.directionFor(text));

  /// Roll receipt. Classic: the original layout. Modern: logo and a bold
  /// total band. Compact: one line per item, smaller type.
  static pw.Widget _thermal(ReceiptDocument doc, ReceiptStyle style) {
    final labels = doc.labels;
    final compact = style == ReceiptStyle.compact;
    final modern = style == ReceiptStyle.modern;
    final base = compact ? 8.0 : 9.0;
    final small = pw.TextStyle(fontSize: base);
    String money(int minor) => _money(doc, minor);

    pw.Widget row(String label, String value, {bool bold = false, PdfColor? color}) {
      final textStyle = pw.TextStyle(
        fontSize: bold ? base + 2 : base,
        fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        color: color,
      );
      return pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [pw.Flexible(child: _t(label, style: textStyle)), _t(value, style: textStyle)],
      );
    }

    final logo = doc.logoPng;
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        if (logo != null)
          pw.Center(child: pw.Image(pw.MemoryImage(logo), height: compact ? 28 : 40, fit: pw.BoxFit.contain)),
        pw.Center(
          child: _t(
            doc.storeName,
            style: pw.TextStyle(fontSize: compact ? 12 : (modern ? 16 : 14), fontWeight: pw.FontWeight.bold),
            textAlign: pw.TextAlign.center,
          ),
        ),
        for (final extra in [doc.branchName, doc.branchAddress, doc.branchPhone])
          if (extra.isNotEmpty) pw.Center(child: _t(extra, style: small, textAlign: pw.TextAlign.center)),
        pw.SizedBox(height: compact ? 3 : 6),
        if (modern) ...[
          row(labels.sale, doc.saleNumber),
          row(labels.date, _formatDateTime(doc.dateTime)),
          row(labels.cashier, doc.cashierName),
          if (doc.customerName?.isNotEmpty ?? false) row(labels.customer, doc.customerName!),
        ] else ...[
          _t('${labels.sale}: ${doc.saleNumber}', style: small),
          _t(_formatDateTime(doc.dateTime), style: small),
          _t('${labels.cashier}: ${doc.cashierName}', style: small),
          if (doc.customerName?.isNotEmpty ?? false) _t('${labels.customer}: ${doc.customerName}', style: small),
        ],
        pw.Divider(thickness: 0.5),
        for (final line in doc.lines)
          if (compact)
            row('${line.quantity} × ${line.name}', money(line.lineTotalMinorUnits))
          else ...[
            _t(line.name, style: modern ? small.copyWith(fontWeight: pw.FontWeight.bold) : small),
            row(
              '${line.quantity} × ${money(line.unitPriceMinorUnits)}'
              '${line.discountMinorUnits > 0 ? '  (-${money(line.discountMinorUnits)})' : ''}',
              money(line.lineTotalMinorUnits),
            ),
          ],
        pw.Divider(thickness: 0.5),
        row(labels.subtotal, money(doc.subtotalMinorUnits)),
        if (doc.discountTotalMinorUnits > 0) row(labels.discount, '-${money(doc.discountTotalMinorUnits)}'),
        if (doc.taxTotalMinorUnits > 0) row(labels.tax, money(doc.taxTotalMinorUnits)),
        if (modern)
          pw.Container(
            margin: const pw.EdgeInsets.symmetric(vertical: 3),
            padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 3),
            color: PdfColors.black,
            child: row(labels.total, money(doc.grandTotalMinorUnits), bold: true, color: PdfColors.white),
          )
        else
          row(labels.total, money(doc.grandTotalMinorUnits), bold: true),
        pw.SizedBox(height: compact ? 2 : 4),
        row(labels.payment, doc.paymentMethodLabel),
        if (doc.amountTenderedMinorUnits != null) row(labels.tendered, money(doc.amountTenderedMinorUnits!)),
        if ((doc.changeGivenMinorUnits ?? 0) > 0) row(labels.change, money(doc.changeGivenMinorUnits!)),
        for (final (label, value) in doc.extraRows) row(label, value),
        if (doc.isPayLater) ...[
          pw.SizedBox(height: 4),
          pw.Center(
            child: _t(labels.payLaterBanner, style: pw.TextStyle(fontSize: base + 1, fontWeight: pw.FontWeight.bold)),
          ),
        ],
        pw.SizedBox(height: compact ? 4 : 8),
        pw.Center(child: _t(doc.footerText, style: small, textAlign: pw.TextAlign.center)),
      ],
    );
  }

  /// A4/A5 invoice: header with logo and store details, invoice details,
  /// an item table, totals and payment. Classic is black and white, modern
  /// has a coloured header band, compact uses smaller type and padding.
  static List<pw.Widget> _sheet(ReceiptDocument doc, ReceiptLayout layout) {
    final labels = doc.labels;
    final a5 = layout.paper == ReceiptPaper.a5;
    final compact = layout.style == ReceiptStyle.compact;
    final modern = layout.style == ReceiptStyle.modern;
    final base = (a5 ? 8.5 : 10.0) - (compact ? 1 : 0);
    final accent = modern ? PdfColor.fromInt(0xFF0F6E5C) : PdfColors.black;
    final small = pw.TextStyle(fontSize: base);
    final bold = pw.TextStyle(fontSize: base, fontWeight: pw.FontWeight.bold);
    final pad = compact ? 3.0 : 5.0;
    String money(int minor) => _money(doc, minor);

    pw.Widget info(String label, String value) => pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 2),
          child: pw.Row(children: [_t('$label: ', style: bold), pw.Flexible(child: _t(value, style: small))]),
        );

    pw.Widget totalRow(String label, String value, {bool strong = false}) => pw.Container(
          padding: pw.EdgeInsets.symmetric(vertical: pad / 2, horizontal: pad),
          color: strong && modern ? accent : null,
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _t(label, style: strong ? bold.copyWith(color: modern ? PdfColors.white : null) : small),
              _t(value, style: strong ? bold.copyWith(color: modern ? PdfColors.white : null) : small),
            ],
          ),
        );

    final logo = doc.logoPng;
    final hasDiscount = doc.lines.any((l) => l.discountMinorUnits > 0);
    final headers = [
      '#',
      labels.item,
      labels.quantity,
      labels.unitPrice,
      if (hasDiscount) labels.discount,
      labels.lineTotal,
    ];

    return [
      pw.Container(
        padding: pw.EdgeInsets.all(modern ? pad * 2 : 0),
        color: modern ? accent : null,
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            if (logo != null)
              pw.Padding(
                padding: const pw.EdgeInsetsDirectional.only(end: 10),
                child: pw.Image(pw.MemoryImage(logo), height: a5 ? 40 : 56, fit: pw.BoxFit.contain),
              ),
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _t(
                    doc.storeName,
                    style: pw.TextStyle(
                      fontSize: base + 8,
                      fontWeight: pw.FontWeight.bold,
                      color: modern ? PdfColors.white : null,
                    ),
                  ),
                  for (final extra in [doc.branchName, doc.branchAddress, doc.branchPhone])
                    if (extra.isNotEmpty) _t(extra, style: small.copyWith(color: modern ? PdfColors.white : null)),
                ],
              ),
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                _t(
                  labels.invoice,
                  style: pw.TextStyle(
                      fontSize: base + 6, fontWeight: pw.FontWeight.bold, color: modern ? PdfColors.white : accent),
                ),
                _t(doc.saleNumber, style: bold.copyWith(color: modern ? PdfColors.white : null)),
              ],
            ),
          ],
        ),
      ),
      pw.SizedBox(height: pad * 2),
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                info(labels.date, _formatDateTime(doc.dateTime)),
                info(labels.cashier, doc.cashierName),
              ],
            ),
          ),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (doc.customerName?.isNotEmpty ?? false) info(labels.customer, doc.customerName!),
                info(labels.payment, doc.paymentMethodLabel),
              ],
            ),
          ),
        ],
      ),
      pw.SizedBox(height: pad * 2),
      pw.Table(
        border: modern ? null : pw.TableBorder.all(width: 0.4, color: PdfColors.grey600),
        columnWidths: {
          0: const pw.FixedColumnWidth(22),
          1: const pw.FlexColumnWidth(4),
          for (var i = 2; i < headers.length; i++) i: const pw.FlexColumnWidth(1.4),
        },
        children: [
          pw.TableRow(
            decoration: pw.BoxDecoration(color: modern ? accent : PdfColors.grey300),
            children: [
              for (final h in headers)
                pw.Padding(
                  padding: pw.EdgeInsets.all(pad),
                  child: _t(h, style: bold.copyWith(color: modern ? PdfColors.white : null)),
                ),
            ],
          ),
          for (final (i, line) in doc.lines.indexed)
            pw.TableRow(
              decoration: modern && i.isOdd ? const pw.BoxDecoration(color: PdfColors.grey100) : null,
              children: [
                for (final cell in [
                  '${i + 1}',
                  line.name,
                  '${line.quantity}',
                  money(line.unitPriceMinorUnits),
                  if (hasDiscount) line.discountMinorUnits > 0 ? '-${money(line.discountMinorUnits)}' : '',
                  money(line.lineTotalMinorUnits),
                ])
                  pw.Padding(padding: pw.EdgeInsets.all(pad), child: _t(cell, style: small)),
              ],
            ),
        ],
      ),
      pw.SizedBox(height: pad * 2),
      pw.Row(
        children: [
          pw.Spacer(),
          pw.SizedBox(
            width: a5 ? 170 : 230,
            child: pw.Column(
              children: [
                totalRow(labels.subtotal, money(doc.subtotalMinorUnits)),
                if (doc.discountTotalMinorUnits > 0)
                  totalRow(labels.discount, '-${money(doc.discountTotalMinorUnits)}'),
                if (doc.taxTotalMinorUnits > 0) totalRow(labels.tax, money(doc.taxTotalMinorUnits)),
                pw.Divider(thickness: 0.6, height: 2),
                totalRow(labels.total, money(doc.grandTotalMinorUnits), strong: true),
                if (doc.amountTenderedMinorUnits != null)
                  totalRow(labels.tendered, money(doc.amountTenderedMinorUnits!)),
                if ((doc.changeGivenMinorUnits ?? 0) > 0) totalRow(labels.change, money(doc.changeGivenMinorUnits!)),
                for (final (label, value) in doc.extraRows) totalRow(label, value),
              ],
            ),
          ),
        ],
      ),
      if (doc.isPayLater) ...[
        pw.SizedBox(height: pad * 2),
        pw.Center(child: _t(labels.payLaterBanner, style: bold)),
      ],
      pw.SizedBox(height: pad * 4),
      pw.Center(child: _t(doc.footerText, style: small, textAlign: pw.TextAlign.center)),
    ];
  }

  /// ESC/POS "GS v 0" raster bytes for the receipt, at the printer's native
  /// 203 dpi, ready to send after `ESC @`.
  static Future<Uint8List> escPosRaster(ReceiptDocument doc, {required int paperWidthMm}) async {
    final pdfBytes = await build(doc, paperWidthMm: paperWidthMm, forceThermal: true);
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
