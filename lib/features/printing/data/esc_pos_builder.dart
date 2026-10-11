import 'dart:convert';
import 'dart:typed_data';
import '../../../core/utils/formatters.dart';

import '../domain/receipt_models.dart';

enum EscPosAlign { left, center, right }

/// Minimal, dependency-free ESC/POS command builder. Implemented directly
/// against the widely-supported ESC/POS command subset rather than pulling
/// in a third-party byte-generation package, since that corner of pub.dev
/// churns and this is a small, well-documented protocol.
class EscPosBuilder {
  final BytesBuilder _bytes = BytesBuilder();

  EscPosBuilder init() {
    _bytes.add([0x1B, 0x40]); // ESC @
    return this;
  }

  EscPosBuilder align(EscPosAlign value) {
    final n = switch (value) {
      EscPosAlign.left => 0x00,
      EscPosAlign.center => 0x01,
      EscPosAlign.right => 0x02,
    };
    _bytes.add([0x1B, 0x61, n]); // ESC a n
    return this;
  }

  EscPosBuilder bold(bool on) {
    _bytes.add([0x1B, 0x45, on ? 0x01 : 0x00]); // ESC E n
    return this;
  }

  EscPosBuilder doubleHeight(bool on) {
    _bytes.add([0x1D, 0x21, on ? 0x11 : 0x00]); // GS ! n (double width+height)
    return this;
  }

  EscPosBuilder text(String value, {bool newline = true}) {
    _bytes.add(utf8.encode(value));
    if (newline) _bytes.add([0x0A]);
    return this;
  }

  EscPosBuilder feed([int lines = 1]) {
    for (var i = 0; i < lines; i++) {
      _bytes.add([0x0A]);
    }
    return this;
  }

  EscPosBuilder divider(int paperWidthChars) {
    text('-' * paperWidthChars);
    return this;
  }

  EscPosBuilder cut() {
    _bytes.add([0x1D, 0x56, 0x00]); // GS V 0 (full cut)
    return this;
  }

  Uint8List build() => _bytes.toBytes();

  /// Two-column line where the left part is left-aligned and the right
  /// part is right-aligned, padded to [width] characters (monospace font
  /// assumption, true for virtually all ESC/POS thermal printers).
  static String twoColumn(String left, String right, int width) {
    final space = width - left.length - right.length;
    if (space <= 0) {
      final truncated = left.length > width - right.length - 1
          ? '${left.substring(0, (width - right.length - 1).clamp(0, left.length))}…'
          : left;
      final pad = (width - truncated.length - right.length).clamp(1, width);
      return '$truncated${' ' * pad}$right';
    }
    return '$left${' ' * space}$right';
  }

  static Uint8List buildReceipt(ReceiptDocument doc, {int paperWidthChars = 32}) {
    final b = EscPosBuilder()..init();

    b
      ..align(EscPosAlign.center)
      ..bold(true)
      ..doubleHeight(true)
      ..text(doc.storeName)
      ..doubleHeight(false)
      ..bold(false);
    if (doc.branchName.isNotEmpty) b.text(doc.branchName);
    if (doc.branchAddress.isNotEmpty) b.text(doc.branchAddress);
    if (doc.branchPhone.isNotEmpty) b.text(doc.branchPhone);
    b.feed();

    b
      ..align(EscPosAlign.left)
      ..text('${doc.labels.sale}: ${doc.saleNumber}')
      ..text(_formatDateTime(doc.dateTime))
      ..text('${doc.labels.cashier}: ${doc.cashierName}');
    if (doc.customerName != null && doc.customerName!.isNotEmpty) {
      b.text('${doc.labels.customer}: ${doc.customerName}');
    }
    b.divider(paperWidthChars);

    for (final line in doc.lines) {
      b.text(line.name);
      b.text(twoColumn(
        '  ${line.quantity} x ${_money(line.unitPriceMinorUnits, doc.currencySymbol)}',
        _money(line.lineTotalMinorUnits, doc.currencySymbol),
        paperWidthChars,
      ));
    }
    b.divider(paperWidthChars);

    b.text(twoColumn(doc.labels.subtotal, _money(doc.subtotalMinorUnits, doc.currencySymbol), paperWidthChars));
    if (doc.discountTotalMinorUnits > 0) {
      b.text(twoColumn(doc.labels.discount, '-${_money(doc.discountTotalMinorUnits, doc.currencySymbol)}', paperWidthChars));
    }
    if (doc.taxTotalMinorUnits > 0) {
      b.text(twoColumn(doc.labels.tax, _money(doc.taxTotalMinorUnits, doc.currencySymbol), paperWidthChars));
    }
    b
      ..bold(true)
      ..text(twoColumn(doc.labels.total, _money(doc.grandTotalMinorUnits, doc.currencySymbol), paperWidthChars))
      ..bold(false);

    b.text(twoColumn(doc.labels.payment, doc.paymentMethodLabel, paperWidthChars));
    if (doc.amountTenderedMinorUnits != null) {
      b.text(twoColumn(doc.labels.tendered, _money(doc.amountTenderedMinorUnits!, doc.currencySymbol), paperWidthChars));
    }
    if (doc.changeGivenMinorUnits != null && doc.changeGivenMinorUnits! > 0) {
      b.text(twoColumn(doc.labels.change, _money(doc.changeGivenMinorUnits!, doc.currencySymbol), paperWidthChars));
    }
    if (doc.isPayLater) {
      b
        ..feed()
        ..align(EscPosAlign.center)
        ..bold(true)
        ..text(doc.labels.payLaterBanner)
        ..bold(false);
    }

    b
      ..feed()
      ..align(EscPosAlign.center)
      ..text(doc.footerText)
      ..feed(3)
      ..cut();

    return b.build();
  }

  // Raw ESC/POS text goes through a single-byte code page, so a non-ASCII
  // symbol (د.ع) would print as garbage — fall back to the currency code.
  static String _money(int minorUnits, String symbol) => Money.format(
        minorUnits,
        currencySymbol: RegExp(r'^[\x20-\x7E]*$').hasMatch(symbol) ? symbol : Money.currency.code,
      );

  static String _formatDateTime(DateTime dt) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${dt.year}-${two(dt.month)}-${two(dt.day)} ${two(dt.hour)}:${two(dt.minute)}';
  }
}
