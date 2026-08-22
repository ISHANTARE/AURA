import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../../database/app_database.dart';
import '../../../reminders/data/services/notification_service.dart';
import '../entities/intent_result.dart';
import 'create_task_usecase.dart';

/// Single Action Dispatcher Engine for AURA.
/// Executes confirmed actions based on intentType:
///   • create_task / create_alarm / create_workspace / delete_task / delete_workspace
class ExecuteAiActionUseCase {
  final ItemDao _itemDao;
  final WorkspaceDao _workspaceDao;
  final CreateTaskUseCase _createTaskUseCase;
  static const Uuid _uuid = Uuid();

  ExecuteAiActionUseCase(AppDatabase db)
      : _itemDao = ItemDao(db),
        _workspaceDao = WorkspaceDao(db),
        _createTaskUseCase = CreateTaskUseCase(db);

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

        await _itemDao.insertItem(
          ItemsCompanion.insert(
            id: alarmId,
            title: intent.title ?? 'Alarm ${_formatTime(fireTime)}',
            category: 'alarm',
            kind: 'generic',
            status: const Value('pending'),
            fireAt: Value(fireTime.millisecondsSinceEpoch),
            createdAt: nowEpoch,
            updatedAt: nowEpoch,
          ),
        );

        await NotificationService().scheduleAlarm(
          id: alarmId.hashCode.abs(),
          title: intent.title ?? 'Alarm',
          body: 'Alarm: ${_formatTime(fireTime)}',
          scheduledDate: fireTime,
          payload: alarmId,
        );

        return 'Set alarm for ${_formatTime(fireTime)}';

      case 'create_workspace':
        final newWsId = _uuid.v4();
        final wsName = intent.title ?? workspaceNameToCreate ?? 'New Workspace';
        final colorHex = intent.workspaceColorHex ?? '#C8FF00';
        final iconKey = intent.workspaceIconKey ?? 'folder';

        await _workspaceDao.insertWorkspace(
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

        final matches = await _itemDao.search(searchTerm);
        if (matches.isEmpty) {
          return 'No active item found matching "$searchTerm"';
        }

        // 1. Check for exact title match (case-insensitive)
        final exactMatches = matches
            .where((t) => t.title.trim().toLowerCase() == searchTerm.trim().toLowerCase())
            .toList();

        if (exactMatches.length == 1) {
          await _itemDao.softDelete(exactMatches.first.id);
          return 'Deleted task "${exactMatches.first.title}"';
        }

        if (exactMatches.length > 1) {
          final sorted = List<Item>.from(exactMatches)
            ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
          await _itemDao.softDelete(sorted.first.id);
          return 'Deleted task "${sorted.first.title}" (${exactMatches.length} matches found)';
        }

        // 2. If no exact title match, delete only if single fuzzy match found
        if (matches.length == 1) {
          await _itemDao.softDelete(matches.first.id);
          return 'Deleted task "${matches.first.title}"';
        }

        return 'Multiple tasks matched "$searchTerm" (${matches.length} found). Please specify the exact task title.';

      case 'delete_workspace':
        final searchTerm = intent.targetName ?? intent.title ?? '';
        if (searchTerm.isEmpty) return 'No workspace specified for deletion';

        final allWorkspaces = await _workspaceDao.getAll();
        final matches = allWorkspaces
            .where((w) =>
                w.deletedAt == null &&
                w.name.toLowerCase().contains(searchTerm.toLowerCase()))
            .toList();

        if (matches.isEmpty) {
          return 'No active workspace found matching "$searchTerm"';
        }

        final exactMatches = matches
            .where((w) => w.name.trim().toLowerCase() == searchTerm.trim().toLowerCase())
            .toList();

        if (exactMatches.isNotEmpty) {
          final target = exactMatches.first;
          await _workspaceDao.softDelete(target.id);
          return 'Deleted workspace "${target.name}"';
        }

        if (matches.length == 1) {
          await _workspaceDao.softDelete(matches.first.id);
          return 'Deleted workspace "${matches.first.name}"';
        }

        return 'Multiple workspaces matched "$searchTerm" (${matches.length} found). Please specify the exact workspace name.';

      case 'add_note':
      case 'create_task':
      default:
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
