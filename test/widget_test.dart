import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aura/main.dart';

void main() {
  testWidgets('AuraBootstrapApp renders initial brand title', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: AuraBootstrapApp(),
      ),
    );

    expect(find.text('AURA'), findsOneWidget);
  });
}
