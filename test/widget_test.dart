import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aura/app.dart';

void main() {
  testWidgets('AuraApp launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: AuraApp(),
      ),
    );
    expect(find.byType(AuraApp), findsOneWidget);
  });
}
