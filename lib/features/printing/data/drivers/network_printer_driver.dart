import 'dart:io';

import '../../domain/printer_service.dart';
import '../../domain/receipt_models.dart';
import '../esc_pos_builder.dart';

/// Talks to a WiFi/LAN ESC/POS thermal printer over a raw TCP socket
/// (the standard "port 9100 raw printing" protocol nearly every network
/// thermal printer supports) — no third-party package needed.
class NetworkPrinterDriver implements PrinterService {
  NetworkPrinterDriver({this.paperWidthChars = 32});

  final int paperWidthChars;
  Socket? _socket;

  (String host, int port) _parseAddress(String address) {
    final parts = address.split(':');
    final host = parts.first;
    final port = parts.length > 1 ? int.tryParse(parts[1]) ?? 9100 : 9100;
    return (host, port);
  }

  @override
  Future<void> connect(String connectionAddress) async {
    final (host, port) = _parseAddress(connectionAddress);
    try {
      _socket = await Socket.connect(host, port, timeout: const Duration(seconds: 5));
    } catch (e) {
      throw PrinterException('Could not connect to network printer at $connectionAddress: $e');
    }
  }

  @override
  Future<void> printReceipt(ReceiptDocument document) async {
    // Reuse an existing connection if one is open; otherwise the caller is
    // expected to have called connect() with the configured address first.
    if (_socket == null) {
      throw PrinterException('Not connected to a network printer');
    }
    final bytes = EscPosBuilder.buildReceipt(document, paperWidthChars: paperWidthChars);
    _socket!.add(bytes);
    await _socket!.flush();
  }

  @override
  Future<bool> testConnection(String connectionAddress) async {
    final (host, port) = _parseAddress(connectionAddress);
    try {
      final socket = await Socket.connect(host, port, timeout: const Duration(seconds: 3));
      await socket.close();
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> disconnect() async {
    await _socket?.close();
    _socket = null;
  }
}
