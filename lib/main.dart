import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/security/secret_store.dart';
import 'core/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file (dev convenience only;
  // production builds carry no .env and use defaults / user settings).
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // If .env is missing, app runs using fallback or defaults
  }

  // Migrate any legacy plaintext API key into encrypted storage.
  await SecretStore().migrateLegacyKey();

  // Initialize local notifications (channels + timezone)
  final notificationService = NotificationService();
  await notificationService.initialize();
  try {
    await notificationService.requestPermissions();
  } catch (e) {
    debugPrint('Notification permissions deferred: $e');
  }

  runApp(
    // ProviderScope is the root of Riverpod state management
    const ProviderScope(
      child: AuraApp(),
    ),
  );
}
