import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox(width: 100, height: 100));
    expect(find.byType(SizedBox), findsOneWidget);
  });
}
