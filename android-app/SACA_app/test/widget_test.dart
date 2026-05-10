import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saca_app/main.dart';

void main() {
  testWidgets('SACA app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SacaApp());
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
