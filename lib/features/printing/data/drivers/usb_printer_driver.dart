import '../../domain/printer_service.dart';
import '../../domain/receipt_models.dart';

/// USB thermal printer driver.
///
/// KNOWN GAP: raw USB device access from Flutter needs a platform-specific
/// package (on Android, a USB-serial/USB-host package; on Windows, sending
/// bytes through the Win32 print spooler to a printer registered as a USB
/// printer object). That integration needs real hardware to select and pin
/// a reliable package/version and cannot be verified in this environment.
/// The interface is wired up end-to-end (Settings can select "USB" as the
/// driver type) so plugging in a real implementation later is a contained
/// change in this one file.
class UsbPrinterDriver implements PrinterService {
  @override
  Future<void> connect(String connectionAddress) async {
    throw PrinterException(
      'USB printing is not yet implemented on this platform. Choose Network or Windows System Printer instead.',
    );
  }

  @override
  Future<void> printReceipt(ReceiptDocument document) async {
    throw PrinterException('USB printing is not yet implemented on this platform.');
  }

  @override
  Future<bool> testConnection(String connectionAddress) async => false;

  @override
  Future<void> disconnect() async {}
}
