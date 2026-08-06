import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mypocket/main.dart';

void main() {
  testWidgets('App initializes cleanly smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );

    // Allow pending timers/animations to settle
    await tester.pump(const Duration(seconds: 3));

    // Verify app renders
    expect(find.byType(MyApp), findsOneWidget);
  });
}
