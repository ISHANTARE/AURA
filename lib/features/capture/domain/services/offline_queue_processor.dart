import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/providers.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../reminders/data/services/notification_service.dart';
import '../../../reminders/domain/services/notification_ids.dart';
import '../../data/datasources/llm_api_datasource.dart';
import '../usecases/execute_ai_action_usecase.dart';

/// Processor for offline captured transcripts (PRD F-10).
/// Listens to network status and automatically processes queued captures when back online.
///
/// Fixes applied (Audit FIX-04):
///   1. Routes ALL intent types through [ExecuteAiActionUseCase] (not just create_task).
///   2. Resolves workspace dynamically from DB — never hardcodes 'w-general'.
///   3. Caps retry attempts at [_maxAttempts] to prevent an infinite retry loop.
class OfflineQueueProcessor {
  final OfflineQueueDao _queueDao;
  final LlmApiDataSource _llmDataSource;
  final ExecuteAiActionUseCase _executeAiActionUseCase;
  final WorkspaceDao _workspaceDao;
  final ConnectivityMonitor _connectivityService;

  StreamSubscription<bool>? _connectivitySub;
  bool _isProcessing = false;

  OfflineQueueProcessor({
    required OfflineQueueDao queueDao,
    required LlmApiDataSource llmDataSource,
    required ExecuteAiActionUseCase executeAiActionUseCase,
    required WorkspaceDao workspaceDao,
    required ConnectivityMonitor connectivityService,
  })  : _queueDao = queueDao,
        _llmDataSource = llmDataSource,
        _executeAiActionUseCase = executeAiActionUseCase,
        _workspaceDao = workspaceDao,
        _connectivityService = connectivityService;

  /// Start monitoring connectivity and process queue when online.
  void start() {
    _connectivitySub = _connectivityService.onConnectivityChanged.listen((isOnline) {
      if (isOnline) processQueue();
    });

    // Check immediately on startup.
    _connectivityService.isOnline().then((online) {
      if (online) processQueue();
    });
  }

  /// Stop processor.
  void stop() {
    _connectivitySub?.cancel();
    _connectivitySub = null;
  }

  /// Process all pending offline captures sequentially.
  Future<void> processQueue() async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      final pending = await _queueDao.getPendingItems();
      if (pending.isEmpty) return;

      // Resolve the fallback workspace once per batch.
      final workspaces = await _workspaceDao.getAll();
      final defaultWorkspace = workspaces.firstOrNull;

      for (final item in pending) {
        // Items already at the shared retry cap are marked failed, not
        // processed — they stay visible to the user via the FAILED badge.
        if (item.attempts >= OfflineQueueDao.maxAttempts) {
          await _queueDao.markFailed(item.id);
          continue;
        }

        // If no workspace exists yet, defer this item until the user creates one.
        if (defaultWorkspace == null) {
          await _queueDao.incrementAttempt(item.id, item.attempts);
          continue;
        }

        try {
          // 1. Extract intent using LLM API or local fallback.
          final intent = await _llmDataSource.extractIntent(
            transcript: item.content,
          );

          // 2. Safeguard: Destructive intents (delete_task, delete_workspace) captured offline
          // MUST NOT execute silently in the background (ADR-004 compliance).
          if (intent.intentType == 'delete_task' || intent.intentType == 'delete_workspace') {
            await NotificationService().showInstantNotification(
              id: NotificationIds.offlineReview,
              title: 'Pending Offline Action Review',
              body: 'Voice request "${item.content}" requires your confirmation to execute.',
              payload: 'route:/search',
            );
            await _queueDao.markProcessed(item.id);
            continue;
          }

          // 3. Execute creation intent (creates task/alarm/workspace/note)
          final resultMsg = await _executeAiActionUseCase.execute(
            intent: intent,
            workspaceId: defaultWorkspace.id,
            originalTranscript: item.content,
          );

          // 4. Notify user that offline voice capture was processed (Human-in-the-Loop)
          await NotificationService().showInstantNotification(
            id: NotificationIds.offlineReview,
            title: 'Offline Voice Capture Processed',
            body: '$resultMsg. Tap to review.',
            payload: 'route:/',
          );

          // 5. Mark item as successfully processed.
          await _queueDao.markProcessed(item.id);
        } catch (e, st) {
          // On failure increment the attempt counter; log so persistent
          // failures are diagnosable instead of silently retried.
          debugPrint('OfflineQueueProcessor: item ${item.id} failed: $e\n$st');
          await _queueDao.incrementAttempt(item.id, item.attempts);
        }
      }
    } finally {
      _isProcessing = false;
    }
  }
}

// ── Riverpod Provider ─────────────────────────────────────────────────────────

final offlineQueueProcessorProvider = Provider<OfflineQueueProcessor>((ref) {
  final db = ref.watch(databaseProvider);
  final queueDao = ref.watch(offlineQueueDaoProvider);
  final workspaceDao = ref.watch(workspaceDaoProvider);
  final llmDataSource = LlmApiDataSource();
  final executeAiActionUseCase = ExecuteAiActionUseCase(db);
  final connectivityService = ref.watch(connectivityServiceProvider);

  final processor = OfflineQueueProcessor(
    queueDao: queueDao,
    llmDataSource: llmDataSource,
    executeAiActionUseCase: executeAiActionUseCase,
    workspaceDao: workspaceDao,
    connectivityService: connectivityService,
  );

  processor.start();
  ref.onDispose(processor.stop);
  return processor;
});
