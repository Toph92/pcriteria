import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Test min row with expanded', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: Container(
                      color: Colors.yellow,
                      child: Text("Hello"),
                    ),
                  )
                ]
              )
            ]
          )
        )
      )
    ));
    // If it pumps without error, the layout is valid.
    expect(tester.takeException(), isNull);
  });
}
