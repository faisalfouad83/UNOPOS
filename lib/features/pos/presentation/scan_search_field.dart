import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../domain/barcode_scan.dart';

/// The till's search box, built for barcode scanners that type like a
/// keyboard (USB/Bluetooth HID): every code ending in Enter (or Tab, or a
/// CR/LF inside the text) is handed to [onScan], the box is cleared and
/// keeps focus, ready for the next scan — no clicking between scans.
///
/// * Codes are processed one at a time, in order, so fast back-to-back
///   scans are neither lost nor added twice; an Enter with an empty box
///   (scanners that send CR+LF) is ignored.
/// * If focus wandered off (a click on a product tile, a closed dialog),
///   characters typed while nothing else is being edited on this screen are
///   routed back into the box, so the next scan still lands here. Keys
///   typed into another field, or while a dialog is open, are left alone.
class ScanSearchField extends StatefulWidget {
  const ScanSearchField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onScan,
    required this.onChanged,
    this.hintText,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final Future<void> Function(String code) onScan;
  final ValueChanged<String> onChanged;
  final String? hintText;

  @override
  State<ScanSearchField> createState() => _ScanSearchFieldState();
}

class _ScanSearchFieldState extends State<ScanSearchField> {
  Future<void> _queue = Future.value();

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_captureStrayKeys);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_captureStrayKeys);
    super.dispose();
  }

  void _submit(String raw) {
    final codes = splitScannedCodes(raw);
    // Clear first: the scanner may already be typing the next code.
    widget.controller.clear();
    widget.onChanged('');
    widget.focusNode.requestFocus();
    for (final code in codes) {
      _queue = _queue.then((_) => widget.onScan(code)).catchError((Object _) {});
    }
  }

  void _onChanged(String value) {
    if (value.contains(RegExp(r'[\r\n\t]'))) {
      _submit(value);
      return;
    }
    widget.onChanged(value);
  }

  /// Puts printable keys typed while focus is elsewhere on this screen
  /// (but not in another text field or a dialog) into the box.
  bool _captureStrayKeys(KeyEvent event) {
    if (!mounted || widget.focusNode.hasFocus || event is! KeyDownEvent) return false;
    final character = event.character;
    if (character == null || character.isEmpty || character.codeUnitAt(0) < 0x20) return false;
    final keyboard = HardwareKeyboard.instance;
    if (keyboard.isControlPressed || keyboard.isAltPressed || keyboard.isMetaPressed) return false;

    final routeScope = FocusScope.of(context);
    final primary = FocusManager.instance.primaryFocus;
    if (primary != null && primary != routeScope && !primary.ancestors.contains(routeScope)) {
      return false; // a dialog or another screen has the keyboard
    }
    if (primary?.context?.findAncestorStateOfType<EditableTextState>() != null) return false;

    widget.focusNode.requestFocus();
    final text = widget.controller.text + character;
    widget.controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    widget.onChanged(text);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      // Scanners set to end codes with Tab: submit instead of moving focus.
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.tab &&
            widget.controller.text.trim().isNotEmpty) {
          _submit(widget.controller.text);
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: TextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        autofocus: true,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.qr_code_scanner),
          hintText: widget.hintText,
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: widget.controller,
            builder: (context, value, _) => value.text.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      widget.controller.clear();
                      widget.onChanged('');
                      widget.focusNode.requestFocus();
                    },
                  ),
          ),
        ),
        onChanged: _onChanged,
        // Keep the keyboard focus here after Enter (mobile would otherwise
        // close the keyboard and drop focus).
        onEditingComplete: () {},
        onSubmitted: _submit,
      ),
    );
  }
}
