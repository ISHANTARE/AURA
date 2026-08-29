import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aura/core/providers/database_provider.dart';
import 'package:aura/core/router/app_router.dart';
import 'package:aura/database/app_database.dart';
import 'package:aura/main.dart';

void main() {
  testWidgets('AuraApp boots with OnboardingScreen or Home', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({'ONBOARDING_COMPLETED': true});
    final prefs = await SharedPreferences.getInstance();
    final gateNotifier = OnboardingGateNotifier(prefs);
    final db = AppDatabase();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          onboardingGateProvider.overrideWithValue(gateNotifier),
        ],
        child: AuraApp(
          gateNotifier: gateNotifier,
          initialAccent: 'Indigo',
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(AuraApp), findsOneWidget);
    db.close();
  });
}
