import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/providers/providers.dart';
import '../../../capture/domain/services/offline_queue_processor.dart';

/// Sync Status & Connectivity Badge (Sprint 7 / PRD F-10).
/// Shows live network state and pending offline queue item count.
/// Failed items surface as a tappable "RETRY" state that re-queues them.
class SyncStatusBadge extends ConsumerWidget {
  const SyncStatusBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider).value ?? true;
    final queueDao = ref.watch(offlineQueueDaoProvider);

    return StreamBuilder<int>(
      stream: queueDao.watchPendingCount(),
      builder: (context, pendingSnap) {
        return StreamBuilder<int>(
          stream: queueDao.watchFailedCount(),
          builder: (context, failedSnap) {
            final pendingCount = pendingSnap.data ?? 0;
            final failedCount = failedSnap.data ?? 0;

            Color badgeColor;
            String labelText;
            IconData iconData;
            final tapToRetry = failedCount > 0 && isOnline && pendingCount == 0;

            if (!isOnline) {
              badgeColor = AuraColors.accentOrange;
              labelText = pendingCount > 0
                  ? 'OFFLINE · $pendingCount QUEUED'
                  : 'OFFLINE MODE';
              iconData = Icons.wifi_off_rounded;
            } else if (tapToRetry) {
              badgeColor = AuraColors.accentOrange;
              labelText = '$failedCount FAILED · TAP RETRY';
              iconData = Icons.error_outline_rounded;
            } else if (pendingCount > 0) {
              badgeColor = AuraColors.accentLime;
              labelText = 'SYNCING · $pendingCount ITEMS';
              iconData = Icons.sync_rounded;
            } else {
              badgeColor = AuraColors.accentGreen;
              labelText = 'SYNCED';
              iconData = Icons.check_circle_outline_rounded;
            }

            return InkWell(
              onTap: tapToRetry ? () => _retryFailed(ref) : null,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AuraSpacing.sm,
                  vertical: AuraSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: badgeColor.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(iconData, size: 12, color: badgeColor),
                    const SizedBox(width: 4),
                    Text(
                      labelText,
                      style: AuraTypography.label.copyWith(
                        color: badgeColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _retryFailed(WidgetRef ref) async {
    await ref.read(offlineQueueDaoProvider).resetFailedToPending();
    await ref.read(offlineQueueProcessorProvider).processQueue();
  }
}
