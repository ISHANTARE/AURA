import 'dart:convert';

import '../../../database/daos/offline_queue_dao.dart';
import '../../capture/domain/execute_ai_action_usecase.dart';
import '../../capture/domain/extracted_intent.dart';
import '../../capture/domain/local_intent_parser.dart';

/// Processor for draining offline queued voice transcripts and actions when connectivity is restored.
class OfflineQueueProcessor {
  final OfflineQueueDao _offlineQueueDao;
  final ExecuteAiActionUseCase _executeAiActionUseCase;

  OfflineQueueProcessor({
    required OfflineQueueDao offlineQueueDao,
    required ExecuteAiActionUseCase executeAiActionUseCase,
  })  : _offlineQueueDao = offlineQueueDao,
        _executeAiActionUseCase = executeAiActionUseCase;

  bool _isProcessing = false;

  /// Drains all pending FIFO items from the offline queue.
  ///
  /// Safe to call on network reconnection or app foregrounding.
  /// Destructive actions (delete_task, delete_workspace) queued offline are flagged
  /// or skipped if required by user review rules.
  Future<int> drainQueue({bool requireReviewForDestructive = true}) async {
    if (_isProcessing) return 0;
    _isProcessing = true;

    int processedCount = 0;
    try {
      final pendingItems = await _offlineQueueDao.getPendingItems();
      final nowMs = DateTime.now().millisecondsSinceEpoch;

      for (final queueItem in pendingItems) {
        if (queueItem.attempts >= 5) {
          // Cap reached: skip stale/corrupted entries
          continue;
        }

        try {
          // Increment attempt count
          await _offlineQueueDao.incrementAttempt(queueItem.id, queueItem.attempts);

          final ExtractedIntent intent;
          final String transcript = queueItem.content;

          if (queueItem.type == 'action') {
            final payload = jsonDecode(queueItem.content) as Map<String, dynamic>;
            intent = ExtractedIntent.fromJson(payload);
          } else {
            // Raw transcript queued while offline
            intent = LocalIntentParser.parse(queueItem.content);
          }

          // Safeguard: Check if this is a destructive action requiring review
          final isDestructive = intent.intentType == 'delete_task' || intent.intentType == 'delete_workspace';
          if (isDestructive && requireReviewForDestructive) {
            // Leave in pending status for explicit user confirmation in UI
            continue;
          }

          // Execute action
          await _executeAiActionUseCase.execute(
            intent: intent,
            rawTranscript: transcript,
            assignedWorkspaceId: intent.workspaceHint,
          );

          // Mark processed
          await _offlineQueueDao.markProcessed(queueItem.id, nowMs);
          processedCount++;
        } catch (_) {
          // Attempt failed; will retry on next drain cycle up to 5 attempts
        }
      }
    } finally {
      _isProcessing = false;
    }

    return processedCount;
  }
}
