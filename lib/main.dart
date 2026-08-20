import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // If .env is missing, app runs using fallback or defaults
  }

  // Initialize local notifications (channels + timezone)
  final notificationService = NotificationService();
  await notificationService.initialize();
  await notificationService.requestPermissions();

  runApp(
    // ProviderScope is the root of Riverpod state management
    const ProviderScope(
      child: AuraApp(),
    ),
  );
}
