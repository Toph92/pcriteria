import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Test layout', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Row(
          children: [
            Container(
              width: double.infinity, // This will throw an error
              child: Text("Hello"),
            )
          ]
        )
      )
    ));
    expect(tester.takeException(), isNotNull);
  });
}
