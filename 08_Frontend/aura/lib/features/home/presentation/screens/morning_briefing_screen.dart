import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:aura/core/constants/colors.dart';
import 'package:aura/core/constants/typography.dart';
import 'package:aura/core/router/app_router.dart';
import 'package:aura/database/daos/event_dao.dart';
import 'package:aura/database/daos/notification_dao.dart';
import 'package:aura/database/daos/reminder_dao.dart';
import 'package:aura/database/daos/task_dao.dart';
import '../../domain/usecases/generate_morning_briefing_usecase.dart';

final morningBriefingUseCaseProvider = Provider<GenerateMorningBriefingUseCase>((ref) {
  return GenerateMorningBriefingUseCase(
    taskDao: ref.watch(taskDaoProvider),
    eventDao: ref.watch(eventDaoProvider),
    reminderDao: ref.watch(reminderDaoProvider),
    notificationDao: ref.watch(notificationDaoProvider),
  );
});

final morningBriefingDataProvider = FutureProvider<MorningBriefingData>((ref) async {
  return ref.watch(morningBriefingUseCaseProvider).execute();
});

class MorningBriefingScreen extends ConsumerWidget {
  const MorningBriefingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final briefingAsync = ref.watch(morningBriefingDataProvider);

    return Scaffold(
      backgroundColor: AuraColors.bgBase,
      body: SafeArea(
        child: briefingAsync.when(
          data: (data) => Column(
            children: [
              // Top Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox.shrink(),
                    IconButton(
                      icon: const Icon(LucideIcons.x, color: AuraColors.textSecondary),
                      onPressed: () => context.go(Routes.home),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Text(data.greeting, style: AuraTypography.display),
                      const SizedBox(height: 4),
                      Text(data.dateFormatted, style: AuraTypography.bodySmall),
                      const SizedBox(height: 16),

                      // AI Summary Line
                      Text(
                        '── ${data.summaryLine} ──',
                        style: AuraTypography.bodySmall.copyWith(
                          fontStyle: FontStyle.italic,
                          color: AuraColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Section 1: URGENT
                      if (data.urgentTasks.isNotEmpty) ...[
                        _BriefingCard(
                          title: '🔴 URGENT',
                          titleColor: AuraColors.accentRed,
                          children: data.urgentTasks.map((t) => ListTile(
                                leading: const Icon(LucideIcons.alertTriangle, color: AuraColors.accentRed, size: 16),
                                title: Text(t.name, style: AuraTypography.cardTitle),
                                trailing: const Icon(LucideIcons.chevronRight, color: AuraColors.textSecondary, size: 16),
                                onTap: () => context.push(Routes.taskRoute(t.id)),
                              )).toList(),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Section 2: TODAY'S FOCUS
                      _BriefingCard(
                        title: '🎯 TODAY\'S FOCUS',
                        titleColor: AuraColors.accentLime,
                        badge: 'AI suggested 🤖',
                        children: data.focusTasks.isEmpty
                            ? [
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Text('All clear today!', style: AuraTypography.bodySmall),
                                )
                              ]
                            : data.focusTasks.asMap().entries.map((entry) {
                                final idx = entry.key + 1;
                                final t = entry.value;
                                return ListTile(
                                  leading: CircleAvatar(
                                    radius: 12,
                                    backgroundColor: AuraColors.accentLime,
                                    child: Text('$idx', style: AuraTypography.badgeText.copyWith(color: AuraColors.textOnAccent)),
                                  ),
                                  title: Text(t.name, style: AuraTypography.cardTitle),
                                  trailing: const Icon(LucideIcons.chevronRight, color: AuraColors.textSecondary, size: 16),
                                  onTap: () => context.push(Routes.taskRoute(t.id)),
                                );
                              }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // Section 3: UPCOMING
                      if (data.upcomingTasks.isNotEmpty) ...[
                        _BriefingCard(
                          title: '📅 UPCOMING',
                          titleColor: AuraColors.accentBlue,
                          subtitle: 'Next 7 days',
                          children: data.upcomingTasks.map((t) => ListTile(
                                leading: const Icon(LucideIcons.calendar, color: AuraColors.accentBlue, size: 16),
                                title: Text(t.name, style: AuraTypography.cardTitle),
                                trailing: const Icon(LucideIcons.chevronRight, color: AuraColors.textSecondary, size: 16),
                                onTap: () => context.push(Routes.taskRoute(t.id)),
                              )).toList(),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Section 4: DND Missed items (Conditional)
                      if (data.missedDndReminders.isNotEmpty) ...[
                        _BriefingCard(
                          title: '🔕 WHILE YOU WERE IN DND',
                          titleColor: AuraColors.accentOrange,
                          children: data.missedDndReminders.map((r) => ListTile(
                                leading: const Icon(LucideIcons.bellOff, color: AuraColors.accentOrange, size: 16),
                                title: Text('Missed reminder (ID: ${r.id})', style: AuraTypography.bodySmall),
                              )).toList(),
                        ),
                        const SizedBox(height: 16),
                      ],

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // Bottom CTA: START MY DAY
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () => context.go(Routes.home),
                    icon: const Icon(LucideIcons.play, size: 18, color: AuraColors.textOnAccent),
                    label: Text(
                      'START MY DAY',
                      style: AuraTypography.buttonText.copyWith(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AuraColors.accentLime,
                      foregroundColor: AuraColors.textOnAccent,
                      elevation: 0,
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    ),
                  ),
                ),
              ),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator(color: AuraColors.accentLime)),
          error: (e, s) => Center(child: Text('Error: $e', style: AuraTypography.body)),
        ),
      ),
    );
  }
}

class _BriefingCard extends StatelessWidget {
  final String title;
  final Color titleColor;
  final String? subtitle;
  final String? badge;
  final List<Widget> children;

  const _BriefingCard({
    required this.title,
    required this.titleColor,
    this.subtitle,
    this.badge,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AuraColors.bgCard,
        border: Border.all(color: AuraColors.border, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(title, style: AuraTypography.bentoMetricLabel.copyWith(color: titleColor)),
                    if (subtitle != null) ...[
                      const SizedBox(width: 8),
                      Text('· $subtitle', style: AuraTypography.bodySmall),
                    ],
                  ],
                ),
                if (badge != null)
                  Text(badge!, style: AuraTypography.bodySmall.copyWith(color: AuraColors.textSecondary)),
              ],
            ),
          ),
          const Divider(color: AuraColors.borderMuted, height: 1),
          ...children,
        ],
      ),
    );
  }
}
