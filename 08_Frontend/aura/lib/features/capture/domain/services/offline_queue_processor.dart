import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/connectivity_service.dart';
import '../../../../database/app_database.dart';
import '../../../../database/daos/offline_queue_dao.dart';
import '../../data/datasources/llm_api_datasource.dart';
import '../usecases/create_task_usecase.dart';

/// Processor for offline captured transcripts (PRD F-10).
/// Listens to network status and automatically processes queued captures when back online.
class OfflineQueueProcessor {
  final OfflineQueueDao _queueDao;
  final LlmApiDataSource _llmDataSource;
  final CreateTaskUseCase _createTaskUseCase;
  final ConnectivityService _connectivityService;

  StreamSubscription<bool>? _connectivitySub;
  bool _isProcessing = false;

  OfflineQueueProcessor({
    required OfflineQueueDao queueDao,
    required LlmApiDataSource llmDataSource,
    required CreateTaskUseCase createTaskUseCase,
    required ConnectivityService connectivityService,
  })  : _queueDao = queueDao,
        _llmDataSource = llmDataSource,
        _createTaskUseCase = createTaskUseCase,
        _connectivityService = connectivityService;

  /// Start monitoring connectivity and process queue when online.
  void start() {
    _connectivitySub = _connectivityService.onConnectivityChanged.listen((isOnline) {
      if (isOnline) {
        processQueue();
      }
    });

    // Check immediately on startup
    _connectivityService.isOnline().then((online) {
      if (online) processQueue();
    });
  }

  /// Stop processor.
  void stop() {
    _connectivitySub?.cancel();
    _subscriptionNull();
  }

  void _subscriptionNull() {
    _connectivitySub = null;
  }

  /// Process all pending offline captures sequentially.
  Future<void> processQueue() async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      final pending = await _queueDao.getPendingItems();
      if (pending.isEmpty) {
        _isProcessing = false;
        return;
      }

      for (final item in pending) {
        try {
          // 1. Extract intent using LLM API
          final intent = await _llmDataSource.extractIntent(
            transcript: item.content,
          );

          // 2. Default workspace selection ('General' or hint)
          const workspaceId = 'w-general';

          // 3. Commit task using CreateTaskUseCase
          await _createTaskUseCase.execute(
            intent: intent,
            workspaceId: workspaceId,
            originalTranscript: item.content,
          );

          // 4. Mark item as processed
          await _queueDao.markProcessed(item.id);
        } catch (_) {
          // If LLM call or creation fails, increment attempt count
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
  final llmDataSource = LlmApiDataSource();
  final createTaskUseCase = CreateTaskUseCase(db);
  final connectivityService = ref.watch(connectivityServiceProvider);

  final processor = OfflineQueueProcessor(
    queueDao: queueDao,
    llmDataSource: llmDataSource,
    createTaskUseCase: createTaskUseCase,
    connectivityService: connectivityService,
  );

  processor.start();
  ref.onDispose(processor.stop);
  return processor;
});
