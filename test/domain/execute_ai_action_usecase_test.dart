import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:aura/database/app_database.dart';
import 'package:aura/features/capture/domain/entities/intent_result.dart';
import 'package:aura/features/capture/domain/usecases/execute_ai_action_usecase.dart';
import 'package:drift/drift.dart' hide isNotNull;

void main() {
  late AppDatabase db;
  late ItemDao itemDao;
  late WorkspaceDao workspaceDao;
  late ExecuteAiActionUseCase executeAiActionUseCase;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('UTC'));

    const channel = MethodChannel('dexterous.com/flutter/local_notifications');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      return null;
    });
  });

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    itemDao = ItemDao(db);
    workspaceDao = WorkspaceDao(db);
    executeAiActionUseCase = ExecuteAiActionUseCase(db);

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

  group('ExecuteAiActionUseCase Unit Tests', () {
    test('Creates alarm action successfully', () async {
      final intent = IntentResult(
        intentType: 'create_alarm',
        title: 'Morning Alarm',
        deadline: DateTime.now().add(const Duration(hours: 1)),
      );

      final msg = await executeAiActionUseCase.execute(
        intent: intent,
        workspaceId: 'ws-general',
        originalTranscript: 'set alarm for morning',
      );

      expect(msg, contains('Set alarm'));
      final activeAlarms = await itemDao.watchByCategory('alarm').first;
      expect(activeAlarms.length, equals(1));
    });

    test('Creates workspace action successfully', () async {
      const intent = IntentResult(
        intentType: 'create_workspace',
        title: 'Placement Prep',
        workspaceColorHex: '#C8FF00',
      );

      final msg = await executeAiActionUseCase.execute(
        intent: intent,
        workspaceId: 'ws-general',
        originalTranscript: 'create workspace Placement Prep',
      );

      expect(msg, contains('Created workspace "Placement Prep"'));
      final workspaces = await workspaceDao.getAll();
      expect(workspaces.any((w) => w.name == 'Placement Prep'), isTrue);
    });

    test('Delete task intent safeguards against mass deletion when multiple matches exist', () async {
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      await itemDao.insertItem(
        ItemsCompanion.insert(
          id: 't-1',
          title: 'Project Proposal Alpha',
          category: 'task',
          kind: 'generic',
          createdAt: nowMs,
          updatedAt: nowMs,
        ),
      );
      await itemDao.insertItem(
        ItemsCompanion.insert(
          id: 't-2',
          title: 'Project Submission Beta',
          category: 'task',
          kind: 'generic',
          createdAt: nowMs,
          updatedAt: nowMs,
        ),
      );

      const intent = IntentResult(
        intentType: 'delete_task',
        title: 'Project',
        targetName: 'Project',
      );

      final msg = await executeAiActionUseCase.execute(
        intent: intent,
        workspaceId: 'ws-general',
        originalTranscript: 'delete task project',
      );

      // Should refuse to mass-delete and ask for exact title
      expect(msg, contains('Multiple tasks matched'));

      final activeItems = await itemDao.getAllActive();
      expect(activeItems.length, equals(2));
    });

    test('Delete task intent deletes single exact match safely', () async {
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      await itemDao.insertItem(
        ItemsCompanion.insert(
          id: 't-exact',
          title: 'Unique Task Name',
          category: 'task',
          kind: 'generic',
          createdAt: nowMs,
          updatedAt: nowMs,
        ),
      );

      const intent = IntentResult(
        intentType: 'delete_task',
        title: 'Unique Task Name',
        targetName: 'Unique Task Name',
      );

      final msg = await executeAiActionUseCase.execute(
        intent: intent,
        workspaceId: 'ws-general',
        originalTranscript: 'delete task Unique Task Name',
      );

      expect(msg, contains('Deleted task "Unique Task Name"'));
      final item = await itemDao.getById('t-exact');
      expect(item!.deletedAt, isNotNull);
    });
  });
}
