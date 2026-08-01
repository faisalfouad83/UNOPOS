import '../../domain/printer_service.dart';
import '../../domain/receipt_models.dart';

/// Bluetooth thermal printer driver (Android-focused — most inexpensive
/// thermal printers' Bluetooth stacks are not well supported on Windows).
///
/// KNOWN GAP: same as [UsbPrinterDriver] — needs a platform Bluetooth
/// package plus real hardware to pick and validate a reliable
/// package/version, which isn't possible in this environment. Structurally
/// wired up so Settings can already offer "Bluetooth" as a driver choice.
class BluetoothPrinterDriver implements PrinterService {
  @override
  Future<void> connect(String connectionAddress) async {
    throw PrinterException(
      'Bluetooth printing is not yet implemented. Choose Network or Windows System Printer instead.',
    );
  }

  @override
  Future<void> printReceipt(ReceiptDocument document) async {
    throw PrinterException('Bluetooth printing is not yet implemented.');
  }

  @override
  Future<bool> testConnection(String connectionAddress) async => false;

  @override
  Future<void> disconnect() async {}
}
