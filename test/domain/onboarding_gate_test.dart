import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aura/core/router/app_router.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OnboardingGateNotifier', () {
    test('starts locked when onboarding never completed', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(onboardingGateProvider), isFalse);
    });

    test('complete() persists and unlocks', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(onboardingGateProvider.notifier);

      await notifier.complete();

      expect(container.read(onboardingGateProvider), isTrue);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('onboarding_complete'), isTrue);
    });

    test(
        'reset() re-locks the gate and clears persistence — '
        'Reset App Data cannot be bypassed', () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(onboardingGateProvider.notifier);

      // Unlock first (as onboarding completion would).
      await notifier.complete();
      expect(container.read(onboardingGateProvider), isTrue);

      // Then simulate Reset App Data.
      await notifier.reset();

      expect(container.read(onboardingGateProvider), isFalse);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('onboarding_complete'), isNull);
    });

    test('hydrate(true) promotes a locked gate without demoting an open one',
        () async {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(onboardingGateProvider.notifier);

      notifier.hydrate(true);
      expect(container.read(onboardingGateProvider), isTrue);

      // hydrate must never re-lock.
      notifier.hydrate(false);
      expect(container.read(onboardingGateProvider), isTrue);
    });
  });
}
