import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unopos/core/widgets/numeric_pin_pad.dart';

void main() {
  testWidgets('NumericPinPad accumulates digits and calls onSubmit at maxLength', (tester) async {
    String value = '';
    var submitted = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => NumericPinPad(
              value: value,
              maxLength: 4,
              onChanged: (v) => setState(() => value = v),
              onSubmit: () => submitted = true,
            ),
          ),
        ),
      ),
    );

    for (final digit in ['1', '3', '1', '3']) {
      await tester.tap(find.text(digit).first);
      await tester.pump();
    }

    expect(value, '1313');
    expect(submitted, isTrue);
  });

  testWidgets('backspace removes the last digit', (tester) async {
    String value = '12';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => NumericPinPad(
              value: value,
              maxLength: 4,
              onChanged: (v) => setState(() => value = v),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.backspace_outlined));
    await tester.pump();

    expect(value, '1');
  });

  testWidgets('does not accept more digits than maxLength', (tester) async {
    String value = '1313';
    var onChangedCallCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => NumericPinPad(
              value: value,
              maxLength: 4,
              onChanged: (v) {
                onChangedCallCount++;
                setState(() => value = v);
              },
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('5').first);
    await tester.pump();

    expect(onChangedCallCount, 0);
    expect(value, '1313');
  });
}
