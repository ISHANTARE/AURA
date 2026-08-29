import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:aura/core/services/notification_service.dart';
import 'package:aura/database/app_database.dart';
import 'package:aura/features/capture/domain/execute_ai_action_usecase.dart';
import 'package:aura/features/capture/domain/extracted_intent.dart';
import 'package:aura/features/reminders/services/reminder_scheduling_service.dart';

class _FakeNotificationService extends Fake implements NotificationService {
  final List<int> scheduledIds = [];
  final List<int> cancelledIds = [];

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
  Future<void> cancel(int id) async {
    cancelledIds.add(id);
  }
}

void main() {
  late AppDatabase db;
  late _FakeNotificationService fakeNotificationService;
  late ReminderSchedulingService schedulingService;
  late ExecuteAiActionUseCase executeUseCase;

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
  });

  tearDown(() async {
    await db.close();
  });

  group('ExecuteAiActionUseCase Tests', () {
    test('create_alarm inserts alarm item, schedules notification, and logs audit trail', () async {
      const intent = ExtractedIntent(
        intentType: 'create_alarm',
        title: 'Alarm 6:30 AM',
        deadlineIso: '2026-08-30T06:30:00',
        confidence: 0.95,
      );

      final msg = await executeUseCase.execute(
        intent: intent,
        rawTranscript: 'set alarm for 6:30 am',
      );

      expect(msg, contains('Set alarm for 6:30 AM'));

      final items = await db.itemDao.watchAllActive().first;
      expect(items.length, 1);
      expect(items.first.category, 'alarm');
      expect(fakeNotificationService.scheduledIds.length, 1);

      // Check audit log
      final logs = await db.select(db.aiActionsLogs).get();
      expect(logs.length, 1);
      expect(logs.first.actionTaken, contains('Set alarm for 6:30 AM'));
      expect(logs.first.inputText, 'set alarm for 6:30 am');
    });

    test('create_workspace creates a new workspace in Drift table', () async {
      const intent = ExtractedIntent(
        intentType: 'create_workspace',
        title: 'Placement Prep',
        workspaceColorHex: '#3B82F6',
        confidence: 0.90,
      );

      final msg = await executeUseCase.execute(
        intent: intent,
        rawTranscript: 'create workspace named Placement Prep',
      );

      expect(msg, 'Created workspace "Placement Prep"');

      final workspaces = await db.workspaceDao.watchAll().first;
      expect(workspaces.length, 1);
      expect(workspaces.first.name, 'Placement Prep');
      expect(workspaces.first.colorHex, '#3B82F6');
    });

    test('delete_task cancels alarms and soft-deletes item', () async {
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      const itemId = 'task-to-delete-1';

      await db.itemDao.insertItem(
        ItemsCompanion.insert(
          id: itemId,
          title: 'Mathematics Homework',
          createdAt: nowMs,
          updatedAt: nowMs,
        ),
      );

      const intent = ExtractedIntent(
        intentType: 'delete_task',
        targetName: 'mathematics homework',
        confidence: 0.85,
      );

      final msg = await executeUseCase.execute(intent: intent);
      expect(msg, 'Deleted task "Mathematics Homework"');

      final active = await db.itemDao.watchAllActive().first;
      expect(active.isEmpty, true);
    });

    test('add_note inserts freeform note in notes table', () async {
      const intent = ExtractedIntent(
        intentType: 'add_note',
        title: 'Project portal closes Friday',
        notes: 'Project portal closes Friday at midnight',
        confidence: 0.85,
      );

      final msg = await executeUseCase.execute(intent: intent);
      expect(msg, 'Saved note "Project portal closes Friday"');

      final notes = await db.select(db.notes).get();
      expect(notes.length, 1);
      expect(notes.first.content, 'Project portal closes Friday at midnight');
    });
  });
}
