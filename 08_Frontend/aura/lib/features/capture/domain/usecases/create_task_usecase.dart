import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../../database/app_database.dart';
import '../entities/intent_result.dart';

class CreateTaskUseCase {
  final AppDatabase _db;
  final ItemDao _itemDao;
  final WorkspaceDao _workspaceDao;
  static const Uuid _uuid = Uuid();

  CreateTaskUseCase(this._db)
      : _itemDao = ItemDao(_db),
        _workspaceDao = WorkspaceDao(_db);

  /// Executes a database transaction to save the confirmed item/task,
  /// creating a workspace if needed, and logging to ai_actions_log.
  Future<String> execute({
    required IntentResult intent,
    required String workspaceId,
    String? workspaceNameToCreate,
    required String originalTranscript,
  }) async {
    return await _db.transaction<String>(() async {
      var finalWorkspaceId = workspaceId;
      final nowEpoch = DateTime.now().millisecondsSinceEpoch;

      // 1. If workspace needs auto-creation, create it now
      if (workspaceId == 'NEW' && workspaceNameToCreate != null) {
        final newWsId = _uuid.v4();
        await _workspaceDao.insertWorkspace(
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

      // 2. Insert Item (v2 entity)
      final itemId = _uuid.v4();

      await _itemDao.insertItem(
        ItemsCompanion.insert(
          id: itemId,
          workspaceId: Value(finalWorkspaceId),
          title: intent.title ?? 'Untitled Voice Task',
          category: 'reminder',
          kind: 'task',
          status: const Value('pending'),
          priority: Value(intent.priority ?? 'medium'),
          deadline: Value(intent.deadline?.millisecondsSinceEpoch),
          notes: Value(intent.notes),
          isRecurring: Value(intent.isRecurring),
          recurrenceRule: Value(intent.recurrenceType),
          createdAt: nowEpoch,
          updatedAt: nowEpoch,
        ),
      );

      // 3. Log AI Action (store full serialized intent for audit trail)
      final logId = _uuid.v4();
      final intentJson = jsonEncode({
        'intent_type': intent.intentType,
        'title': intent.title,
        'deadline_iso': intent.deadline?.toIso8601String(),
        'workspace_hint': intent.workspaceHint,
        'priority': intent.priority,
        'is_recurring': intent.isRecurring,
        'notes': intent.notes,
        'confidence': intent.confidence,
      });
      await _db.into(_db.aiActionsLogs).insert(
        AiActionsLogsCompanion.insert(
          id: logId,
          inputText: originalTranscript,
          rawResponse: intent.title ?? '',
          parsedJson: intentJson,
          confidence: Value(intent.confidence),
          actionTaken: 'task_created',
          itemId: Value(itemId),
          userEdited: const Value(false),
          createdAt: nowEpoch,
        ),
      );

      return itemId;
    });
  }
}
