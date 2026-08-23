import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:aura/database/app_database.dart';
import 'package:aura/features/capture/domain/entities/intent_result.dart';
import 'package:aura/features/reminders/data/services/notification_service.dart';
import 'package:aura/features/reminders/domain/services/reminder_scheduling_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late ItemDao itemDao;
  late WorkspaceDao workspaceDao;
  late NotificationService notifications;
  final recordedCalls = <String>[];

  setUpAll(() {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('UTC'));

    const channel = MethodChannel('dexterous.com/flutter/local_notifications');
    TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      recordedCalls.add(call.method);
      return null;
    });
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    recordedCalls.clear();
    db = AppDatabase.forTesting(NativeDatabase.memory());
    itemDao = ItemDao(db);
    workspaceDao = WorkspaceDao(db);
    notifications = NotificationService();
    // Skip the real exact-alarm permission probe (platform channel).
    notifications.canScheduleExactAlarmsProbe = () async => true;

    final nowMs = DateTime.now().millisecondsSinceEpoch;
    await workspaceDao.insertWorkspace(
      WorkspacesCompanion.insert(
        id: 'ws-general',
        name: 'General',
        colorHex: const Value('#3B82F6'),
        createdAt: nowMs,
        updatedAt: nowMs,
      ),
    );
  });

  tearDown(() async {
    await db.close();
  });

  Future<Item> insertTimedItem({
    required String id,
    required DateTime when,
    bool alarm = false,
  }) async {
    final nowEpoch = DateTime.now().millisecondsSinceEpoch;
    await itemDao.insertItem(
      ItemsCompanion.insert(
        id: id,
        title: 'Test $id',
        workspaceId: const Value('ws-general'),
        category: alarm ? 'alarm' : 'reminder',
        kind: alarm ? 'alarm' : 'task',
        deadline: Value(when.millisecondsSinceEpoch),
        createdAt: nowEpoch,
        updatedAt: nowEpoch,
      ),
    );
    return (await itemDao.getById(id))!;
  }

  group('ReminderSchedulingService.syncForItem', () {
    test('persists extracted offsets + anchor row, schedules and logs them',
        () async {
      final item = await insertTimedItem(
        id: 't-1',
        when: DateTime.now().add(const Duration(hours: 5)),
      );

      final service =
          ReminderSchedulingService(db: db, notifications: notifications);
      final outcome = await service.syncForItem(item, extractedReminders: [
        const ExtractedReminder(
            offsetValue: 30, offsetUnit: 'minutes', type: 'notification'),
      ]);

      final rows = await itemDao.getRemindersForItem('t-1');
      expect(rows.length, 2, reason: 'one offset row + one anchor row');

      expect(outcome.scheduledCount, 2);
      expect(outcome.usedInexactFallback, isFalse);

      final logs = await db.select(db.notificationLogs).get();
      expect(logs.length, 2);

      // The OS received exactly two zonedSchedule calls.
      final scheduledCount =
          recordedCalls.where((m) => m == 'zonedSchedule').length;
      expect(scheduledCount, 2);
    });

    test('stale deadlines beyond the grace window are skipped, not fired',
        () async {
      final item = await insertTimedItem(
        id: 't-old',
        when: DateTime.now().subtract(const Duration(hours: 6)),
      );

      final service =
          ReminderSchedulingService(db: db, notifications: notifications);
      final outcome = await service.syncForItem(item);

      expect(outcome.scheduledCount, 0);
      expect(outcome.warnings, isNotEmpty);
      expect(recordedCalls.contains('zonedSchedule'), isFalse);
    });

    test('re-syncing replaces old rows instead of stacking duplicates',
        () async {
      final item = await insertTimedItem(
        id: 't-2',
        when: DateTime.now().add(const Duration(hours: 3)),
      );

      final service =
          ReminderSchedulingService(db: db, notifications: notifications);
      await service.syncForItem(item);
      await service.syncForItem(item);
      await service.syncForItem(item);

      final rows = await itemDao.getRemindersForItem('t-2');
      expect(rows.length, 1, reason: 'anchor row replaced, not duplicated');

      final logs = await db.select(db.notificationLogs).get();
      expect(logs.length, 1);
    });

    test('recurring weekday alarms persist one virtual row per weekday',
        () async {
      final nowEpoch = DateTime.now().millisecondsSinceEpoch;
      await itemDao.insertItem(
        ItemsCompanion.insert(
          id: 'a-weekly',
          title: 'Weekday Alarm',
          workspaceId: const Value('ws-general'),
          category: 'alarm',
          kind: 'alarm',
          fireAt: Value(nowEpoch),
          isRecurring: const Value(true),
          recurrenceRule: const Value('DAYS:1,3,5'),
          createdAt: nowEpoch,
          updatedAt: nowEpoch,
        ),
      );
      final item = (await itemDao.getById('a-weekly'))!;

      final service =
          ReminderSchedulingService(db: db, notifications: notifications);
      final outcome = await service.syncForItem(item);

      final rows = await itemDao.getRemindersForItem('a-weekly');
      expect(rows.length, 3, reason: 'Mon/Wed/Fri placeholders');
      expect(outcome.scheduledCount, 3);
    });
  });

  group('ReminderSchedulingService.cancelForItem', () {
    test('cancels every derivable ID variant', () async {
      final service =
          ReminderSchedulingService(db: db, notifications: notifications);
      await service.cancelForItem('some-item');

      final cancels = recordedCalls.where((m) => m == 'cancel').length;
      // rows(0 known at this point) + primary + 7 weekdays + snooze = 9+
      expect(cancels, greaterThanOrEqualTo(8));
    });

    test('deleted tasks stop having notifications (dispatcher path)', () async {
      final item = await insertTimedItem(
        id: 't-del',
        when: DateTime.now().add(const Duration(hours: 2)),
      );
      final service =
          ReminderSchedulingService(db: db, notifications: notifications);
      await service.syncForItem(item);
      final scheduledBefore =
          recordedCalls.where((m) => m == 'zonedSchedule').length;
      expect(scheduledBefore, greaterThanOrEqualTo(1));

      recordedCalls.clear();
      await service.cancelForItem('t-del');
      expect(recordedCalls.contains('cancel'), isTrue);
    });
  });

  group('ReminderSchedulingService.snooze', () {
    test('moves the DB fireAt AND reschedules the notification', () async {
      final originalTime = DateTime.now().add(const Duration(hours: 1));
      final item = await insertTimedItem(id: 't-snooze', when: originalTime);

      final service =
          ReminderSchedulingService(db: db, notifications: notifications);
      await service.syncForItem(item);

      recordedCalls.clear();
      final target = DateTime.now().add(const Duration(hours: 3));
      final outcome = await service.snooze(item: item, target: target);

      expect(outcome.scheduledCount, 1);

      // DB synced — overdue stats no longer count the original time.
      final updated = await itemDao.getById('t-snooze');
      expect(updated!.fireAt, target.millisecondsSinceEpoch);

      // Exactly one new OS schedule was placed after cancelling.
      expect(recordedCalls.contains('cancel'), isTrue);
      expect(recordedCalls.where((m) => m == 'zonedSchedule').length, 1);
    });
  });

  group('ReminderSchedulingService.resynchronizeAll', () {
    test('marks fired occurrences and advances recurring items', () async {
      final pastAnchor = DateTime.now().subtract(const Duration(days: 1));
      final nowEpoch = DateTime.now().millisecondsSinceEpoch;
      await itemDao.insertItem(
        ItemsCompanion.insert(
          id: 'r-daily',
          title: 'Daily Recurring',
          workspaceId: const Value('ws-general'),
          category: 'reminder',
          kind: 'task',
          deadline: Value(pastAnchor.millisecondsSinceEpoch),
          isRecurring: const Value(true),
          recurrenceRule: const Value('daily'),
          createdAt: nowEpoch,
          updatedAt: nowEpoch,
        ),
      );

      final service =
          ReminderSchedulingService(db: db, notifications: notifications);

      // First sync persists the occurrence row + its log (stale-skipped).
      await service.syncForItem((await itemDao.getById('r-daily'))!);

      // Sweep marks the past occurrence fired and advances it a day.
      await service.resynchronizeAll(reason: 'test');

      final rows = await itemDao.getRemindersForItem('r-daily');
      expect(rows, isNotEmpty);
      final row = rows.first;
      expect(row.fireAt,
          greaterThan(DateTime.now().millisecondsSinceEpoch),
          reason: 'recurring occurrence must advance to the next slot');

      // The fired occurrence got its log stamped.
      final stampedLogs = await (db.select(db.notificationLogs)
            ..where((n) => n.firedAt.isNotNull()))
          .get();
      expect(stampedLogs.length, greaterThanOrEqualTo(1));
    });
  });
}
