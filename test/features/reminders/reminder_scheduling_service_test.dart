import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

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
  late AppDatabase db;
  late _FakeNotificationService fakeNotificationService;
  late ReminderSchedulingService schedulingService;

  setUp(() {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('UTC'));

    db = AppDatabase(NativeDatabase.memory());
    fakeNotificationService = _FakeNotificationService();
    schedulingService = ReminderSchedulingService(
      itemDao: db.itemDao,
      notificationService: fakeNotificationService,
      db: db,
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('ReminderSchedulingService Tests', () {
    test('syncForItem schedules future reminder and cancels previous IDs', () async {
      final futureTime = DateTime.now().add(const Duration(hours: 2));
      final futureMs = futureTime.millisecondsSinceEpoch;

      const itemId = 'test-item-sync-1';
      final item = Item(
        id: itemId,
        title: 'Complete Math Homework',
        status: 'pending',
        category: 'reminder',
        kind: 'task',
        priority: 'high',
        isRecurring: false,
        fireAt: futureMs,
        createdAt: futureMs,
        updatedAt: futureMs,
      );

      await schedulingService.syncForItem(item);

      // Should have cancelled previous variant IDs (forItem, forSnooze, 7 weekdays)
      expect(fakeNotificationService.cancelledIds.length, greaterThanOrEqualTo(9));
      // Should have scheduled 1 notification for future reminder
      expect(fakeNotificationService.scheduledIds.length, 1);
    });

    test('syncForItem handles alarm category with fullScreenIntent', () async {
      final futureTime = DateTime.now().add(const Duration(minutes: 30));
      final futureMs = futureTime.millisecondsSinceEpoch;

      const itemId = 'test-alarm-sync-1';
      final item = Item(
        id: itemId,
        title: 'Morning Wakeup',
        status: 'pending',
        category: 'alarm',
        kind: 'task',
        priority: 'high',
        isRecurring: false,
        fireAt: futureMs,
        createdAt: futureMs,
        updatedAt: futureMs,
      );

      await schedulingService.syncForItem(item);
      expect(fakeNotificationService.scheduledIds.length, 1);
    });

    test('cancelForItem cancels all 4 ID variants', () async {
      const itemId = 'cancel-test-id';
      await schedulingService.cancelForItem(itemId);

      // forItem, forSnooze, 7 weekdays = 9 cancellation calls
      expect(fakeNotificationService.cancelledIds.length, 9);
    });

    test('snooze updates fireAt in database and schedules snooze notification', () async {
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      const itemId = 'snooze-test-item';

      await db.itemDao.insertItem(
        ItemsCompanion.insert(
          id: itemId,
          title: 'Team Standup',
          category: const Value('reminder'),
          kind: const Value('task'),
          fireAt: Value(nowMs),
          createdAt: nowMs,
          updatedAt: nowMs,
        ),
      );

      final item = await db.itemDao.getItemById(itemId);
      final snoozeTarget = DateTime.now().add(const Duration(minutes: 30));

      await schedulingService.snooze(item!, snoozeTarget);

      final updated = await db.itemDao.getItemById(itemId);
      expect(updated!.fireAt, snoozeTarget.millisecondsSinceEpoch);
      expect(fakeNotificationService.scheduledIds.length, 1);
    });
  });
}
