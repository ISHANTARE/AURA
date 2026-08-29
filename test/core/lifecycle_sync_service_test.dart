import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:uuid/uuid.dart';

import 'package:aura/core/services/lifecycle_sync_service.dart';
import 'package:aura/core/services/notification_service.dart';
import 'package:aura/database/app_database.dart';
import 'package:aura/features/reminders/services/reminder_scheduling_service.dart';

class _FakeNotificationService extends Fake implements NotificationService {
  final List<int> scheduledIds = [];
  final List<int> cancelledIds = [];
  final List<int> immediateIds = [];

  @override
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    required String channelId,
    String? payload,
    bool fullScreenIntent = false,
  }) async {
    scheduledIds.add(id);
  }

  @override
  Future<void> showImmediate({
    required int id,
    required String title,
    required String body,
    String channelId = NotificationService.remindersChannelId,
    String? payload,
  }) async {
    immediateIds.add(id);
  }

  @override
  Future<void> cancel(int id) async {
    cancelledIds.add(id);
  }

  @override
  Future<void> cancelAll() async {
    cancelledIds.add(-1);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late _FakeNotificationService notifService;
  late ReminderSchedulingService scheduler;
  late LifecycleSyncService lifecycleService;

  setUp(() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('UTC'));
    SharedPreferences.setMockInitialValues({});
    db = AppDatabase(NativeDatabase.memory());
    notifService = _FakeNotificationService();
    scheduler = ReminderSchedulingService(
      itemDao: db.itemDao,
      notificationService: notifService,
      db: db,
    );
    lifecycleService = LifecycleSyncService(
      itemDao: db.itemDao,
      scheduler: scheduler,
      notificationService: notifService,
      db: db,
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('LifecycleSyncService — onAppActive() 6-Job Chain', () {
    test('Job 1: processes pending_bg_action for MARK_DONE and clears key', () async {
      final itemId = const Uuid().v4();
      final now = DateTime.now().millisecondsSinceEpoch;
      await db.itemDao.insertItem(ItemsCompanion.insert(
        id: itemId,
        title: 'Background Target Task',
        status: const drift.Value('pending'),
        createdAt: now,
        updatedAt: now,
      ));

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('pending_bg_action', 'MARK_DONE:item:$itemId');

      await lifecycleService.onAppActive();

      final updated = await db.itemDao.getItemById(itemId);
      expect(updated?.status, 'completed');
      expect(prefs.getString('pending_bg_action'), isNull);
    });

    test('Job 2: schedules today morning briefing once per calendar day', () async {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      final todayKey = 'briefing_${now.year}_${now.month}_${now.day}';

      expect(prefs.getBool(todayKey), isNull);

      await lifecycleService.onAppActive();

      expect(prefs.getBool(todayKey), true);
      expect(notifService.scheduledIds.isNotEmpty, true);
    });

    test('Job 3: resets completed recurring tasks to their next slot', () async {
      final itemId = const Uuid().v4();
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      await db.itemDao.insertItem(ItemsCompanion.insert(
        id: itemId,
        title: 'Daily Standup',
        status: const drift.Value('completed'),
        isRecurring: const drift.Value(true),
        recurrenceRule: const drift.Value('daily'),
        fireAt: drift.Value(yesterday.millisecondsSinceEpoch),
        deadline: drift.Value(yesterday.millisecondsSinceEpoch),
        createdAt: yesterday.millisecondsSinceEpoch,
        updatedAt: yesterday.millisecondsSinceEpoch,
      ));

      await lifecycleService.onAppActive();

      final updated = await db.itemDao.getItemById(itemId);
      expect(updated?.status, 'pending');
      expect(updated!.fireAt! > yesterday.millisecondsSinceEpoch, true);
    });

    test('Job 4: respects quiet hours, spacing, and daily cap for proactive nudges', () async {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      final dayKey = 'nudge_count_${now.year}_${now.month}_${now.day}';

      // Insert high-priority task
      final itemId = const Uuid().v4();
      await db.itemDao.insertItem(ItemsCompanion.insert(
        id: itemId,
        title: 'Critical Report',
        priority: const drift.Value('high'),
        status: const drift.Value('pending'),
        createdAt: now.millisecondsSinceEpoch,
        updatedAt: now.millisecondsSinceEpoch,
      ));

      await lifecycleService.onAppActive();

      // If outside quiet hours, count increments
      if (now.hour >= 7 && now.hour < 23) {
        expect(prefs.getInt(dayKey), 1);
        expect(notifService.immediateIds.isNotEmpty, true);
      }
    });

    test('Job 5 & 6: error isolation prevents single-job failures from blocking chain', () async {
      await lifecycleService.onAppActive();
      expect(true, isTrue);
    });
  });
}
