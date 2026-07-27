import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../database/daos/offline_queue_dao.dart';

/// Sync Status & Connectivity Badge (Sprint 7 / PRD F-10).
/// Shows live network state and pending offline queue item count.
class SyncStatusBadge extends ConsumerWidget {
  const SyncStatusBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnlineAsync = ref.watch(isOnlineProvider);
    final isOnline = isOnlineAsync.value ?? true;
    final queueDao = ref.watch(offlineQueueDaoProvider);

    return StreamBuilder<int>(
      stream: queueDao.watchPendingCount(),
      builder: (context, snapshot) {
        final pendingCount = snapshot.data ?? 0;

        Color badgeColor;
        String labelText;
        IconData iconData;

        if (!isOnline) {
          badgeColor = AuraColors.accentOrange;
          labelText = pendingCount > 0
              ? 'OFFLINE · $pendingCount QUEUED'
              : 'OFFLINE MODE';
          iconData = Icons.wifi_off_rounded;
        } else if (pendingCount > 0) {
          badgeColor = AuraColors.accentLime;
          labelText = 'SYNCING · $pendingCount ITEMS';
          iconData = Icons.sync_rounded;
        } else {
          badgeColor = AuraColors.accentGreen;
          labelText = 'SYNCED';
          iconData = Icons.check_circle_outline_rounded;
        }

        return Container(
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
        );
      },
    );
  }
}
