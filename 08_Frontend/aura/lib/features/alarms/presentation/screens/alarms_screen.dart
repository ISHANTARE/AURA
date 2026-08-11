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

/// Alarms Screen — AURA v2 Dedicated Alarms & Time Alerts Screen
class AlarmsScreen extends ConsumerWidget {
  const AlarmsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alarmsAsync = ref.watch(alarmsListProvider);
    final itemDao = ref.watch(itemDaoProvider);

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

              return Container(
                padding: const EdgeInsets.all(AuraSpacing.md),
                decoration: BoxDecoration(
                  color: AuraColors.bgCard,
                  border: Border.all(
                      color: AuraColors.border, width: AuraSpacing.borderWidth),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black,
                      offset: Offset(4, 4),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AuraSpacing.xs + 2),
                      decoration: BoxDecoration(
                        color: AuraColors.accentLime.withValues(alpha: 0.15),
                        border: Border.all(color: AuraColors.accentLime),
                      ),
                      child: const Icon(LucideIcons.alarmClock,
                          color: AuraColors.accentLime, size: 24),
                    ),
                    const SizedBox(width: AuraSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            timeStr,
                            style: AuraTypography.cardTitle.copyWith(
                              fontSize: 22,
                              color: AuraColors.accentLime,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${alarm.title} · $dateStr',
                            style: AuraTypography.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.trash2,
                          color: AuraColors.textSecondary, size: 20),
                      onPressed: () async {
                        HapticFeedback.mediumImpact();
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
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AuraColors.accentLime),
          ),
        ),
        error: (err, _) =>
            Center(child: Text('Error: $err', style: AuraTypography.body)),
      ),
    );
  }
}
