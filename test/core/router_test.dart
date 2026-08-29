import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aura/core/router/app_router.dart';

void main() {
  late SharedPreferences prefs;
  late OnboardingGateNotifier gateNotifier;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    gateNotifier = OnboardingGateNotifier(prefs);
  });

  tearDown(() => gateNotifier.dispose());

  group('OnboardingGateNotifier', () {
    test('defaults to false when no pref is set', () {
      expect(gateNotifier.isComplete, false);
    });

    test('defaults to true when ONBOARDING_COMPLETED is already true', () async {
      SharedPreferences.setMockInitialValues({'ONBOARDING_COMPLETED': true});
      final prefs2 = await SharedPreferences.getInstance();
      final notifier = OnboardingGateNotifier(prefs2);
      expect(notifier.isComplete, true);
      notifier.dispose();
    });

    test('complete() sets isComplete to true and persists', () async {
      await gateNotifier.complete();
      expect(gateNotifier.isComplete, true);
      expect(prefs.getBool('ONBOARDING_COMPLETED'), true);
    });

    test('reset() sets isComplete to false and removes pref', () async {
      await gateNotifier.complete();
      await gateNotifier.reset();
      expect(gateNotifier.isComplete, false);
      expect(prefs.getBool('ONBOARDING_COMPLETED'), isNull);
    });

    test('notifies listeners on complete', () async {
      int notifications = 0;
      gateNotifier.addListener(() => notifications++);
      await gateNotifier.complete();
      expect(notifications, 1);
    });

    test('notifies listeners on reset', () async {
      await gateNotifier.complete();
      int notifications = 0;
      gateNotifier.addListener(() => notifications++);
      await gateNotifier.reset();
      expect(notifications, 1);
    });
  });

  group('GoRouter — Onboarding Gate Redirects', () {
    testWidgets('un-gated /capture-overlay is accessible before onboarding',
        (tester) async {
      final router = buildAppRouter(gateNotifier);
      addTearDown(router.dispose);
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      router.go(Routes.captureOverlay);
      await tester.pumpAndSettle();
      expect(find.text('Voice Capture Overlay'), findsOneWidget);
    });

    testWidgets('un-gated /share is accessible before onboarding',
        (tester) async {
      final router = buildAppRouter(gateNotifier);
      addTearDown(router.dispose);
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      router.go(Routes.share);
      await tester.pumpAndSettle();
      expect(find.text('Share Receiver'), findsOneWidget);
    });

    testWidgets('gated / redirects to /onboarding before completion',
        (tester) async {
      final router = buildAppRouter(gateNotifier);
      addTearDown(router.dispose);
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Onboarding'), findsOneWidget);
    });

    testWidgets('gated / is accessible after onboarding completes',
        (tester) async {
      SharedPreferences.setMockInitialValues({'ONBOARDING_COMPLETED': true});
      final p2 = await SharedPreferences.getInstance();
      final notifier = OnboardingGateNotifier(p2);
      addTearDown(notifier.dispose);
      final router = buildAppRouter(notifier);
      addTearDown(router.dispose);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('/onboarding redirects to / when already completed',
        (tester) async {
      SharedPreferences.setMockInitialValues({'ONBOARDING_COMPLETED': true});
      final p2 = await SharedPreferences.getInstance();
      final notifier = OnboardingGateNotifier(p2);
      addTearDown(notifier.dispose);
      final router = buildAppRouter(notifier);
      addTearDown(router.dispose);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      router.go(Routes.onboarding);
      await tester.pumpAndSettle();
      expect(find.text('Home'), findsOneWidget);
    });
  });
}
