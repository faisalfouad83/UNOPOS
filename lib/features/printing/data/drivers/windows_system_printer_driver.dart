import 'package:printing/printing.dart';

import '../../domain/printer_service.dart';
import '../../domain/receipt_models.dart';
import '../receipt_pdf.dart';

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
    final bytes = await ReceiptPdf.build(document, paperWidthMm: paperWidthMm);
    await Printing.layoutPdf(onLayout: (_) async => bytes);
  }

  @override
  Future<bool> testConnection(String connectionAddress) async => true;

  @override
  Future<void> disconnect() async {}
}
