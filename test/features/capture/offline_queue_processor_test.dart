import 'dart:convert';

import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:aura/core/services/notification_service.dart';
import 'package:aura/database/app_database.dart';
import 'package:aura/features/capture/domain/execute_ai_action_usecase.dart';
import 'package:aura/features/capture/domain/extracted_intent.dart';
import 'package:aura/features/capture/services/offline_queue_processor.dart';
import 'package:aura/features/reminders/services/reminder_scheduling_service.dart';

class _FakeNotificationService extends Fake implements NotificationService {
  @override
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    required String channelId,
    String? payload,
    bool fullScreenIntent = false,
  }) async {}

  @override
  Future<void> cancel(int id) async {}
}

void main() {
  late AppDatabase db;
  late _FakeNotificationService fakeNotificationService;
  late ReminderSchedulingService schedulingService;
  late ExecuteAiActionUseCase executeUseCase;
  late OfflineQueueProcessor queueProcessor;

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
    executeUseCase = ExecuteAiActionUseCase(
      db: db,
      itemDao: db.itemDao,
      workspaceDao: db.workspaceDao,
      schedulingService: schedulingService,
    );
    queueProcessor = OfflineQueueProcessor(
      offlineQueueDao: db.offlineQueueDao,
      executeAiActionUseCase: executeUseCase,
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('OfflineQueueProcessor Unit Tests', () {
    test('drains transcript items and executes them when online', () async {
      final nowMs = DateTime.now().millisecondsSinceEpoch;

      await db.offlineQueueDao.enqueue(
        OfflineQueuesCompanion.insert(
          id: 'q-transcript-1',
          type: const Value('transcript'),
          content: 'set an alarm for 7:30 am',
          createdAt: nowMs,
        ),
      );

      final processedCount = await queueProcessor.drainQueue();
      expect(processedCount, 1);

      // Verify item was created in db
      final items = await db.itemDao.watchAllActive().first;
      expect(items.length, 1);
      expect(items.first.category, 'alarm');

      // Verify queue is empty of pending items
      final pending = await db.offlineQueueDao.getPendingItems();
      expect(pending.isEmpty, true);
    });

    test('drains action JSON payload items', () async {
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      const intent = ExtractedIntent(
        intentType: 'create_task',
        title: 'Submit Lab Report',
        priority: 'high',
      );

      await db.offlineQueueDao.enqueue(
        OfflineQueuesCompanion.insert(
          id: 'q-action-1',
          type: const Value('action'),
          content: jsonEncode(intent.toJson()),
          createdAt: nowMs,
        ),
      );

      final processedCount = await queueProcessor.drainQueue();
      expect(processedCount, 1);

      final items = await db.itemDao.watchAllActive().first;
      expect(items.length, 1);
      expect(items.first.title, 'Submit Lab Report');
    });

    test('skips destructive delete actions when requireReviewForDestructive is true', () async {
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      const intent = ExtractedIntent(
        intentType: 'delete_task',
        targetName: 'Old Task',
      );

      await db.offlineQueueDao.enqueue(
        OfflineQueuesCompanion.insert(
          id: 'q-destructive-1',
          type: const Value('action'),
          content: jsonEncode(intent.toJson()),
          createdAt: nowMs,
        ),
      );

      final processedCount = await queueProcessor.drainQueue(requireReviewForDestructive: true);
      expect(processedCount, 0);

      // Still pending for user confirmation
      final pending = await db.offlineQueueDao.getPendingItems();
      expect(pending.length, 1);
    });
  });
}
