import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/typography.dart';
import '../providers/home_providers.dart';

/// 3-part Date Navigator with Compact Mini-Week Dot Strip and Day Status Filter.
class AuraDateNavigator extends ConsumerWidget {
  const AuraDateNavigator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final activeFilter = ref.watch(selectedDayFilterProvider);
    final agendaAsync = ref.watch(dayAgendaProvider);
    final weekActivityAsync = ref.watch(weekActivityMapProvider(selectedDate));
    const accentColor = AuraColors.accentPrimary;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isToday = selectedDate.year == today.year &&
        selectedDate.month == today.month &&
        selectedDate.day == today.day;
    final isTomorrow = selectedDate.difference(today).inDays == 1 &&
        selectedDate.day != today.day;
    final isYesterday = today.difference(selectedDate).inDays == 1 &&
        selectedDate.day != today.day;

    String dateLabel;
    if (isToday) {
      dateLabel = 'Today · ${DateFormat('EEE, MMM d').format(selectedDate)}';
    } else if (isTomorrow) {
      dateLabel = 'Tomorrow · ${DateFormat('EEE, MMM d').format(selectedDate)}';
    } else if (isYesterday) {
      dateLabel = 'Yesterday · ${DateFormat('EEE, MMM d').format(selectedDate)}';
    } else {
      dateLabel = DateFormat('EEEE, MMM d').format(selectedDate);
    }

    final agenda = agendaAsync.value ??
        const DayAgendaModel(
          timedItems: [],
          anytimeItems: [],
          totalPending: 0,
          totalCompleted: 0,
        );

    final weekActivity = weekActivityAsync.value ?? <String, int>{};

    // Calculate Monday of the selected week
    final weekday = selectedDate.weekday; // 1 = Mon, 7 = Sun
    final monday = selectedDate.subtract(Duration(days: weekday - 1));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AuraColors.bgCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AuraColors.border, width: 2),
      ),
      child: Column(
        children: [
          // ── Top: 3-Part Date Switcher ───────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Prev Day Button
              IconButton(
                icon: const Icon(LucideIcons.chevronLeft, size: 20),
                color: AuraColors.textPrimary,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                onPressed: () {
                  ref.read(selectedDateProvider.notifier).state =
                      selectedDate.subtract(const Duration(days: 1));
                },
              ),

              // Date Label Button (Tapping opens Calendar Picker)
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2035),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.dark(
                            primary: AuraColors.accentPrimary,
                            surface: AuraColors.bgCard,
                            onSurface: AuraColors.textPrimary,
                          ),
                          dialogTheme: const DialogThemeData(
                            backgroundColor: AuraColors.bgElevated,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    ref.read(selectedDateProvider.notifier).state =
                        DateTime(picked.year, picked.month, picked.day);
                  }
                },
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(LucideIcons.calendar, size: 14, color: AuraColors.accentPrimary),
                      const SizedBox(width: 6),
                      Text(
                        dateLabel,
                        style: AuraTypography.cardTitle.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isToday ? AuraColors.accentPrimary : AuraColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(LucideIcons.chevronDown, size: 13, color: AuraColors.textSecondary),
                    ],
                  ),
                ),
              ),

              // Next Day Button
              IconButton(
                icon: const Icon(LucideIcons.chevronRight, size: 20),
                color: AuraColors.textPrimary,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                onPressed: () {
                  ref.read(selectedDateProvider.notifier).state =
                      selectedDate.add(const Duration(days: 1));
                },
              ),
            ],
          ),

          const SizedBox(height: 8),

          // ── Middle: Compact Mini-Week Strip ────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final dayDate = monday.add(Duration(days: index));
              final isSelectedDay = dayDate.year == selectedDate.year &&
                  dayDate.month == selectedDate.month &&
                  dayDate.day == selectedDate.day;
              final isCurrentToday = dayDate.year == today.year &&
                  dayDate.month == today.month &&
                  dayDate.day == today.day;

              final key =
                  '${dayDate.year}-${dayDate.month.toString().padLeft(2, '0')}-${dayDate.day.toString().padLeft(2, '0')}';
              final taskCount = weekActivity[key] ?? 0;

              const dayNames = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    ref.read(selectedDateProvider.notifier).state =
                        DateTime(dayDate.year, dayDate.month, dayDate.day);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelectedDay
                          ? accentColor.withValues(alpha: 0.15)
                          : (isCurrentToday
                              ? AuraColors.bgElevated
                              : Colors.transparent),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelectedDay
                            ? accentColor
                            : (isCurrentToday ? AuraColors.border : Colors.transparent),
                        width: isSelectedDay ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          dayNames[index],
                          style: AuraTypography.caption.copyWith(
                            fontSize: 10,
                            color: isSelectedDay
                                ? accentColor
                                : AuraColors.textSecondary,
                            fontWeight: isSelectedDay ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${dayDate.day}',
                          style: AuraTypography.badgeText.copyWith(
                            fontSize: 13,
                            color: isSelectedDay
                                ? AuraColors.textPrimary
                                : AuraColors.textMuted,
                            fontWeight:
                                isSelectedDay ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 3),
                        // Activity Dots Indicator
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (taskCount > 0)
                              Container(
                                width: 4,
                                height: 4,
                                margin: const EdgeInsets.symmetric(horizontal: 1),
                                decoration: BoxDecoration(
                                  color: isSelectedDay
                                      ? accentColor
                                      : AuraColors.accentPrimary,
                                  shape: BoxShape.circle,
                                ),
                              )
                            else
                              const SizedBox(height: 4),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 10),
          const Divider(color: AuraColors.border, height: 1),
          const SizedBox(height: 8),

          // ── Bottom: Day Status Text with Tap-To-Filter Toggle ───────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Pending / Done Text Switcher
              Row(
                children: [
                  // Pending Pill
                  GestureDetector(
                    onTap: () {
                      ref.read(selectedDayFilterProvider.notifier).state =
                          activeFilter == DayFilter.pendingOnly
                              ? DayFilter.all
                              : DayFilter.pendingOnly;
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: activeFilter == DayFilter.pendingOnly
                            ? accentColor.withValues(alpha: 0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: activeFilter == DayFilter.pendingOnly
                              ? accentColor
                              : Colors.transparent,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '${agenda.totalPending} Pending',
                        style: AuraTypography.label.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: accentColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text('·', style: TextStyle(color: AuraColors.textDisabled)),
                  const SizedBox(width: 4),
                  // Completed Pill
                  GestureDetector(
                    onTap: () {
                      ref.read(selectedDayFilterProvider.notifier).state =
                          activeFilter == DayFilter.completedOnly
                              ? DayFilter.all
                              : DayFilter.completedOnly;
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: activeFilter == DayFilter.completedOnly
                            ? AuraColors.accentGreen.withValues(alpha: 0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: activeFilter == DayFilter.completedOnly
                              ? AuraColors.accentGreen
                              : Colors.transparent,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '${agenda.totalCompleted} Completed',
                        style: AuraTypography.label.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AuraColors.accentGreen,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Filter State Reset / Indicator
              if (activeFilter != DayFilter.all)
                GestureDetector(
                  onTap: () {
                    ref.read(selectedDayFilterProvider.notifier).state = DayFilter.all;
                  },
                  child: Text(
                    'Show All',
                    style: AuraTypography.caption.copyWith(
                      color: accentColor,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
