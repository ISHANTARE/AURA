import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../database/app_database.dart';
import '../../../database/daos/item_dao.dart';
import '../../../database/daos/workspace_dao.dart';
import '../../reminders/services/reminder_scheduling_service.dart';
import 'extracted_intent.dart';

/// Single authoritative dispatcher executing confirmed AI intents to the Drift database.
class ExecuteAiActionUseCase {
  final AppDatabase _db;
  final ItemDao _itemDao;
  final WorkspaceDao _workspaceDao;
  final ReminderSchedulingService _schedulingService;
  final Uuid _uuid;

  ExecuteAiActionUseCase({
    required AppDatabase db,
    required ItemDao itemDao,
    required WorkspaceDao workspaceDao,
    required ReminderSchedulingService schedulingService,
    Uuid? uuid,
  })  : _db = db,
        _itemDao = itemDao,
        _workspaceDao = workspaceDao,
        _schedulingService = schedulingService,
        _uuid = uuid ?? const Uuid();

  /// Executes the confirmed [intent] and returns a human-friendly confirmation message.
  Future<String> execute({
    required ExtractedIntent intent,
    String? rawTranscript,
    String? assignedWorkspaceId,
  }) async {
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    String confirmation;
    String? createdItemId;

    switch (intent.intentType) {
      case 'create_alarm':
        final res = await _executeCreateAlarm(intent, nowMs);
        confirmation = res.$1;
        createdItemId = res.$2;
        break;

      case 'create_workspace':
        confirmation = await _executeCreateWorkspace(intent, nowMs);
        break;

      case 'delete_task':
        confirmation = await _executeDeleteTask(intent, nowMs);
        break;

      case 'delete_workspace':
        confirmation = await _executeDeleteWorkspace(intent, nowMs);
        break;

      case 'add_note':
        confirmation = await _executeAddNote(intent, assignedWorkspaceId, nowMs);
        break;

      case 'create_reminder':
      case 'create_event':
      case 'create_task':
      default:
        final res = await _executeCreateTaskOrReminder(intent, assignedWorkspaceId, nowMs);
        confirmation = res.$1;
        createdItemId = res.$2;
        break;
    }

    // Insert audit log into ai_actions_logs
    await _db.into(_db.aiActionsLogs).insert(
          AiActionsLogsCompanion.insert(
            id: _uuid.v4(),
            inputText: rawTranscript ?? intent.title ?? '',
            rawResponse: rawTranscript ?? intent.title ?? '',
            parsedJson: jsonEncode(intent.toJson()),
            confidence: Value(intent.confidence),
            actionTaken: confirmation,
            itemId: Value(createdItemId),
            createdAt: nowMs,
          ),
        );

    return confirmation;
  }

  // ── Private Action Handlers ────────────────────────────────────────────────

  Future<(String, String)> _executeCreateAlarm(ExtractedIntent intent, int nowMs) async {
    final id = _uuid.v4();
    final deadlineDt = intent.deadlineIso != null ? DateTime.tryParse(intent.deadlineIso!) : null;
    final fireAt = deadlineDt?.millisecondsSinceEpoch ?? nowMs;

    final item = Item(
      id: id,
      title: intent.title ?? 'Alarm',
      category: 'alarm',
      kind: 'alarm',
      status: 'pending',
      priority: 'high',
      isRecurring: intent.isRecurring,
      recurrenceRule: intent.recurrenceType,
      fireAt: fireAt,
      createdAt: nowMs,
      updatedAt: nowMs,
    );

    await _itemDao.insertItem(
      ItemsCompanion.insert(
        id: id,
        title: item.title,
        category: const Value('alarm'),
        kind: const Value('alarm'),
        priority: const Value('high'),
        isRecurring: Value(item.isRecurring),
        recurrenceRule: Value(item.recurrenceRule),
        fireAt: Value(fireAt),
        createdAt: nowMs,
        updatedAt: nowMs,
      ),
    );

    await _schedulingService.syncForItem(item);

    final timeStr = deadlineDt != null
        ? '${deadlineDt.hour % 12 == 0 ? 12 : deadlineDt.hour % 12}:${deadlineDt.minute.toString().padLeft(2, '0')} ${deadlineDt.hour >= 12 ? 'PM' : 'AM'}'
        : 'scheduled time';

    return ('Set alarm for $timeStr', id);
  }

  Future<String> _executeCreateWorkspace(ExtractedIntent intent, int nowMs) async {
    final id = _uuid.v4();
    final name = intent.title ?? 'New Workspace';
    final color = intent.workspaceColorHex ?? '#C8FF00';

    await _workspaceDao.insertWorkspace(
      WorkspacesCompanion.insert(
        id: id,
        name: name,
        colorHex: Value(color),
        iconKey: Value(intent.workspaceIconKey ?? 'custom'),
        createdAt: nowMs,
        updatedAt: nowMs,
      ),
    );

    return 'Created workspace "$name"';
  }

