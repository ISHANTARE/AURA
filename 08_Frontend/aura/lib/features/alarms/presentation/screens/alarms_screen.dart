import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:drift/drift.dart' hide Column;

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/constants/typography.dart';
import '../../../../database/app_database.dart';

/// Alarms Screen — Dedicated Alarms & Time Alerts tab (Sprint 8)
class AlarmsScreen extends ConsumerWidget {
  const AlarmsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);

    return Scaffold(
      backgroundColor: AuraColors.bgBase,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(AuraSpacing.md),
              child: Row(
                children: [
                  const Icon(LucideIcons.alarmClock, color: AuraColors.accentOrange, size: 24),
                  const SizedBox(width: AuraSpacing.xs),
                  Text('Alarms & Time Alerts', style: AuraTypography.sectionHeader),
                ],
              ),
            ),

            // Alarms List
            Expanded(
              child: StreamBuilder<List<Reminder>>(
                stream: (db.select(db.reminders)
                      ..where((r) => r.type.equals('alarm'))
                      ..orderBy([(r) => OrderingTerm.asc(r.fireAt)]))
                    .watch(),
                builder: (context, snapshot) {
                  final alarms = snapshot.data ?? [];

                  if (alarms.isEmpty) {
                    return _buildEmptyAlarms();
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(AuraSpacing.md),
                    itemCount: alarms.length,
                    itemBuilder: (context, i) {
                      final item = alarms[i];
                      final dt = DateTime.fromMillisecondsSinceEpoch(item.fireAt);
                      final isPending = item.status == 'pending';

                      return Container(
                        margin: const EdgeInsets.only(bottom: AuraSpacing.sm),
                        padding: const EdgeInsets.all(AuraSpacing.md),
                        decoration: BoxDecoration(
                          color: AuraColors.bgCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isPending ? AuraColors.accentOrange : AuraColors.borderMuted,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              _formatTime(dt),
                              style: AuraTypography.display.copyWith(
                                fontSize: 26,
                                color: isPending ? AuraColors.textPrimary : AuraColors.textDisabled,
                              ),
                            ),
                            const Spacer(),
                            Switch(
                              value: isPending,
                              activeColor: AuraColors.accentOrange,
                              onChanged: (val) async {
                                final newStatus = val ? 'pending' : 'cancelled';
                                await (db.update(db.reminders)
                                      ..where((r) => r.id.equals(item.id)))
                                    .write(RemindersCompanion(status: Value(newStatus)));
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    final minuteStr = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minuteStr $ampm';
  }

  Widget _buildEmptyAlarms() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AuraColors.accentOrange.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: AuraColors.accentOrange.withValues(alpha: 0.4), width: 1.5),
            ),
            child: const Icon(LucideIcons.alarmClock, color: AuraColors.accentOrange, size: 28),
          ),
          const SizedBox(height: AuraSpacing.md),
          Text('No alarms set', style: AuraTypography.sectionHeader),
          const SizedBox(height: AuraSpacing.xs),
          Text(
            'Tap the floating orb and say:\n"Set an alarm for 7 AM tomorrow"',
            style: AuraTypography.body.copyWith(color: AuraColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
