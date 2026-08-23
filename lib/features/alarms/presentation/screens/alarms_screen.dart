import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/providers/providers.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../reminders/domain/services/reminder_scheduling_service.dart';

import '../widgets/edit_alarm_modal.dart';

/// Alarms Screen — AURA v2 Redesigned Alarms Screen
class AlarmsScreen extends ConsumerWidget {
  const AlarmsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alarmsAsync = ref.watch(alarmsListProvider);
    final itemDao = ref.watch(itemDaoProvider);
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: AuraColors.bgBase,
      appBar: AppBar(
        title: Text('ALARMS', style: AuraTypography.screenHeader),
        backgroundColor: AuraColors.bgBase,
        elevation: 0,
      ),
      body: alarmsAsync.when(
        data: (alarms) {
          if (alarms.isEmpty) {
            return const AuraEmptyState(
              icon: LucideIcons.alarmClock,
              title: 'No Active Alarms',
              subtitle:
                  'Tap the AURA orb or say "Set an alarm for 7 AM" to create one.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AuraSpacing.md),
            itemCount: alarms.length,
            separatorBuilder: (_, __) => const SizedBox(height: AuraSpacing.sm),
            itemBuilder: (context, index) {
              final alarm = alarms[index];
              final fireAtDt = alarm.fireAt != null
                  ? DateTime.fromMillisecondsSinceEpoch(alarm.fireAt!)
                  : null;

              final timeStr = fireAtDt != null
                  ? DateFormat('h:mm a').format(fireAtDt)
                  : 'Daily Alarm';

              final dateStr = fireAtDt != null
                  ? DateFormat('EEE, MMM d').format(fireAtDt)
                  : 'Active';

              return InkWell(
                onTap: () => EditAlarmModal.show(context, ref, alarm),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: AuraColors.bgCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AuraColors.border, width: 1),
                    boxShadow: const [
                      BoxShadow(
                        color: AuraColors.shadow,
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AuraSpacing.md, vertical: 16),
                    child: Row(
                      children: [
                        // Circular icon container
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(LucideIcons.alarmClock, color: primaryColor, size: 26),
                        ),
                        const SizedBox(width: AuraSpacing.md),
                        // Time + label
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                timeStr,
                                style: AuraTypography.display.copyWith(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                  color: AuraColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${alarm.title} · $dateStr',
                                style: AuraTypography.caption,
                              ),
                            ],
                          ),
                        ),
                        // Edit button
                        IconButton(
                          icon: Icon(LucideIcons.edit2, color: primaryColor, size: 18),
                          onPressed: () => EditAlarmModal.show(context, ref, alarm),
                        ),
                        // Delete button
                        IconButton(
                          icon: const Icon(LucideIcons.trash2,
                              color: AuraColors.textMuted, size: 20),
                          onPressed: () async {
                            HapticFeedback.mediumImpact();
                            // Cancel every notification variant first, then
                            // soft-delete the row.
                            await ref
                                .read(reminderSchedulingServiceProvider)
                                .cancelForItem(alarm.id);
                            await itemDao.softDelete(alarm.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Alarm deleted'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) =>
            Center(child: Text('Error: $err', style: AuraTypography.body)),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: () => EditAlarmModal.showCreate(context, ref),
        child: const Icon(LucideIcons.plus, size: 24),
      ),
    );
  }
}
