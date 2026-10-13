import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unopos/features/pos/presentation/scan_search_field.dart';

void main() {
  late List<String> scanned;
  late TextEditingController controller;
  late FocusNode focus;

  Future<void> pump(WidgetTester tester) async {
    scanned = [];
    controller = TextEditingController();
    focus = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focus.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              ScanSearchField(
                controller: controller,
                focusNode: focus,
                onChanged: (_) {},
                onScan: (code) async => scanned.add(code),
              ),
              ElevatedButton(onPressed: () {}, child: const Text('tile')),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('several scans in a row without touching the box', (tester) async {
    await pump(tester);
    expect(focus.hasFocus, isTrue);

    for (final code in ['6291001', '6291002', '6291001']) {
      await tester.enterText(find.byType(TextField), code);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(controller.text, isEmpty);
      expect(focus.hasFocus, isTrue);
    }
    expect(scanned, ['6291001', '6291002', '6291001']);
  });

  testWidgets('a stray Enter (scanner CR+LF) adds nothing', (tester) async {
    await pump(tester);
    await tester.enterText(find.byType(TextField), '6291001');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(scanned, ['6291001']);
  });

  testWidgets('a Tab or CR suffix arriving inside the text submits the code', (tester) async {
    await pump(tester);
    await tester.enterText(find.byType(TextField), '6291002\t');
    await tester.pump();
    await tester.enterText(find.byType(TextField), '6291003\r');
    await tester.pump();
    expect(scanned, ['6291002', '6291003']);
    expect(controller.text, isEmpty);
  });

  testWidgets('typing after clicking elsewhere still lands in the box', (tester) async {
    await pump(tester);
    focus.unfocus();
    await tester.pump();
    expect(focus.hasFocus, isFalse);
    await tester.sendKeyEvent(LogicalKeyboardKey.digit7);
    await tester.pump();
    expect(focus.hasFocus, isTrue);
    expect(controller.text, '7');
  });
}
