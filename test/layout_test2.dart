import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Test colored box', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: Row(
            children: [
              Container(
                color: Colors.yellow, // This creates _RenderColoredBox
                width: double.infinity, // This creates RenderConstrainedBox
                child: SizedBox(), // Dummy child
              )
            ]
          )
        )
      )
    ));
    expect(tester.takeException(), isNotNull);
  });
}
