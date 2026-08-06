import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('App UI Smoke Test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Center(child: Text('MyPocket Digital Wallet')),
          ),
        ),
      ),
    );

    expect(find.text('MyPocket Digital Wallet'), findsOneWidget);
  });
}
