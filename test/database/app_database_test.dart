import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aura/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('AppDatabase Schema & DAO Integration Tests', () {
    test('Schema version is 4', () {
      expect(db.schemaVersion, 4);
    });

    test('WorkspaceDao inserts, queries, archives and soft-deletes with cascade', () async {
      final nowMs = DateTime.now().millisecondsSinceEpoch;

      // 1. Insert workspace
      const wsId = 'ws-academic-1';
      await db.workspaceDao.insertWorkspace(
        WorkspacesCompanion.insert(
          id: wsId,
          name: 'Academic',
          colorHex: const Value('#7B6FF0'),
          createdAt: nowMs,
          updatedAt: nowMs,
        ),
      );

      final ws = await db.workspaceDao.getWorkspaceById(wsId);
      expect(ws, isNotNull);
      expect(ws!.name, 'Academic');
      expect(ws.colorHex, '#7B6FF0');
      expect(ws.isArchived, false);

      // 2. Insert section
      const sectionId = 'sec-exams-1';
      await db.workspaceDao.insertSection(
        WorkspaceSectionsCompanion.insert(
          id: sectionId,
          workspaceId: wsId,
          name: 'Exams',
          createdAt: nowMs,
          updatedAt: nowMs,
        ),
      );

      final sections = await db.workspaceDao.watchSections(wsId).first;
      expect(sections.length, 1);
      expect(sections.first.name, 'Exams');

      // 3. Insert item in workspace
      const itemId = 'item-task-1';
      await db.itemDao.insertItem(
        ItemsCompanion.insert(
          id: itemId,
          workspaceId: const Value(wsId),
          sectionId: const Value(sectionId),
          title: 'Study Mathematics',
          category: const Value('reminder'),
          kind: const Value('task'),
          createdAt: nowMs,
          updatedAt: nowMs,
        ),
      );

      final itemsBefore = await db.itemDao.watchItemsByWorkspace(wsId).first;
      expect(itemsBefore.length, 1);

      // 4. Soft-delete workspace cascades to sections and items
      final deleteTime = nowMs + 1000;
      await db.workspaceDao.softDeleteWorkspace(wsId, deleteTime);

      final activeWorkspaces = await db.workspaceDao.watchAll().first;
      expect(activeWorkspaces.isEmpty, true);

      final activeSections = await db.workspaceDao.watchSections(wsId).first;
      expect(activeSections.isEmpty, true);

      final activeItems = await db.itemDao.watchItemsByWorkspace(wsId).first;
      expect(activeItems.isEmpty, true);
    });

    test('ItemDao handles subtask hierarchy (parentId) and soundUri (v3/v4)', () async {
      final nowMs = DateTime.now().millisecondsSinceEpoch;

      const parentId = 'parent-item-1';
      const childId = 'child-subtask-1';

      // Insert parent item with custom sound URI
      await db.itemDao.insertItem(
        ItemsCompanion.insert(
          id: parentId,
          title: 'Prepare Presentation',
          category: const Value('alarm'),
          kind: const Value('task'),
          soundUri: const Value('content://media/internal/audio/media/12'),
          createdAt: nowMs,
          updatedAt: nowMs,
        ),
      );

      // Insert child subtask referencing parentId
      await db.itemDao.insertItem(
        ItemsCompanion.insert(
          id: childId,
          parentId: const Value(parentId),
          title: 'Create Title Slide',
          category: const Value('reminder'),
          kind: const Value('task'),
          createdAt: nowMs,
          updatedAt: nowMs,
        ),
      );

      final parent = await db.itemDao.getItemById(parentId);
      expect(parent, isNotNull);
      expect(parent!.soundUri, 'content://media/internal/audio/media/12');

      final subtasks = await db.itemDao.watchSubtasks(parentId).first;
      expect(subtasks.length, 1);
      expect(subtasks.first.title, 'Create Title Slide');

      // Soft-deleting parent item cascades to subtasks
      await db.itemDao.softDeleteItem(parentId, nowMs + 500);

      final subtasksAfter = await db.itemDao.watchSubtasks(parentId).first;
      expect(subtasksAfter.isEmpty, true);
    });

    test('ItemDao status completion and active item queries', () async {
      final nowMs = DateTime.now().millisecondsSinceEpoch;

      const itemId = 'item-query-1';
      await db.itemDao.insertItem(
        ItemsCompanion.insert(
          id: itemId,
          title: 'Submit Assignment',
          deadline: Value(nowMs + 3600000),
          createdAt: nowMs,
          updatedAt: nowMs,
        ),
      );

      final activeList = await db.itemDao.watchAllActive().first;
      expect(activeList.length, 1);

      // Mark complete
      await db.itemDao.completeItem(itemId, true, nowMs + 100);
      final itemCompleted = await db.itemDao.getItemById(itemId);
      expect(itemCompleted!.status, 'completed');

      // Mark pending again
      await db.itemDao.completeItem(itemId, false, nowMs + 200);
      final itemPending = await db.itemDao.getItemById(itemId);
      expect(itemPending!.status, 'pending');
    });

    test('NotificationDao logs DND status and catchup replay', () async {
      final nowMs = DateTime.now().millisecondsSinceEpoch;

      // Create item & reminder
      const itemId = 'item-rem-1';
      await db.itemDao.insertItem(
        ItemsCompanion.insert(
          id: itemId,
          title: 'Silent Reminder',
          createdAt: nowMs,
          updatedAt: nowMs,
        ),
      );

      const reminderId = 'rem-1';
      await db.into(db.remindersSchedule).insert(
            RemindersScheduleCompanion.insert(
              id: reminderId,
              itemId: itemId,
              offsetValue: 0,
              offsetUnit: 'minutes',
              fireAt: nowMs,
            ),
          );

      // Insert DND notification log
      const logId = 'log-dnd-1';
      await db.notificationDao.insertLog(
        NotificationLogsCompanion.insert(
          id: logId,
          reminderId: reminderId,
          scheduledAt: nowMs,
          wasDnd: const Value(true),
          createdAt: nowMs,
        ),
      );

      final unreplayed = await db.notificationDao.getUnreplayed();
      expect(unreplayed.length, 1);
      expect(unreplayed.first.id, logId);

      // Mark replayed
      await db.notificationDao.markReplayed(logId, nowMs + 5000);
      final unreplayedAfter = await db.notificationDao.getUnreplayed();
      expect(unreplayedAfter.isEmpty, true);
    });

    test('OfflineQueueDao handles FIFO enqueue, retries, and processing', () async {
      final nowMs = DateTime.now().millisecondsSinceEpoch;

      const qId1 = 'queue-1';
      const qId2 = 'queue-2';

      await db.offlineQueueDao.enqueue(
        OfflineQueuesCompanion.insert(
          id: qId1,
          content: 'Set reminder for meeting tomorrow',
          createdAt: nowMs,
        ),
      );

      await db.offlineQueueDao.enqueue(
        OfflineQueuesCompanion.insert(
          id: qId2,
          content: 'Buy textbooks',
          createdAt: nowMs + 100,
        ),
      );

      final pending = await db.offlineQueueDao.getPendingItems();
      expect(pending.length, 2);
      expect(pending.first.id, qId1); // FIFO check

      // Increment attempt
      await db.offlineQueueDao.incrementAttempt(qId1, 0);
      final updatedQueue1 = (await db.offlineQueueDao.getPendingItems())
          .firstWhere((e) => e.id == qId1);
      expect(updatedQueue1.attempts, 1);

      // Mark processed
      await db.offlineQueueDao.markProcessed(qId1, nowMs + 500);
      final pendingAfter = await db.offlineQueueDao.getPendingItems();
      expect(pendingAfter.length, 1);
      expect(pendingAfter.first.id, qId2);
    });

    test('SharedContentDao handles staging and cleanup', () async {
      final nowMs = DateTime.now().millisecondsSinceEpoch;

      const sId = 'share-1';
      await db.sharedContentDao.insertContent(
        SharedContentsCompanion.insert(
          id: sId,
          type: 'text',
          rawUrl: const Value('https://example.com'),
          ocrText: const Value('Shared lecture notes'),
          createdAt: nowMs - 100000,
          updatedAt: nowMs - 100000,
        ),
      );

      final pending = await db.sharedContentDao.getPending();
      expect(pending.length, 1);

      // Mark processed
      await db.sharedContentDao.markProcessed(sId);
      final pendingAfter = await db.sharedContentDao.getPending();
      expect(pendingAfter.isEmpty, true);

      // Delete older than cutoff
      final deletedCount = await db.sharedContentDao.deleteOlderThan(nowMs);
      expect(deletedCount, 1);
    });
  });
}
