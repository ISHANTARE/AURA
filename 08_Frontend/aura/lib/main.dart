import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';

import 'app.dart';
import 'core/services/notification_service.dart';

/// Background task dispatcher — called by WorkManager in a separate isolate.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case 'recurringReset':
        // Midnight reset for recurring tasks (Sprint 8)
        break;
      case 'morningBriefing':
        // Morning briefing generation (Sprint 8)
        break;
      case 'processOfflineQueue':
        // Process queued offline captures (Sprint 4)
        break;
      case 'nudgeCheck':
        // Proactive nudge evaluation (Sprint 8)
        break;
    }
    return Future.value(true);
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize WorkManager for background tasks
  await Workmanager().initialize(
    callbackDispatcher,
  );

  // Initialize local notifications
  await NotificationService.initialize();

  runApp(
    // ProviderScope is the root of Riverpod state management
    const ProviderScope(
      child: AuraApp(),
    ),
  );
}
