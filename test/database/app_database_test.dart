import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aura/database/app_database.dart';
import 'package:drift/drift.dart' hide isNotNull;

void main() {
  late AppDatabase db;
  late ItemDao itemDao;
  late WorkspaceDao workspaceDao;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    itemDao = ItemDao(db);
    workspaceDao = WorkspaceDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('AppDatabase & DAOs Integration Tests', () {
    test('Inserts and retrieves workspace correctly', () async {
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      await workspaceDao.insertWorkspace(
        WorkspacesCompanion.insert(
          id: 'ws-1',
          name: 'Academics',
          colorHex: const Value('#3B82F6'),
          createdAt: nowMs,
          updatedAt: nowMs,
        ),
      );

      final workspaces = await workspaceDao.getAll();
      expect(workspaces.length, equals(1));
      expect(workspaces.first.name, equals('Academics'));
    });

    test('Inserts, updates status, and soft deletes items correctly', () async {
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      await itemDao.insertItem(
        ItemsCompanion.insert(
          id: 'item-1',
          title: 'Complete Lab Report',
          category: 'task',
          kind: 'generic',
          status: const Value('pending'),
          createdAt: nowMs,
          updatedAt: nowMs,
        ),
      );

      // Verify insertion
      final item = await itemDao.getById('item-1');
      expect(item, isNotNull);
      expect(item!.title, equals('Complete Lab Report'));
      expect(item.status, equals('pending'));

      // Update status to completed
      await itemDao.updateStatus('item-1', 'completed');
      final updated = await itemDao.getById('item-1');
      expect(updated!.status, equals('completed'));

      // Soft delete
      await itemDao.softDelete('item-1');
      final activeList = await itemDao.getAllActive();
      expect(activeList.any((i) => i.id == 'item-1'), isFalse);
    });

    test('Searches items by keyword correctly', () async {
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      await itemDao.insertItem(
        ItemsCompanion.insert(
          id: 'item-search',
          title: 'Prepare GATE Algo Notes',
          category: 'task',
          kind: 'generic',
          status: const Value('pending'),
          createdAt: nowMs,
          updatedAt: nowMs,
        ),
      );

      final searchResults = await itemDao.search('GATE');
      expect(searchResults.length, equals(1));
      expect(searchResults.first.title, contains('GATE Algo'));
    });
  });
}
