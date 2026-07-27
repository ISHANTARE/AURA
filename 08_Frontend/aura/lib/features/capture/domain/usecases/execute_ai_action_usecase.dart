import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../../database/app_database.dart';
import '../entities/intent_result.dart';
import 'create_task_usecase.dart';

/// Single Action Dispatcher Engine for AURA (Sprint 8).
/// Executes confirmed actions based on intentType:
///   • create_task
///   • create_workspace
///   • delete_task
///   • delete_workspace
///   • create_event
///   • add_note
class ExecuteAiActionUseCase {
  final AppDatabase _db;
  final CreateTaskUseCase _createTaskUseCase;
  static const Uuid _uuid = Uuid();

  ExecuteAiActionUseCase(this._db)
      : _createTaskUseCase = CreateTaskUseCase(_db);

  Future<String> execute({
    required IntentResult intent,
    required String workspaceId,
    String? workspaceNameToCreate,
    required String originalTranscript,
  }) async {
    final nowEpoch = DateTime.now().millisecondsSinceEpoch;

    switch (intent.intentType) {
      case 'create_alarm':
        final fireTime = intent.deadline ?? DateTime.now().add(const Duration(minutes: 30));
        final alarmId = _uuid.v4();

        // Create dummy parent task for alarm reference
        final taskId = await _createTaskUseCase.execute(
          intent: intent.copyWith(title: intent.title ?? 'Alarm ${fireTime.hour}:${fireTime.minute}'),
          workspaceId: workspaceId,
          workspaceNameToCreate: workspaceNameToCreate,
          originalTranscript: originalTranscript,
        );

        await _db.into(_db.reminders).insert(
          RemindersCompanion.insert(
            id: alarmId,
            taskId: Value(taskId),
            fireAt: fireTime.millisecondsSinceEpoch,
            type: const Value('alarm'),
            createdAt: nowEpoch,
            updatedAt: nowEpoch,
          ),
        );
        return 'Set alarm for ${_formatTime(fireTime)}';
      case 'create_workspace':
        final newWsId = _uuid.v4();
        final wsName = intent.title ?? workspaceNameToCreate ?? 'New Workspace';
        final colorHex = intent.workspaceColorHex ?? '#C8FF00';
        final iconKey = intent.workspaceIconKey ?? 'folder';

        await _db.workspaceDao.insertWorkspace(
          WorkspacesCompanion.insert(
            id: newWsId,
            name: wsName,
            colorHex: Value(colorHex),
            iconKey: Value(iconKey),
            createdAt: nowEpoch,
            updatedAt: nowEpoch,
          ),
        );
        return 'Created workspace "$wsName"';

      case 'delete_task':
        final searchTerm = intent.targetName ?? intent.title ?? '';
        if (searchTerm.isEmpty) return 'No task specified for deletion';

        final allTasks = await _db.taskDao.getAll();
        final matches = allTasks.where((t) =>
            t.name.toLowerCase().contains(searchTerm.toLowerCase()) &&
            t.deletedAt == null);

        int count = 0;
        for (final t in matches) {
          await _db.taskDao.softDelete(t.id);
          count++;
        }
        return count > 0
            ? 'Deleted $count task(s) matching "$searchTerm"'
            : 'No active task found matching "$searchTerm"';

      case 'delete_workspace':
        final searchTerm = intent.targetName ?? intent.title ?? '';
        if (searchTerm.isEmpty) return 'No workspace specified for deletion';

        final allWorkspaces = await _db.workspaceDao.getAll();
        final matches = allWorkspaces.where((w) =>
            w.name.toLowerCase().contains(searchTerm.toLowerCase()) &&
            w.deletedAt == null);

        int count = 0;
        for (final w in matches) {
          await _db.workspaceDao.softDelete(w.id);
          count++;
        }
        return count > 0
            ? 'Deleted $count workspace(s) matching "$searchTerm"'
            : 'No active workspace found matching "$searchTerm"';

      case 'add_note':
      case 'create_task':
      default:
        // Task creation fallback
        await _createTaskUseCase.execute(
          intent: intent,
          workspaceId: workspaceId,
          workspaceNameToCreate: workspaceNameToCreate,
          originalTranscript: originalTranscript,
        );
        return 'Saved task "${intent.title ?? 'Untitled'}"';
    }
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final minuteStr = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minuteStr $ampm';
  }
}
