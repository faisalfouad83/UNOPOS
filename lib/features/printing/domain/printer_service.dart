import 'receipt_models.dart';

class PrinterException implements Exception {
  PrinterException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// One interface, four connection-type drivers (network/USB/Bluetooth
/// ESC-POS thermal printers, plus a generic Windows-system-printer
/// fallback). Settings persists which driver + connection details a store
/// is using; the POS checkout flow only ever talks to this interface.
abstract class PrinterService {
  Future<void> connect(String connectionAddress);
  Future<void> printReceipt(ReceiptDocument document);
  Future<bool> testConnection(String connectionAddress);
  Future<void> disconnect();
}
