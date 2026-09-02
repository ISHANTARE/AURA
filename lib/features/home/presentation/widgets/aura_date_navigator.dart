import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/typography.dart';
import '../providers/home_providers.dart';

/// 3-part Day Navigation Control with Day-Specific [Pending | Done] summary badge.
///
/// Contains exactly three navigation elements:
///   [Previous Day] -> [Date Selector] -> [Next Day]
///
/// Below the switcher sits the day-specific metrics badge: [X Pending | Y Done]
/// with interactive tap-to-filter toggles for the active day's agenda.
class AuraDateNavigator extends ConsumerWidget {
  const AuraDateNavigator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final activeFilter = ref.watch(selectedDayFilterProvider);
    final agendaAsync = ref.watch(dayAgendaProvider);

    final primaryColor = Theme.of(context).colorScheme.primary;
    final cardBg = AuraColors.cardOf(context);
    final elevatedBg = AuraColors.elevatedOf(context);
    final borderColor = AuraColors.borderOf(context);
    final textPrimary = AuraColors.textPrimaryOf(context);
    final textSecondary = AuraColors.textSecondaryOf(context);
    final isDark = AuraColors.isDarkMode(context);

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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: isDark ? AuraColors.shadow : AuraColors.lightShadow,
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── 1. Top: Exactly 3 Logical Navigation Elements ─────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 1. Previous Day Button
              IconButton(
                icon: const Icon(LucideIcons.chevronLeft, size: 20),
                color: textPrimary,
                tooltip: 'Previous Day',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                onPressed: () {
                  ref.read(selectedDateProvider.notifier).state =
                      selectedDate.subtract(const Duration(days: 1));
                },
              ),

              // 2. Date Selector (Tap to pick any date)
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2035),
                    builder: (pickerCtx, child) {
                      return Theme(
                        data: Theme.of(pickerCtx).copyWith(
                          colorScheme: isDark
                              ? ColorScheme.dark(
                                  primary: primaryColor,
                                  surface: AuraColors.bgElevated,
                                  onSurface: AuraColors.textPrimary,
                                )
                              : ColorScheme.light(
                                  primary: primaryColor,
                                  surface: AuraColors.lightBgCard,
                                  onSurface: AuraColors.lightTextPrimary,
                                ),
                          dialogTheme: DialogThemeData(
                            backgroundColor: isDark
                                ? AuraColors.bgElevated
                                : AuraColors.lightBgCard,
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
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.calendar, size: 15, color: primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        dateLabel,
                        style: AuraTypography.cardTitle.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isToday ? primaryColor : textPrimary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(LucideIcons.chevronDown, size: 14, color: textSecondary),
                    ],
                  ),
                ),
              ),

              // 3. Next Day Button
              IconButton(
                icon: const Icon(LucideIcons.chevronRight, size: 20),
                color: textPrimary,
                tooltip: 'Next Day',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                onPressed: () {
                  ref.read(selectedDateProvider.notifier).state =
                      selectedDate.add(const Duration(days: 1));
                },
              ),
            ],
          ),

          const SizedBox(height: 10),
          Divider(color: borderColor, height: 1),
          const SizedBox(height: 10),

          // ── 2. Day-Specific Badge / Box [X Pending | Y Done] ─────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: elevatedBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Day metrics [Pending | Done] with tap-to-filter
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
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: activeFilter == DayFilter.pendingOnly
                              ? primaryColor.withValues(alpha: 0.18)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: activeFilter == DayFilter.pendingOnly
                                ? primaryColor
                                : Colors.transparent,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(LucideIcons.clock, size: 12, color: primaryColor),
                            const SizedBox(width: 4),
                            Text(
                              '${agenda.totalPending} Pending',
                              style: AuraTypography.label.copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        '|',
                        style: TextStyle(
                          color: textSecondary.withValues(alpha: 0.4),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // Completed Pill
                    GestureDetector(
                      onTap: () {
                        ref.read(selectedDayFilterProvider.notifier).state =
                            activeFilter == DayFilter.completedOnly
                                ? DayFilter.all
                                : DayFilter.completedOnly;
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: activeFilter == DayFilter.completedOnly
                              ? AuraColors.accentGreen.withValues(alpha: 0.18)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: activeFilter == DayFilter.completedOnly
                                ? AuraColors.accentGreen
                                : Colors.transparent,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(LucideIcons.checkCircle, size: 12, color: AuraColors.accentGreen),
                            const SizedBox(width: 4),
                            Text(
                              '${agenda.totalCompleted} Done',
                              style: AuraTypography.label.copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AuraColors.accentGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Reset filter button if active
                if (activeFilter != DayFilter.all)
                  GestureDetector(
                    onTap: () {
                      ref.read(selectedDayFilterProvider.notifier).state = DayFilter.all;
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Text(
                        'Show All',
                        style: AuraTypography.caption.copyWith(
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  )
                else
                  Text(
                    'DAY SUMMARY',
                    style: AuraTypography.caption.copyWith(
                      color: textSecondary,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
