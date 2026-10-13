import 'package:printing/printing.dart';

import '../../domain/printer_service.dart';
import '../../domain/receipt_models.dart';
import '../receipt_pdf.dart';

/// Renders the receipt as a PDF and sends it to a printer registered with
/// the OS — works with any installed printer (thermal roll or A4/A5 sheet),
/// which makes it the universal driver. With a printer chosen in Settings
/// (its name is the connection address) it prints straight to it; without
/// one the system print dialog opens.
class WindowsSystemPrinterDriver implements PrinterService {
  WindowsSystemPrinterDriver({this.paperWidthMm = 58});

  final int paperWidthMm;
  String? _printerUrl;

  @override
  Future<void> connect(String connectionAddress) async {
    _printerUrl = connectionAddress.trim().isEmpty ? null : connectionAddress.trim();
  }

  @override
  Future<void> printReceipt(ReceiptDocument document) async {
    final bytes = await ReceiptPdf.build(document, paperWidthMm: paperWidthMm);
    final format = ReceiptPdf.pageFormat(document.layout, paperWidthMm: paperWidthMm);
    final url = _printerUrl;
    if (url != null) {
      final ok = await Printing.directPrintPdf(
        printer: Printer(url: url),
        format: format,
        name: document.saleNumber,
        onLayout: (_) async => bytes,
      );
      if (!ok) throw PrinterException('The printer "$url" did not accept the job (offline, out of paper?)');
      return;
    }
    await Printing.layoutPdf(format: format, name: document.saleNumber, onLayout: (_) async => bytes);
  }

  @override
  Future<bool> testConnection(String connectionAddress) async {
    final url = connectionAddress.trim();
    if (url.isEmpty) return true;
    try {
      final printers = await Printing.listPrinters();
      return printers.any((p) => p.url == url && p.isAvailable);
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> disconnect() async {}
}
