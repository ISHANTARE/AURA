import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'platform/overlay_channel.dart';
import 'features/home/presentation/providers/home_providers.dart';
import 'features/reminders/data/services/dnd_service.dart';
import 'features/reminders/data/services/notification_service.dart';
import 'features/reminders/domain/entities/reminder_models.dart';

/// Root application widget.
/// Consumes the router and theme — both Riverpod-aware.
class AuraApp extends ConsumerStatefulWidget {
  const AuraApp({super.key});

  @override
  ConsumerState<AuraApp> createState() => _AuraAppState();
}

class _AuraAppState extends ConsumerState<AuraApp> with WidgetsBindingObserver {
  StreamSubscription<String?>? _notificationSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Listen for notification taps for deep linking
    _notificationSub = NotificationService()
        .selectNotificationStream
        .listen(_onNotificationTapPayload);

    // Listen for global floating orb taps from native system overlay
    OverlayChannel.listenToOrbTaps(() {
      final router = ref.read(appRouterProvider);
      router.push(Routes.home);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Start DND service
      ref.read(dndServiceProvider);

      // Auto-start system-level floating orb if permission is granted
      OverlayChannel.autoStartIfPermitted();

      // Run nudge & overdue evaluation
      _onAppActive();
    });
  }

  @override
  void dispose() {
    _notificationSub?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _onAppActive();
    }
  }

  Future<void> _onAppActive() async {
    // 1. Process any pending background actions from SharedPreferences
    await _processPendingBackgroundActions();

    // 2. Schedule (or re-confirm) today's morning briefing notification
    await ref.read(briefingSchedulerProvider).onAppActive();

    // 3. Recurring task daily reset (once per calendar day)
    await ref.read(recurringTaskResetProvider).execute();

    // 4. Evaluate proactive nudges
    await ref.read(nudgeEngineProvider).evaluateAndNudge();

    // 5. Evaluate overdue items notification (1/day max)
    await ref.read(overdueReminderUseCaseProvider).execute();
  }

  Future<void> _processPendingBackgroundActions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pendingAction = prefs.getString('pending_bg_action');
      if (pendingAction == null || pendingAction.isEmpty) return;

      await prefs.remove('pending_bg_action');
      final parts = pendingAction.split(':');
      if (parts.length < 2) return;

      final action = parts[0];
      final payload = parts.sublist(1).join(':');
      final itemId = payload.replaceAll('item:', '');

      final itemDao = ref.read(itemDaoProvider);
      final snoozeUseCase = ref.read(snoozeReminderUseCaseProvider);

      if (action == 'MARK_DONE') {
        await itemDao.updateStatus(itemId, 'completed');
      } else if (action == 'SNOOZE_30M') {
        final item = await itemDao.getById(itemId);
        if (item != null) {
          await snoozeUseCase.execute(
            reminderId: itemId,
            taskTitle: item.title,
            taskId: itemId,
            preset: SnoozePreset.minutes30,
          );
        }
      }
    } catch (_) {}
  }

  void _onNotificationTapPayload(String? payload) {
    if (payload == null || payload.isEmpty) return;

    final router = ref.read(appRouterProvider);

    if (payload.startsWith('route:')) {
      final route = payload.substring(6);
      if (route == '/briefing') {
        router.go(Routes.briefing);
      } else {
        router.push(route);
      }
    } else if (payload.startsWith('item:')) {
      final itemId = payload.substring(5);
      router.push(Routes.taskRoute(itemId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final accent = ref.watch(themeAccentProvider);

    return MaterialApp.router(
      title: 'AURA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(accent.color),
      darkTheme: AppTheme.dark(accent.color),
      themeMode: ThemeMode.dark,
      routerConfig: router,
    );
  }
}
