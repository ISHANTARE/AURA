import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aura/core/services/notification_ids.dart';
import 'package:aura/core/services/notification_service.dart';
import 'package:aura/database/app_database.dart';
import 'package:aura/features/reminders/services/dnd_service.dart';

class _FakeNotificationService extends Fake implements NotificationService {
  final List<int> immediateIds = [];
  final List<String> bodies = [];

  @override
  Future<void> showImmediate({
    required int id,
    required String title,
    required String body,
    String channelId = NotificationService.remindersChannelId,
    String? payload,
  }) async {
    immediateIds.add(id);
    bodies.add(body);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late _FakeNotificationService fakeNotificationService;
  late ReplayDndNotificationsUseCase replayUseCase;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    fakeNotificationService = _FakeNotificationService();
    replayUseCase = ReplayDndNotificationsUseCase(
      notificationDao: db.notificationDao,
      notificationService: fakeNotificationService,
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('ReplayDndNotificationsUseCase Tests', () {
    test('replays single missed notification with individual alert', () async {
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      const itemId = 'item-single-dnd';
      const reminderId = 'rem-single-dnd';
      const logId = 'log-single-dnd';

      await db.itemDao.insertItem(
        ItemsCompanion.insert(
          id: itemId,
          title: 'Study Session',
          createdAt: nowMs,
          updatedAt: nowMs,
        ),
      );

      await db.into(db.remindersSchedule).insert(
            RemindersScheduleCompanion.insert(
              id: reminderId,
              itemId: itemId,
              offsetValue: 0,
              offsetUnit: 'minutes',
              fireAt: nowMs - 600000,
            ),
          );

      await db.notificationDao.insertLog(
        NotificationLogsCompanion.insert(
          id: logId,
          reminderId: reminderId,
          scheduledAt: nowMs - 600000, // 10 minutes ago
          wasDnd: const drift.Value(true),
          createdAt: nowMs - 600000,
        ),
      );

      await replayUseCase.execute();

      expect(fakeNotificationService.immediateIds.length, 1);
      expect(fakeNotificationService.immediateIds.first, NotificationIds.dndCatchup);
      expect(fakeNotificationService.bodies.first.contains('10m ago'), true);

      final unreplayed = await db.notificationDao.getUnreplayed();
      expect(unreplayed.isEmpty, true);
    });

    test('replays multiple missed notifications with summary catchup notification', () async {
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      const itemId = 'item-multi-dnd';
      const remId1 = 'rem-multi-1';
      const remId2 = 'rem-multi-2';

      await db.itemDao.insertItem(
        ItemsCompanion.insert(
          id: itemId,
          title: 'Deep Work Tasks',
          createdAt: nowMs,
          updatedAt: nowMs,
        ),
      );

      await db.into(db.remindersSchedule).insert(
            RemindersScheduleCompanion.insert(
              id: remId1,
              itemId: itemId,
              offsetValue: 0,
              offsetUnit: 'minutes',
              fireAt: nowMs - 1200000,
            ),
          );

      await db.into(db.remindersSchedule).insert(
            RemindersScheduleCompanion.insert(
              id: remId2,
              itemId: itemId,
              offsetValue: 0,
              offsetUnit: 'minutes',
              fireAt: nowMs - 600000,
            ),
          );

      await db.notificationDao.insertLog(
        NotificationLogsCompanion.insert(
          id: 'log-multi-1',
          reminderId: remId1,
          scheduledAt: nowMs - 1200000,
          wasDnd: const drift.Value(true),
          createdAt: nowMs - 1200000,
        ),
      );

      await db.notificationDao.insertLog(
        NotificationLogsCompanion.insert(
          id: 'log-multi-2',
          reminderId: remId2,
          scheduledAt: nowMs - 600000,
          wasDnd: const drift.Value(true),
          createdAt: nowMs - 600000,
        ),
      );

      await replayUseCase.execute();

      expect(fakeNotificationService.immediateIds.length, 1);
      expect(fakeNotificationService.immediateIds.first, NotificationIds.dndCatchup);
      expect(fakeNotificationService.bodies.first.contains('2 reminders'), true);

      final unreplayed = await db.notificationDao.getUnreplayed();
      expect(unreplayed.isEmpty, true);
    });

    test('does nothing when no unreplayed DND logs exist', () async {
      await replayUseCase.execute();
      expect(fakeNotificationService.immediateIds.isEmpty, true);
    });
  });
}
