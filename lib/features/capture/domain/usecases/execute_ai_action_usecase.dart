import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../../database/app_database.dart';
import '../../../reminders/domain/services/reminder_scheduling_service.dart';
import '../entities/intent_result.dart';
import 'create_task_usecase.dart';

/// Single Action Dispatcher Engine for AURA.
/// Executes confirmed actions based on intentType:
///   • create_task / create_reminder / create_event / create_alarm
///   • create_workspace / delete_task / delete_workspace / add_note
class ExecuteAiActionUseCase {
  final ItemDao _itemDao;
  final WorkspaceDao _workspaceDao;
  final CreateTaskUseCase _createTaskUseCase;
  final ReminderSchedulingService _scheduling;
  static const Uuid _uuid = Uuid();

  ExecuteAiActionUseCase(AppDatabase db, {ReminderSchedulingService? scheduling})
      : this._(db, scheduling ?? ReminderSchedulingService(db: db));

  ExecuteAiActionUseCase._(AppDatabase db, ReminderSchedulingService scheduling)
      : _itemDao = ItemDao(db),
        _workspaceDao = WorkspaceDao(db),
        _scheduling = scheduling,
        _createTaskUseCase = CreateTaskUseCase(db, scheduling: scheduling);

  Future<String> execute({
    required IntentResult intent,
    required String workspaceId,
    String? workspaceNameToCreate,
    required String originalTranscript,
  }) async {
    final nowEpoch = DateTime.now().millisecondsSinceEpoch;

    switch (intent.intentType) {
      case 'create_alarm':
        final fireTime =
            intent.deadline ?? DateTime.now().add(const Duration(minutes: 30));
        final alarmId = _uuid.v4();

        await _itemDao.insertItem(
          ItemsCompanion.insert(
            id: alarmId,
            title: intent.title ?? 'Alarm ${_formatTime(fireTime)}',
            category: 'alarm',
            kind: 'alarm',
            status: const Value('pending'),
            fireAt: Value(fireTime.millisecondsSinceEpoch),
            confidence: Value(intent.confidence),
            aiTranscript: Value(originalTranscript),
            createdAt: nowEpoch,
            updatedAt: nowEpoch,
          ),
        );

        final item = await _itemDao.getById(alarmId);
        if (item != null) {
          await _scheduling.syncForItem(item);
        }

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
          await _softDeleteWithNotifications(exactMatches.first.id);
          return 'Deleted task "${exactMatches.first.title}"';
        }

        if (exactMatches.length > 1) {
          final sorted = List<Item>.from(exactMatches)
            ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
          await _softDeleteWithNotifications(sorted.first.id);
          return 'Deleted task "${sorted.first.title}" (${exactMatches.length} matches found)';
        }

        // 2. If no exact title match, delete only if single fuzzy match found
        if (matches.length == 1) {
          await _softDeleteWithNotifications(matches.first.id);
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
        await _dispatchTimed(intent, workspaceId, workspaceNameToCreate, originalTranscript);
        return 'Saved task "${intent.title ?? 'Untitled'}"';

      case 'create_reminder':
        await _dispatchTimed(intent, workspaceId, workspaceNameToCreate, originalTranscript);
        return _timedConfirmation(intent, 'Reminder set');

      case 'create_event':
        await _dispatchTimed(intent, workspaceId, workspaceNameToCreate, originalTranscript);
        return _timedConfirmation(intent, 'Event scheduled');

      default:
        await _dispatchTimed(intent, workspaceId, workspaceNameToCreate, originalTranscript);
        return 'Saved task "${intent.title ?? 'Untitled'}"';
    }
  }

  /// Tasks/reminders/events all persist through [CreateTaskUseCase], which
  /// also schedules their notifications — one path, no split-brain.
  Future<void> _dispatchTimed(
    IntentResult intent,
    String workspaceId,
    String? workspaceNameToCreate,
    String originalTranscript,
  ) async {
    await _createTaskUseCase.execute(
      intent: intent,
      workspaceId: workspaceId,
      workspaceNameToCreate: workspaceNameToCreate,
      originalTranscript: originalTranscript,
    );
  }

  String _timedConfirmation(IntentResult intent, String prefix) {
    final title = intent.title ?? 'Untitled';
    final when = intent.eventStart ?? intent.deadline;
    if (when == null) return '$prefix "$title"';
    return '$prefix "$title" for ${_formatTime(when)}';
  }

  /// Soft-delete an item and remove any notifications still queued for it so
  /// deleted reminders never ring from the grave.
  Future<void> _softDeleteWithNotifications(String itemId) async {
    try {
      await _scheduling.cancelForItem(itemId);
    } catch (e) {
      debugPrint('Failed cancelling notifications for $itemId: $e');
    }
    await _itemDao.softDelete(itemId);
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final minuteStr = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minuteStr $ampm';
  }
}
