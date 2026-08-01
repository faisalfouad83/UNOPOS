import 'package:flutter/material.dart';

/// A large-target numeric keypad for PIN entry — used for both employee
/// login and the store-password-adjacent flows. Deliberately big and simple:
/// this runs on shared retail terminals, often touched in a hurry.
class NumericPinPad extends StatelessWidget {
  const NumericPinPad({
    super.key,
    required this.value,
    required this.onChanged,
    this.maxLength = 4,
    this.onSubmit,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final int maxLength;
  final VoidCallback? onSubmit;

  void _append(String digit) {
    if (value.length >= maxLength) return;
    final next = value + digit;
    onChanged(next);
    if (next.length == maxLength) {
      onSubmit?.call();
    }
  }

  void _backspace() {
    if (value.isEmpty) return;
    onChanged(value.substring(0, value.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    const layout = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', '⌫'],
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(maxLength, (i) {
            final filled = i < value.length;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: filled
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
            );
          }),
        ),
        const SizedBox(height: 32),
        for (final row in layout)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: row.map((key) {
                if (key.isEmpty) return const SizedBox(width: 76, height: 76);
                final isBackspace = key == '⌫';
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: SizedBox(
                    width: 76,
                    height: 76,
                    child: Material(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: isBackspace ? _backspace : () => _append(key),
                        child: Center(
                          child: isBackspace
                              ? const Icon(Icons.backspace_outlined)
                              : Text(key, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
