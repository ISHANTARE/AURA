import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/router/app_router.dart';
import '../../../alarms/presentation/widgets/edit_alarm_modal.dart';
import '../../../capture/presentation/widgets/voice_capture_overlay.dart';
import '../../../reminders/domain/services/reminder_scheduling_service.dart';
import '../providers/home_providers.dart';

/// The Day Agenda task list supporting horizontal drag gestures and
/// separating Timed / Scheduled items from Anytime checklist tasks.
class DayAgendaView extends ConsumerWidget {
  const DayAgendaView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final agendaAsync = ref.watch(dayAgendaProvider);
    const accentColor = AuraColors.accentPrimary;

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        // Swipe Left: Next Day | Swipe Right: Previous Day
        if (details.primaryVelocity != null) {
          if (details.primaryVelocity! < -200) {
            ref.read(selectedDateProvider.notifier).state =
                selectedDate.add(const Duration(days: 1));
          } else if (details.primaryVelocity! > 200) {
            ref.read(selectedDateProvider.notifier).state =
                selectedDate.subtract(const Duration(days: 1));
          }
        }
      },
      child: agendaAsync.when(
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: CircularProgressIndicator(),
          ),
        ),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Error loading schedule: $err', style: AuraTypography.bodySmall),
          ),
        ),
        data: (agenda) {
          if (agenda.isEmpty) {
            return _EmptyDayState(
              selectedDate: selectedDate,
              accentColor: accentColor,
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Section 1: Timed & Scheduled ──────────────────────────────
              if (agenda.timedItems.isNotEmpty) ...[
                _SectionHeader(
                  title: 'SCHEDULED & TIMED',
                  icon: LucideIcons.clock,
                  count: agenda.timedItems.length,
                  accentColor: accentColor,
                ),
                const SizedBox(height: 8),
                ...agenda.timedItems.map((item) => _AgendaItemTile(item: item)),
                const SizedBox(height: 16),
              ],

              // ── Section 2: Anytime Today ──────────────────────────────────
              if (agenda.anytimeItems.isNotEmpty) ...[
                _SectionHeader(
                  title: 'ANYTIME',
                  icon: LucideIcons.checkSquare,
                  count: agenda.anytimeItems.length,
                  accentColor: accentColor,
                ),
                const SizedBox(height: 8),
                ...agenda.anytimeItems.map((item) => _AgendaItemTile(item: item)),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.count,
    required this.accentColor,
  });

  final String title;
  final IconData icon;
  final int count;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: accentColor),
        const SizedBox(width: 6),
        Text(
          title,
          style: AuraTypography.label.copyWith(
            color: AuraColors.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          decoration: BoxDecoration(
            color: AuraColors.bgElevated,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '$count',
            style: AuraTypography.caption.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AuraColors.textMuted,
            ),
          ),
        ),
      ],
    );
  }
}

class _AgendaItemTile extends ConsumerWidget {
  const _AgendaItemTile({required this.item});

  final Item item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDone = item.status == 'completed';
    final targetMs = item.startTime ?? item.fireAt ?? item.deadline;
    final targetDt = targetMs != null ? DateTime.fromMillisecondsSinceEpoch(targetMs) : null;
    final isAlarm = item.category == 'alarm' || item.kind == 'alarm';
    final isEvent = item.kind == 'event';

    String? timeLabel;
    if (targetDt != null) {
      if (isEvent && item.endTime != null) {
        final endDt = DateTime.fromMillisecondsSinceEpoch(item.endTime!);
        timeLabel = '${DateFormat('h:mm a').format(targetDt)} – ${DateFormat('h:mm a').format(endDt)}';
      } else {
        timeLabel = DateFormat('h:mm a').format(targetDt);
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AuraColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDone ? AuraColors.borderMuted : AuraColors.border,
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: () {
          if (isAlarm) {
            EditAlarmModal.show(context, ref, item);
          } else {
            context.push(Routes.taskRoute(item.id));
          }
        },
        child: Row(
          children: [
            // Checkbox for task completion (or Alarm Icon)
            if (isAlarm)
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AuraColors.accentRed.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.alarmClock, size: 15, color: AuraColors.accentRed),
              )
            else
              GestureDetector(
                onTap: () async {
                  final newStatus = isDone ? 'pending' : 'completed';
                  await ref.read(itemDaoProvider).updateStatus(item.id, newStatus);
                  if (newStatus == 'completed') {
                    await ReminderSchedulingService(
                      db: ref.read(databaseProvider),
                    ).cancelForItem(item.id);
                  } else {
                    await ReminderSchedulingService(
                      db: ref.read(databaseProvider),
                    ).syncForItem(item);
                  }
                },
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isDone ? AuraColors.accentGreen : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isDone ? AuraColors.accentGreen : AuraColors.border,
                      width: 1.5,
                    ),
                  ),
                  child: isDone
                      ? const Icon(LucideIcons.check, size: 15, color: Colors.black)
                      : null,
                ),
              ),

            const SizedBox(width: 12),

            // Main Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: AuraTypography.cardTitle.copyWith(
                      fontSize: 14,
                      decoration: isDone ? TextDecoration.lineThrough : null,
                      color: isDone ? AuraColors.textMuted : AuraColors.textPrimary,
                    ),
                  ),
                  if (item.notes?.isNotEmpty == true) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.notes!,
                      style: AuraTypography.bodySmall.copyWith(
                        fontSize: 11,
                        color: AuraColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // Time Pill & Badges
            if (timeLabel != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isAlarm
                      ? AuraColors.accentRed.withValues(alpha: 0.15)
                      : (isEvent
                          ? AuraColors.accentBlue.withValues(alpha: 0.15)
                          : AuraColors.bgElevated),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  timeLabel,
                  style: AuraTypography.caption.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isAlarm
                        ? AuraColors.accentRed
                        : (isEvent ? AuraColors.accentBlue : AuraColors.accentLime),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyDayState extends StatelessWidget {
  const _EmptyDayState({
    required this.selectedDate,
    required this.accentColor,
  });

  final DateTime selectedDate;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: AuraColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AuraColors.border, width: 1.5),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.calendarCheck, size: 40, color: AuraColors.textDisabled),
            const SizedBox(height: 12),
            Text(
              'No items scheduled',
              style: AuraTypography.cardTitle.copyWith(fontSize: 15),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap the floating orb to speak a task or reminder.',
              textAlign: TextAlign.center,
              style: AuraTypography.bodySmall.copyWith(color: AuraColors.textMuted),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              icon: const Icon(LucideIcons.mic, size: 14),
              label: const Text('VOICE CAPTURE'),
              style: OutlinedButton.styleFrom(
                foregroundColor: accentColor,
                side: BorderSide(color: accentColor),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => VoiceCaptureOverlay.show(context),
            ),
          ],
        ),
      ),
    );
  }
}
