import 'dart:convert';

import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:aura/core/services/connectivity_service.dart';
import 'package:aura/database/app_database.dart';
import 'package:aura/features/capture/data/datasources/llm_api_datasource.dart';
import 'package:aura/features/capture/domain/services/offline_queue_processor.dart';
import 'package:aura/features/capture/domain/usecases/execute_ai_action_usecase.dart';

class _FakeConnectivity implements ConnectivityMonitor {
  _FakeConnectivity(this.initialOnline);
  final bool initialOnline;
  @override
  Future<bool> isOnline() async => initialOnline;
  @override
  Stream<bool> get onConnectivityChanged => const Stream.empty();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late OfflineQueueDao queueDao;
  late WorkspaceDao workspaceDao;
  late OfflineQueueProcessor processor;

  setUpAll(() {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('UTC'));

    const channel = MethodChannel('dexterous.com/flutter/local_notifications');
    TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async => null);

    // Secure storage returns a key so the HTTP path (not the offline parser)
    // is exercised.
    const secure = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
    TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secure, (call) async {
      if (call.method == 'read') return 'test-key';
      return null;
    });
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    db = AppDatabase.forTesting(NativeDatabase.memory());
    queueDao = OfflineQueueDao(db);
    workspaceDao = WorkspaceDao(db);

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

  OfflineQueueProcessor buildProcessor(http.Client client) {
    return OfflineQueueProcessor(
      queueDao: queueDao,
      llmDataSource: LlmApiDataSource(client: client),
      executeAiActionUseCase: ExecuteAiActionUseCase(db),
      workspaceDao: workspaceDao,
      connectivityService: _FakeConnectivity(true),
    );
  }

  http.Response okIntent(Map<String, dynamic> intent) => http.Response(
        jsonEncode({
          'choices': [
            {
              'message': {'content': jsonEncode(intent)}
            }
          ]
        }),
        200,
      );

  Future<OfflineQueue> getItem(String id) =>
      (db.select(db.offlineQueues)..where((q) => q.id.equals(id))).getSingle();

  group('OfflineQueueProcessor', () {
    test('drains pending items and marks them processed when AI succeeds',
        () async {
      await queueDao.enqueueCapture(id: 'q-1', content: 'remind me to buy milk');
      processor = buildProcessor(MockClient(
          (_) async => okIntent({'intent_type': 'create_task', 'title': 'Buy milk'})));

      await processor.processQueue();

      expect((await getItem('q-1')).status, 'processed');

      // The task was actually created in the default workspace.
      final active = await ItemDao(db).getAllActive();
      expect(active.any((i) => i.title == 'Buy milk'), isTrue);
    });

    test('items failing repeatedly hit the shared cap and become failed',
        () async {
      await queueDao.enqueueCapture(id: 'q-fail', content: 'some capture');
      processor = buildProcessor(
          MockClient((_) async => http.Response('denied', 401)));

      for (var i = 0; i < OfflineQueueDao.maxAttempts; i++) {
        await processor.processQueue();
      }

      final item = await getItem('q-fail');
      expect(item.status, 'failed');
      expect(item.attempts, OfflineQueueDao.maxAttempts);

      // A further pass must not touch failed items.
      await processor.processQueue();
      expect((await getItem('q-fail')).attempts, OfflineQueueDao.maxAttempts);
    });

    test('resetFailedToPending re-queues failed items', () async {
      await queueDao.enqueueCapture(id: 'q-r', content: 'capture');
      processor = buildProcessor(
          MockClient((_) async => http.Response('denied', 401)));
      for (var i = 0; i < OfflineQueueDao.maxAttempts; i++) {
        await processor.processQueue();
      }
      expect(await queueDao.watchFailedCount().first, 1);

      await queueDao.resetFailedToPending();
      expect(await queueDao.watchFailedCount().first, 0);
      expect(await queueDao.watchPendingCount().first, 1);
    });

    test('destructive intents captured offline require review, never execute',
        () async {
      await queueDao.enqueueCapture(
          id: 'q-del', content: 'delete task buy milk');

      var notifications = 0;
      const notifChannel =
          MethodChannel('dexterous.com/flutter/local_notifications');
      TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(notifChannel, (call) async {
        if (call.method == 'show') notifications++;
        return null;
      });

      processor = buildProcessor(MockClient(
          (_) async => okIntent({'intent_type': 'delete_task', 'target_name': 'buy milk'})));

      await processor.processQueue();

      final item = await getItem('q-del');
      expect(item.status, 'processed'); // consumed, but only as a review ping
      expect(notifications, greaterThanOrEqualTo(1));
    });

    test('defers (stays pending) while no workspace exists', () async {
      await (db.delete(db.workspaces)).go();
      await queueDao.enqueueCapture(id: 'q-ws', content: 'buy milk');
      processor = buildProcessor(MockClient(
          (_) async => okIntent({'intent_type': 'create_task', 'title': 'Buy milk'})));

      await processor.processQueue();

      expect((await getItem('q-ws')).status, 'pending');
    });
  });
}
