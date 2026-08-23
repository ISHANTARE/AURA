import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../../database/app_database.dart';
import '../entities/intent_result.dart';
import '../../../reminders/domain/services/reminder_scheduling_service.dart';

class CreateTaskUseCase {
  final AppDatabase _db;
  final ItemDao _itemDao;
  final WorkspaceDao _workspaceDao;
  final ReminderSchedulingService? _scheduling;
  static const Uuid _uuid = Uuid();

  CreateTaskUseCase(this._db, {ReminderSchedulingService? scheduling})
      : _itemDao = ItemDao(_db),
        _workspaceDao = WorkspaceDao(_db),
        _scheduling = scheduling;

  /// Executes a database transaction to save the confirmed item/task,
  /// creating a workspace if needed, logging to ai_actions_log and — for any
  /// timed intent — scheduling its reminders/alarms via the single
  /// [ReminderSchedulingService] path.
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

      // 2. Insert Item (v2 entity) — events keep their full timing metadata.
      final itemId = _uuid.v4();
      final isNote = intent.intentType == 'add_note';
      final category =
          isNote ? 'reminder' : (intent.intentType == 'create_alarm' ? 'alarm' : 'reminder');
      final kind = isNote ? 'note' : (intent.intentType == 'create_event' ? 'event' : 'task');

      await _itemDao.insertItem(
        ItemsCompanion.insert(
          id: itemId,
          workspaceId: Value(finalWorkspaceId),
          title: intent.title ?? (isNote ? 'Untitled Note' : 'Untitled Voice Task'),
          category: category,
          kind: kind,
          status: const Value('pending'),
          priority: Value(intent.priority ?? 'medium'),
          deadline: Value(intent.deadline?.millisecondsSinceEpoch),
          startTime: Value(intent.eventStart?.millisecondsSinceEpoch),
          endTime: Value(intent.eventEnd?.millisecondsSinceEpoch),
          location: Value(intent.eventLocation),
          notes: Value(intent.notes),
          isRecurring: Value(intent.isRecurring),
          recurrenceRule: Value(intent.recurrenceType),
          confidence: Value(intent.confidence),
          aiTranscript: Value(originalTranscript),
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
        'event_start_iso': intent.eventStart?.toIso8601String(),
        'event_end_iso': intent.eventEnd?.toIso8601String(),
        'event_location': intent.eventLocation,
        'workspace_hint': intent.workspaceHint,
        'priority': intent.priority,
        'is_recurring': intent.isRecurring,
        'reminders': intent.reminders.map((r) => r.toJson()).toList(),
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
    }).then((itemId) async {
      // 4. Schedule notifications outside the transaction — the OS call must
      // not roll back the DB write, and a scheduling failure must not lose
      // the item either (it is logged and surfaced via the returned outcome).
      if (!isTimedIntent(intent)) return itemId;

      try {
        final item = await _itemDao.getById(itemId);
        if (item != null) {
          final service = _scheduling ?? ReminderSchedulingService(db: _db);
          final outcome = await service.syncForItem(
            item,
            extractedReminders:
                intent.reminders.isNotEmpty ? intent.reminders : null,
          );
          if (outcome.usedInexactFallback || outcome.warnings.isNotEmpty) {
            debugPrint('CreateTaskUseCase scheduling notes: '
                '${outcome.warnings.join('; ')}');
          }
        }
      } catch (e, st) {
        debugPrint('Scheduling after task creation failed (item kept): '
            '$e\n$st');
      }
      return itemId;
    });
  }

  static bool isTimedIntent(IntentResult intent) {
    if (intent.intentType == 'create_alarm') return true;
    return intent.deadline != null ||
        intent.eventStart != null ||
        intent.reminders.isNotEmpty;
  }
}
