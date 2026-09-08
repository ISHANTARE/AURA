import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/router/app_router.dart';
import 'core/providers/clock_providers.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'platform/overlay_channel.dart';
import 'features/capture/domain/services/offline_queue_processor.dart';
import 'features/home/presentation/providers/home_providers.dart';
import 'features/reminders/data/services/dnd_service.dart';
import 'features/reminders/data/services/notification_service.dart';
import 'features/reminders/domain/entities/reminder_models.dart';
import 'features/reminders/domain/services/reminder_scheduling_service.dart';

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
      router.push('/capture-overlay');
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // If running inside the pre-warmed background capture engine,
      // skip heavy main-app sweeps to prevent duplicate DB contention.
      final initialRoute = WidgetsBinding.instance.platformDispatcher.defaultRouteName;
      if (initialRoute == '/capture-overlay') {
        return;
      }

      // Start DND service
      ref.read(dndServiceProvider);

      // Start the offline capture queue processor (drains when back online)
      ref.read(offlineQueueProcessorProvider);

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
      final initialRoute = WidgetsBinding.instance.platformDispatcher.defaultRouteName;
      if (initialRoute == '/capture-overlay') {
        return;
      }
      // Roll "today" windows over if we were suspended across midnight.
      _notifyDayRefresh();
      _onAppActive();
    }
  }

  Future<void> _onAppActive() async {
    // Each startup job runs isolated: one failing step must never starve the
    // remaining ones (a thrown exact-alarm exception used to kill them all).
    // Process any actions triggered in background notifications first.
    await _guarded('background-actions', _processPendingBackgroundActions);

    // Concurrently evaluate independent startup background tasks to prevent
    // sequential blocking jank on app resume.
    await Future.wait([
      _guarded('briefing-scheduler',
          () => ref.read(briefingSchedulerProvider).onAppActive()),
      _guarded('recurring-reset',
          () => ref.read(recurringTaskResetProvider).execute()),
      _guarded(
          'nudges', () => ref.read(nudgeEngineProvider).evaluateAndNudge()),
      _guarded('overdue-check',
          () => ref.read(overdueReminderUseCaseProvider).execute()),
    ]);

    // Heal DB ↔ OS schedule drift (fired marks, recurring advances, reboot
    // recovery). Cheap when everything is already in sync.
    await _guarded(
      'schedule-resync',
      () => ref.read(reminderSchedulingServiceProvider).resynchronizeAll(),
    );
  }

  Future<void> _guarded(String label, Future<void> Function() step) async {
    try {
      await step();
    } catch (e, st) {
      debugPrint('_onAppActive[$label] failed: $e\n$st');
    }
  }

  void _notifyDayRefresh() {
    try {
      ref.read(dayRefreshProvider.notifier).notifyResumed();
    } catch (e) {
      debugPrint('day refresh failed: $e');
    }
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
      final rawItemId = payload.startsWith('item:') ? payload.substring(5) : payload;
      final itemId = rawItemId.trim();

      // Validate ID format: safe alphanumeric / UUID format (no SQL injection or arbitrary chars)
      final idPattern = RegExp(r'^[a-zA-Z0-9_\-]{1,64}$');
      if (!idPattern.hasMatch(itemId)) {
        debugPrint('Discarding invalid pending background action item ID: $itemId');
        return;
      }

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

  /// Unified notification tap grammar:
  ///   route:<location> | item:<itemId> | alarm:<alarmId>
  /// Legacy bare UUID payloads (pre-codec schedules) are tolerated as items.
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
      router.push(Routes.taskRoute(payload.substring(5)));
    } else if (payload.startsWith('alarm:')) {
      // Alarms are Items — open their detail view.
      router.push(Routes.taskRoute(payload.substring(6)));
    } else {
      // Legacy bare-id payload from an old schedule.
      router.push(Routes.taskRoute(payload));
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final accent = ref.watch(themeAccentProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'AURA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(accent.color),
      darkTheme: AppTheme.dark(accent.color),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