  Future<String> _executeDeleteTask(ExtractedIntent intent, int nowMs) async {
    final target = (intent.targetName ?? intent.title ?? '').trim().toLowerCase();
    final allActive = await _itemDao.watchAllActive().first;

    final matched = allActive.where((item) {
      return item.title.toLowerCase().contains(target) || target.contains(item.title.toLowerCase());
    }).toList();

    if (matched.isEmpty) {
      return 'No matching task found to delete for "$target"';
    }

    final toDelete = matched.first;
    await _schedulingService.cancelForItem(toDelete.id);
    await _itemDao.softDeleteItem(toDelete.id, nowMs);

    return 'Deleted task "${toDelete.title}"';
  }

  Future<String> _executeDeleteWorkspace(ExtractedIntent intent, int nowMs) async {
    final target = (intent.targetName ?? intent.title ?? '').trim().toLowerCase();
    final allWs = await _workspaceDao.watchAll().first;

    final matched = allWs.where((ws) {
      return ws.name.toLowerCase().contains(target) || target.contains(ws.name.toLowerCase());
    }).toList();

    if (matched.isEmpty) {
      return 'No matching workspace found to delete for "$target"';
    }

    final toDelete = matched.first;
    await _workspaceDao.softDeleteWorkspace(toDelete.id, nowMs);

    return 'Deleted workspace "${toDelete.name}"';
  }

  Future<String> _executeAddNote(ExtractedIntent intent, String? workspaceId, int nowMs) async {
    final id = _uuid.v4();
    final title = intent.title ?? 'Note';
    final content = intent.notes ?? title;

    await _db.into(_db.notes).insert(
          NotesCompanion.insert(
            id: id,
            workspaceId: Value(workspaceId),
            content: content,
            createdAt: nowMs,
            updatedAt: nowMs,
          ),
        );

    return 'Saved note "$title"';
  }

  Future<(String, String)> _executeCreateTaskOrReminder(ExtractedIntent intent, String? workspaceId, int nowMs) async {
    final id = _uuid.v4();
    final title = intent.title ?? 'New Task';
    final deadlineDt = intent.deadlineIso != null ? DateTime.tryParse(intent.deadlineIso!) : null;
    final fireAt = deadlineDt?.millisecondsSinceEpoch;

    final isReminder = intent.intentType == 'create_reminder';
    final isEvent = intent.intentType == 'create_event';

    final kind = isEvent ? 'event' : (isReminder ? 'reminder' : 'task');
    final category = isReminder ? 'reminder' : (isEvent ? 'event' : 'general');

    final item = Item(
      id: id,
      workspaceId: workspaceId,
      title: title,
      notes: intent.notes,
      status: 'pending',
      category: category,
      kind: kind,
      priority: intent.priority ?? 'medium',
      isRecurring: intent.isRecurring,
      recurrenceRule: intent.recurrenceType,
      deadline: fireAt,
      fireAt: fireAt,
      createdAt: nowMs,
      updatedAt: nowMs,
    );

    await _itemDao.insertItem(
      ItemsCompanion.insert(
        id: id,
        workspaceId: Value(workspaceId),
        title: title,
        notes: Value(intent.notes),
        category: Value(category),
        kind: Value(kind),
        priority: Value(intent.priority ?? 'medium'),
        isRecurring: Value(intent.isRecurring),
        recurrenceRule: Value(intent.recurrenceType),
        deadline: Value(fireAt),
        fireAt: Value(fireAt),
        createdAt: nowMs,
        updatedAt: nowMs,
      ),
    );

    // Persist extracted offset reminders
    if (fireAt != null && intent.reminders.isNotEmpty) {
      for (final r in intent.reminders) {
        final remId = _uuid.v4();
        var offsetMs = 0;
        if (r.offsetUnit == 'minutes') {
          offsetMs = r.offsetValue * 60 * 1000;
        } else if (r.offsetUnit == 'hours') {
          offsetMs = r.offsetValue * 60 * 60 * 1000;
        } else if (r.offsetUnit == 'days') {
          offsetMs = r.offsetValue * 24 * 60 * 60 * 1000;
        }
        final triggerTime = fireAt - offsetMs;

        await _db.into(_db.remindersSchedule).insert(
              RemindersScheduleCompanion.insert(
                id: remId,
                itemId: id,
                offsetValue: r.offsetValue,
                offsetUnit: r.offsetUnit,
                fireAt: triggerTime,
              ),
            );
      }
    }

    if (fireAt != null) {
      await _schedulingService.syncForItem(item);
    }

    if (isReminder && deadlineDt != null) {
      final timeStr = '${deadlineDt.hour % 12 == 0 ? 12 : deadlineDt.hour % 12}:${deadlineDt.minute.toString().padLeft(2, '0')} ${deadlineDt.hour >= 12 ? 'PM' : 'AM'}';
      return ('Reminder set "$title" for $timeStr', id);
    }

    if (isEvent && deadlineDt != null) {
      return ('Event scheduled "$title"', id);
    }

    return ('Saved task "$title"', id);
  }
}
