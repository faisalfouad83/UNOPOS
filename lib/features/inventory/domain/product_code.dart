/// Why a typed barcode/product code can't be saved.
enum ProductCodeError { invalidCharacters, tooLong, badCheckDigit }

/// Checks a barcode or product code typed (or scanned) into the product
/// form. Letters, digits and - _ . are allowed (Code 128 / Code 39 style
/// codes), up to 64 characters. All-digit codes of 8, 12 or 13 digits are
/// EAN-8 / UPC-A / EAN-13 and must carry a correct check digit — that
/// catches most typing mistakes. Null when the code is fine.
ProductCodeError? validateProductCode(String code) {
  final c = code.trim();
  if (c.isEmpty) return null;
  if (c.length > 64) return ProductCodeError.tooLong;
  if (!RegExp(r'^[A-Za-z0-9._\-]+$').hasMatch(c)) return ProductCodeError.invalidCharacters;
  if (RegExp(r'^\d+$').hasMatch(c) && (c.length == 8 || c.length == 12 || c.length == 13)) {
    if (!hasValidGtinCheckDigit(c)) return ProductCodeError.badCheckDigit;
  }
  return null;
}

/// GS1 check digit over EAN-8, UPC-A (12) and EAN-13: weights 3,1,3,1…
/// from the right, excluding the check digit itself.
bool hasValidGtinCheckDigit(String digits) {
  var sum = 0;
  final body = digits.substring(0, digits.length - 1);
  for (var i = 0; i < body.length; i++) {
    final d = body.codeUnitAt(body.length - 1 - i) - 48;
    sum += i.isEven ? d * 3 : d;
  }
  return (10 - sum % 10) % 10 == digits.codeUnitAt(digits.length - 1) - 48;
}
