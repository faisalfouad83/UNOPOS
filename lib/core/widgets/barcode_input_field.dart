import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/l10n/l10n_ext.dart';

/// A text field for barcode/SKU entry that doubles as a barcode reader in
/// two ways: (1) a camera-scan button (Android, via mobile_scanner) and
/// (2) natively working as a "keyboard wedge" target — most USB/Bluetooth
/// HID barcode scanners (the common setup on Windows POS terminals) just
/// type digits followed by Enter into whatever text field has focus, so no
/// special handling is required beyond being a normal focused TextField.
class BarcodeInputField extends StatelessWidget {
  const BarcodeInputField({
    super.key,
    required this.controller,
    this.label = 'Barcode',
    this.onSubmitted,
    this.helperText,
  });

  final TextEditingController controller;
  final String label;
  final ValueChanged<String>? onSubmitted;
  final String? helperText;

  Future<void> _scanWithCamera(BuildContext context) async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (context) => _CameraScanScreen()),
    );
    if (result != null) {
      controller.text = result;
      onSubmitted?.call(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        suffixIcon: IconButton(
          icon: const Icon(Icons.qr_code_scanner),
          tooltip: context.l10n.barcodeScan,
          onPressed: () => _scanWithCamera(context),
        ),
      ),
      onSubmitted: onSubmitted,
    );
  }
}

class _CameraScanScreen extends StatefulWidget {
  @override
  State<_CameraScanScreen> createState() => _CameraScanScreenState();
}

class _CameraScanScreenState extends State<_CameraScanScreen> {
  bool _handled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.barcodeScanTitle)),
      body: MobileScanner(
        onDetect: (capture) {
          if (_handled) return;
          final barcodes = capture.barcodes;
          if (barcodes.isEmpty) return;
          final value = barcodes.first.rawValue;
          if (value == null) return;
          _handled = true;
          Navigator.of(context).pop(value);
        },
      ),
    );
  }
}
