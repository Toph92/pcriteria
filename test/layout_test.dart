import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Test layout', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Row(
          children: [
            const SizedBox(
              width: double.infinity, // This will throw an error
              child: const Text("Hello"),
            )
          ]
        )
      )
    ));
    expect(tester.takeException(), isNotNull);
  });
}
