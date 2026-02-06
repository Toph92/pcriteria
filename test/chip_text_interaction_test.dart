import 'package:criteria/criteria.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ChipText updates displayed status on input', (
    WidgetTester tester,
  ) async {
    final controller = ChipTextController(
      name: 'test',
      group: ChipGroup.none(),
      label: 'Test',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ChipText(controller: controller)),
      ),
    );

    // Initially displayed is false because it defaults to false and no text.
    expect(controller.displayed, isFalse);
    expect(controller.value, isNull);

    // Tap to enter edit mode (text 'Test ?' is shown when empty)
    await tester.tap(find.text('Test ?'));
    await tester.pump();

    // Find TextField
    final textField = find.byType(TextField);
    expect(textField, findsOneWidget);

    // Enter text
    await tester.enterText(textField, 'Hello');
    await tester.pump();

    // Verify displayed is true and value is set
    expect(controller.displayed, isTrue);
    expect(controller.value, 'Hello');

    // Clear text
    await tester.enterText(textField, '');
    await tester.pump();

    // Verify displayed is false and value is null (or empty if logic allows, but here null)
    expect(controller.displayed, isFalse);
    expect(controller.value, isNull);
  });
}
