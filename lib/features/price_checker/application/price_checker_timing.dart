/// How long the price checker keeps things on screen, in one place so they
/// are easy to change.
class PriceCheckerTiming {
  const PriceCheckerTiming._();

  /// A product's price stays this long after it was found; then the screen
  /// is ready for the next customer. A new scan or search starts it again.
  static const Duration resultDisplay = Duration(seconds: 5);

  /// A list to choose from (several products share a code, or a typed
  /// search) stays this long, so there is time to read and pick.
  static const Duration choicesDisplay = Duration(seconds: 30);
}
