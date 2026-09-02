import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/providers/providers.dart';
import '../../../../core/widgets/empty_state.dart';

/// Reminders Screen — AURA v2 Reminders List
class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeItemsAsync = ref.watch(allActiveItemsProvider);
    final primaryColor = Theme.of(context).colorScheme.primary;

    final bg = AuraColors.bgOf(context);
    final cardBg = AuraColors.cardOf(context);
    final borderColor = AuraColors.borderOf(context);
    final textPrimary = AuraColors.textPrimaryOf(context);
    final textSecondary = AuraColors.textSecondaryOf(context);
    final isDark = AuraColors.isDarkMode(context);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text('REMINDERS', style: AuraTypography.screenHeader.copyWith(color: textPrimary)),
        backgroundColor: bg,
        elevation: 0,
      ),
      body: activeItemsAsync.when(
        data: (items) {
          final reminders = items.where((i) => i.category == 'reminder').toList();

          if (reminders.isEmpty) {
            return const AuraEmptyState(
              icon: LucideIcons.bell,
              title: 'No Pending Reminders',
              subtitle: 'Tap the AURA orb or say "Remind me to submit assignment tomorrow at 5 PM".',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AuraSpacing.md),
            itemCount: reminders.length,
            separatorBuilder: (_, __) => const SizedBox(height: AuraSpacing.sm),
            itemBuilder: (context, index) {
              final rem = reminders[index];
              final fireAtDt = rem.fireAt != null
                  ? DateTime.fromMillisecondsSinceEpoch(rem.fireAt!)
                  : null;
              final timeStr = fireAtDt != null
                  ? DateFormat('EEE, MMM d · h:mm a').format(fireAtDt)
                  : 'Pending Reminder';

              return Container(
                padding: const EdgeInsets.all(AuraSpacing.md),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderColor, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? AuraColors.shadow : AuraColors.lightShadow,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(LucideIcons.bell, color: primaryColor, size: 20),
                    ),
                    const SizedBox(width: AuraSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rem.title,
                            style: AuraTypography.cardTitle.copyWith(color: textPrimary),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            timeStr,
                            style: AuraTypography.bodySmall.copyWith(color: textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err', style: AuraTypography.body)),
      ),
    );
  }
}
