import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../domain/printer_service.dart';
import '../../domain/receipt_models.dart';

/// Renders the receipt as a small PDF page and sends it to whatever printer
/// is registered with the OS — works with any installed printer (thermal or
/// otherwise), which makes it the universal fallback driver. Primarily
/// targets Windows desktop, where "just print to the default printer" is
/// often simpler to support than raw USB device access.
class WindowsSystemPrinterDriver implements PrinterService {
  WindowsSystemPrinterDriver({this.paperWidthMm = 58});

  final int paperWidthMm;

  @override
  Future<void> connect(String connectionAddress) async {
    // Nothing to keep open — each print job talks to the OS print spooler
    // independently via Printing.layoutPdf/directPrintPdf.
  }

  @override
  Future<void> printReceipt(ReceiptDocument document) async {
    final pdfWidthPoints = paperWidthMm * PdfPageFormat.mm;
    final format = PdfPageFormat(pdfWidthPoints, double.infinity, marginAll: 8 * PdfPageFormat.mm);

    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        pageFormat: format,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            pw.Center(
              child: pw.Text(document.storeName, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            ),
            if (document.branchName.isNotEmpty)
              pw.Center(child: pw.Text(document.branchName, style: const pw.TextStyle(fontSize: 9))),
            pw.SizedBox(height: 6),
            pw.Text('Sale: ${document.saleNumber}', style: const pw.TextStyle(fontSize: 9)),
            pw.Text('${document.dateTime}', style: const pw.TextStyle(fontSize: 9)),
            pw.Text('Cashier: ${document.cashierName}', style: const pw.TextStyle(fontSize: 9)),
            pw.Divider(),
            ...document.lines.map(
              (line) => pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    child: pw.Text('${line.name}  x${line.quantity}', style: const pw.TextStyle(fontSize: 9)),
                  ),
                  pw.Text(_money(line.lineTotalMinorUnits, document.currencySymbol),
                      style: const pw.TextStyle(fontSize: 9)),
                ],
              ),
            ),
            pw.Divider(),
            _totalRow('Subtotal', document.subtotalMinorUnits, document.currencySymbol),
            if (document.discountTotalMinorUnits > 0)
              _totalRow('Discount', -document.discountTotalMinorUnits, document.currencySymbol),
            if (document.taxTotalMinorUnits > 0)
              _totalRow('Tax', document.taxTotalMinorUnits, document.currencySymbol),
            _totalRow('TOTAL', document.grandTotalMinorUnits, document.currencySymbol, bold: true),
            pw.SizedBox(height: 6),
            pw.Text('Payment: ${document.paymentMethodLabel}', style: const pw.TextStyle(fontSize: 9)),
            if (document.isPayLater)
              pw.Center(
                child: pw.Text('*** ON ACCOUNT / PAY LATER ***',
                    style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
              ),
            pw.SizedBox(height: 10),
            pw.Center(child: pw.Text(document.footerText, style: const pw.TextStyle(fontSize: 9))),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (_) async => doc.save());
  }

  pw.Widget _totalRow(String label, int minorUnits, String symbol, {bool bold = false}) {
    final style = pw.TextStyle(fontSize: 9, fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal);
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: style),
        pw.Text(_money(minorUnits, symbol), style: style),
      ],
    );
  }

  String _money(int minorUnits, String symbol) => '$symbol${(minorUnits / 100).toStringAsFixed(2)}';

  @override
  Future<bool> testConnection(String connectionAddress) async => true;

  @override
  Future<void> disconnect() async {}
}
