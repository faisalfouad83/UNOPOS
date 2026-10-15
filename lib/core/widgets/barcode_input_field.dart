import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    this.errorText,
  });

  final TextEditingController controller;
  final String label;
  final ValueChanged<String>? onSubmitted;
  final String? helperText;
  final String? errorText;

  Future<void> _scanWithCamera(BuildContext context) async {
    final result = await scanBarcodeOnce(context);
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
        helperMaxLines: 2,
        errorText: errorText,
        errorMaxLines: 2,
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

/// Whether this device has a camera to read barcodes with (phones and
/// tablets); desktops use a scanner that types into the field instead.
bool get cameraScanAvailable => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

/// Reads one barcode with the camera; null if closed without one.
Future<String?> scanBarcodeOnce(BuildContext context) =>
    Navigator.of(context).push<String>(MaterialPageRoute(builder: (context) => _CameraScanScreen()));

/// Keeps the camera open and hands every barcode read to [onCode] (the
/// same code again only after a pause), showing what it returns (e.g. the
/// product added) until the next one. For ringing up a basket item by item.
Future<void> scanBarcodesContinuously(BuildContext context, {required Future<String?> Function(String code) onCode}) =>
    Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (context) => _CameraScanScreen(continuous: onCode)),
    );

class _CameraScanScreen extends StatefulWidget {
  const _CameraScanScreen({this.continuous});

  final Future<String?> Function(String code)? continuous;

  @override
  State<_CameraScanScreen> createState() => _CameraScanScreenState();
}

class _CameraScanScreenState extends State<_CameraScanScreen> {
  bool _handled = false;
  String? _lastCode;
  DateTime _lastAt = DateTime(0);
  String? _message;
  bool _busy = false;

  Future<void> _onDetect(BarcodeCapture capture) async {
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    final value = barcodes.first.rawValue;
    if (value == null || value.isEmpty) return;
    final continuous = widget.continuous;
    if (continuous == null) {
      if (_handled) return;
      _handled = true;
      Navigator.of(context).pop(value);
      return;
    }
    // The same code stays in view for a while: count it once per pause.
    final now = DateTime.now();
    if (_busy || (value == _lastCode && now.difference(_lastAt) < const Duration(milliseconds: 1500))) return;
    _lastCode = value;
    _lastAt = now;
    _busy = true;
    HapticFeedback.mediumImpact();
    final message = await continuous(value);
    if (!mounted) return;
    setState(() {
      _message = message;
      _busy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.barcodeScanTitle)),
      body: Stack(
        children: [
          MobileScanner(onDetect: _onDetect),
          if (widget.continuous != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 24,
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_message != null)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(_message!, textAlign: TextAlign.center),
                        ),
                      ),
                    const SizedBox(height: 8),
                    FilledButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.check),
                      label: Text(l10n.actionDone),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
