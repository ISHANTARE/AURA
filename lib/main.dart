import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/providers/database_provider.dart';
import 'core/router/app_router.dart';
import 'core/services/notification_service.dart';
import 'database/app_database.dart';
import 'features/settings/settings_screen.dart' show SettingsKeys;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize local notification channels & timezones
  final notifService = NotificationService();
  await notifService.initialize();

  // 2. Initialize SharedPreferences & Onboarding Gate
  final prefs = await SharedPreferences.getInstance();
  final gateNotifier = OnboardingGateNotifier(prefs);
  final database = AppDatabase();

  final savedAccent = prefs.getString(SettingsKeys.themeAccent) ?? 'Indigo';

  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(database),
        onboardingGateProvider.overrideWithValue(gateNotifier),
      ],
      child: AuraApp(
        gateNotifier: gateNotifier,
        initialAccent: savedAccent,
      ),
    ),
  );
}
