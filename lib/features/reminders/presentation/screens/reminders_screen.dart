import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    return Scaffold(
      backgroundColor: AuraColors.bgBase,
      appBar: AppBar(
        title: Text('REMINDERS', style: AuraTypography.screenHeader),
        backgroundColor: AuraColors.bgBase,
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
              return Container(
                padding: const EdgeInsets.all(AuraSpacing.md),
                decoration: BoxDecoration(
                  color: AuraColors.bgCard,
                  border: Border.all(color: AuraColors.border, width: AuraSpacing.borderWidth),
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
                    const Icon(LucideIcons.bell, color: AuraColors.accentLime, size: 24),
                    const SizedBox(width: AuraSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(rem.title, style: AuraTypography.cardTitle),
                          const SizedBox(height: 2),
                          Text(
                            rem.fireAt != null
                                ? DateTime.fromMillisecondsSinceEpoch(rem.fireAt!).toString()
                                : 'Pending Reminder',
                            style: AuraTypography.bodySmall,
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
