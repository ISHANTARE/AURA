import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../../database/app_database.dart';
import '../entities/intent_result.dart';

class CreateTaskUseCase {
  final AppDatabase _db;
  static const Uuid _uuid = Uuid();

  CreateTaskUseCase(this._db);

  /// Executes a database transaction to save the confirmed task, any reminders,
  /// creating a workspace if needed, and logging to ai_actions_log.
  Future<String> execute({
    required IntentResult intent,
    required String workspaceId,
    String? workspaceNameToCreate,
    required String originalTranscript,
  }) async {
    return _db.transaction(() async {
      var finalWorkspaceId = workspaceId;
      final nowEpoch = DateTime.now().millisecondsSinceEpoch;

      // 1. If workspace needs auto-creation, create it now
      if (workspaceId == 'NEW' && workspaceNameToCreate != null) {
        final newWsId = _uuid.v4();
        await _db.workspaceDao.insertWorkspace(
          WorkspacesCompanion.insert(
            id: newWsId,
            name: workspaceNameToCreate,
            colorHex: const Value('#C8FF00'),
            iconKey: const Value('custom'),
            createdAt: nowEpoch,
            updatedAt: nowEpoch,
          ),
        );
        finalWorkspaceId = newWsId;
      }

      // 2. Insert Task
      final taskId = _uuid.v4();

      final taskCompanion = TasksCompanion.insert(
        id: taskId,
        workspaceId: finalWorkspaceId,
        name: intent.title ?? 'Untitled Voice Task',
        status: const Value('todo'),
        priority: Value(intent.priority ?? 'medium'),
        deadline: Value(intent.deadline?.millisecondsSinceEpoch),
        description: Value(intent.notes),
        isRecurring: Value(intent.isRecurring),
        recurrenceType: Value(intent.recurrenceType),
        createdAt: nowEpoch,
        updatedAt: nowEpoch,
      );

      // 3. Prepare Reminders
      final reminderCompanions = <RemindersCompanion>[];
      for (final rem in intent.reminders) {
        final remId = _uuid.v4();
        int fireAtEpoch;
        if (intent.deadline != null) {
          Duration offset;
          switch (rem.offsetUnit) {
            case 'days':
              offset = Duration(days: rem.offsetValue);
              break;
            case 'hours':
              offset = Duration(hours: rem.offsetValue);
              break;
            default:
              offset = Duration(minutes: rem.offsetValue);
          }
          fireAtEpoch = intent.deadline!.subtract(offset).millisecondsSinceEpoch;
        } else {
          fireAtEpoch = DateTime.now().add(const Duration(minutes: 30)).millisecondsSinceEpoch;
        }

        reminderCompanions.add(
          RemindersCompanion.insert(
            id: remId,
            taskId: Value(taskId),
            fireAt: fireAtEpoch,
            type: Value(rem.type),
            status: const Value('pending'),
            createdAt: nowEpoch,
            updatedAt: nowEpoch,
          ),
        );
      }

      await _db.taskDao.insertWithReminders(taskCompanion, reminderCompanions);

      // 4. Log AI Action
      final logId = _uuid.v4();
      await _db.into(_db.aiActionsLogs).insert(
        AiActionsLogsCompanion.insert(
          id: logId,
          inputText: originalTranscript,
          rawResponse: intent.title ?? '',
          parsedJson: intent.title ?? '',
          confidence: Value(intent.confidence),
          actionTaken: 'task_created',
          taskId: Value(taskId),
          userEdited: const Value(false),
          createdAt: nowEpoch,
        ),
      );

      return taskId;
    });
  }
}
