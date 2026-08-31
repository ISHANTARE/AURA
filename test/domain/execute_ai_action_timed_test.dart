import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:aura/database/app_database.dart';
import 'package:aura/features/capture/domain/entities/intent_result.dart';
import 'package:aura/features/capture/domain/usecases/execute_ai_action_usecase.dart';

/// Covers the audit's headline breakage: create_event / create_reminder used
/// to fall through to bare task rows with no time fields and no notifications.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late ItemDao itemDao;
  late WorkspaceDao workspaceDao;
  late ExecuteAiActionUseCase useCase;
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

    const secure = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
    TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secure, (call) async => null);
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    recordedCalls.clear();
    db = AppDatabase.forTesting(NativeDatabase.memory());
    itemDao = ItemDao(db);
    workspaceDao = WorkspaceDao(db);
    useCase = ExecuteAiActionUseCase(db);

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

  group('create_event intent', () {
    test('persists start/end/location and schedules a notification',
        () async {
      final start = DateTime.now().add(const Duration(days: 1));
      final end = start.add(const Duration(hours: 2));

      final msg = await useCase.execute(
        intent: IntentResult(
          intentType: 'create_event',
          title: 'Interview at Google',
          eventStart: start,
          eventEnd: end,
          eventLocation: 'Google HQ',
          confidence: 0.92,
        ),
        workspaceId: 'ws-general',
        originalTranscript: 'schedule interview at google tomorrow at 2pm',
      );

      expect(msg, contains('Event scheduled'));

      final items = await itemDao.getAllActive();
      final event = items.firstWhere((i) => i.kind == 'event');
      expect(event.startTime, start.millisecondsSinceEpoch);
      expect(event.endTime, end.millisecondsSinceEpoch);
      expect(event.location, 'Google HQ');
      expect(event.confidence, closeTo(0.92, 0.001));
      expect(
          event.aiTranscript, contains('interview at google'));

      expect(recordedCalls.contains('zonedSchedule'), isTrue,
          reason: 'events must fire a reminder notification');
    });
  });

  group('create_reminder intent', () {
    test('schedules a notification for the deadline', () async {
      final deadline = DateTime.now().add(const Duration(hours: 4));

      final msg = await useCase.execute(
        intent: IntentResult(
          intentType: 'create_reminder',
          title: 'Submit assignment',
          deadline: deadline,
        ),
        workspaceId: 'ws-general',
        originalTranscript: 'remind me to submit assignment tomorrow',
      );

      expect(msg, contains('Reminder set'));

      final reminders = await (db.select(db.remindersSchedule)).get();
      expect(reminders, isNotEmpty,
          reason: 'deadline occurrence must be persisted');
      expect(recordedCalls.contains('zonedSchedule'), isTrue);
    });
  });

  group('delete_task intent', () {
    test('cancels scheduled notifications before soft-deleting', () async {
      // Create a timed item first through the same pipeline.
      await useCase.execute(
        intent: IntentResult(
          intentType: 'create_reminder',
          title: 'Unique Task Name',
          deadline: DateTime.now().add(const Duration(hours: 2)),
        ),
        workspaceId: 'ws-general',
        originalTranscript: 'remind me about unique task name',
      );

      recordedCalls.clear();
      const deleteIntent = IntentResult(
        intentType: 'delete_task',
        targetName: 'Unique Task Name',
      );
      final msg = await useCase.execute(
        intent: deleteIntent,
        workspaceId: 'ws-general',
        originalTranscript: 'delete task unique task name',
      );

      expect(msg, contains('Deleted task "Unique Task Name"'));
      // search() filters soft-deleted rows — query the table directly.
      final rows = await (db.select(db.items)
            ..where((t) => t.title.equals('Unique Task Name')))
          .get();
      expect(rows, hasLength(1));
      expect(rows.first.deletedAt, isNotNull);
      expect(recordedCalls.contains('cancel'), isTrue,
          reason: 'deleted reminders must never ring');
    });
  });
}
