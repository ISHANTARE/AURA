import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/widgets/aura_widgets.dart';
import '../../../database/app_database.dart';

// ── Providers ─────────────────────────────────────────────────────────────────

final alarmsListProvider = StreamProvider<List<Item>>((ref) {
  return ref.watch(itemDaoProvider).watchAllActive();
});

// ── Alarms Screen ─────────────────────────────────────────────────────────────

class AlarmsScreen extends ConsumerStatefulWidget {
  const AlarmsScreen({super.key});

  @override
  ConsumerState<AlarmsScreen> createState() => _AlarmsScreenState();
}

class _AlarmsScreenState extends ConsumerState<AlarmsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final itemsAsync = ref.watch(alarmsListProvider);

    return Scaffold(
      backgroundColor: AuraColors.bgBase,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(AuraSpacing.md, AuraSpacing.md, AuraSpacing.md, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Alarms & Reminders', style: AuraTypography.sectionHeader.copyWith(color: AuraColors.textPrimary)),
                        Text(DateFormat('EEEE, MMMM d').format(DateTime.now()),
                            style: AuraTypography.caption.copyWith(color: AuraColors.textMuted)),
                      ],
                    ),
                  ),
                  AuraButton(
                    label: 'NEW',
                    icon: LucideIcons.plus,
                    variant: AuraButtonVariant.outline,
                    onPressed: () => context.push('/capture-overlay'),
                  ),
                ],
              ),
            ),

            // Tabs
            Padding(
              padding: const EdgeInsets.all(AuraSpacing.md),
              child: BentoCard(
                padding: const EdgeInsets.all(4),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: accent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AuraRadius.sm),
                    border: Border.all(color: accent.withOpacity(0.4)),
                  ),
                  labelColor: accent,
                  unselectedLabelColor: AuraColors.textMuted,
                  labelStyle: AuraTypography.label.copyWith(fontWeight: FontWeight.w700),
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: 'UPCOMING'),
                    Tab(text: 'ALARMS'),
                  ],
                ),
              ),
            ),

            Expanded(
              child: itemsAsync.when(
                data: (items) {
                  final upcoming = items
                      .where((i) =>
                          i.category == 'reminder' &&
                          i.status == 'pending' &&
                          i.parentId == null)
                      .toList()
                    ..sort((a, b) => (a.fireAt ?? a.deadline ?? 0).compareTo(b.fireAt ?? b.deadline ?? 0));

                  final alarms = items
                      .where((i) => i.category == 'alarm' && i.parentId == null)
                      .toList()
                    ..sort((a, b) => (a.fireAt ?? 0).compareTo(b.fireAt ?? 0));

                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _UpcomingList(items: upcoming),
                      _AlarmList(alarms: alarms),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('$e', style: const TextStyle(color: AuraColors.accentRed))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Upcoming List ─────────────────────────────────────────────────────────────

class _UpcomingList extends StatelessWidget {
  final List<Item> items;
  const _UpcomingList({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.bellOff, size: 48, color: AuraColors.textMuted.withOpacity(0.3)),
            const SizedBox(height: AuraSpacing.md),
            Text('No upcoming reminders', style: AuraTypography.body.copyWith(color: AuraColors.textMuted)),
            const SizedBox(height: AuraSpacing.md),
            AuraButton(
              label: 'ADD REMINDER',
              icon: LucideIcons.plus,
              variant: AuraButtonVariant.outline,
              onPressed: () => context.push('/capture-overlay'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AuraSpacing.md),
      itemCount: items.length,
      itemBuilder: (_, i) => _ReminderCard(item: items[i]),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  final Item item;
  const _ReminderCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final ms = item.fireAt ?? item.deadline;
    final fireAt = ms != null ? DateTime.fromMillisecondsSinceEpoch(ms) : null;
    final now = DateTime.now();
    final isOverdue = fireAt != null && fireAt.isBefore(now);
    final timeStr = fireAt != null
        ? (fireAt.day == now.day ? DateFormat('hh:mm a').format(fireAt) : DateFormat('MMM d · hh:mm a').format(fireAt))
        : 'Anytime';

    return Padding(
      padding: const EdgeInsets.only(bottom: AuraSpacing.xs),
      child: BentoCard(
        borderColor: isOverdue ? AuraColors.accentRed.withOpacity(0.4) : AuraColors.border,
        onTap: () => context.push('/task/${item.id}'),
        child: Row(
          children: [
            SizedBox(
              width: 72,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    timeStr,
                    style: AuraTypography.mono.copyWith(
                      color: isOverdue ? AuraColors.accentRed : accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (isOverdue)
                    Text('OVERDUE', style: AuraTypography.caption.copyWith(color: AuraColors.accentRed, fontSize: 9, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            Container(width: 1, height: 36, color: AuraColors.border, margin: const EdgeInsets.symmetric(horizontal: AuraSpacing.sm)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: AuraTypography.bodySmall.copyWith(color: AuraColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  PriorityBadge(priority: item.priority),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Alarm List ────────────────────────────────────────────────────────────────

class _AlarmList extends StatelessWidget {
  final List<Item> alarms;
  const _AlarmList({required this.alarms});

  @override
  Widget build(BuildContext context) {
    if (alarms.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.alarmClock, size: 48, color: AuraColors.textMuted.withOpacity(0.3)),
            const SizedBox(height: AuraSpacing.md),
            Text('No alarms set', style: AuraTypography.body.copyWith(color: AuraColors.textMuted)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AuraSpacing.md),
      itemCount: alarms.length,
      itemBuilder: (_, i) {
        final alarm = alarms[i];
        final ms = alarm.fireAt;
        final fireAt = ms != null ? DateTime.fromMillisecondsSinceEpoch(ms) : null;
        final timeStr = fireAt != null ? DateFormat('hh:mm a').format(fireAt) : 'Unscheduled';
        final isEnabled = alarm.status == 'pending';
        final accent = Theme.of(context).colorScheme.primary;

        return Padding(
          padding: const EdgeInsets.only(bottom: AuraSpacing.sm),
          child: BentoCard(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(timeStr,
                          style: AuraTypography.displayMedium.copyWith(
                            color: isEnabled ? AuraColors.textPrimary : AuraColors.textMuted,
                            fontWeight: FontWeight.w800,
                          )),
                      Text(alarm.title, style: AuraTypography.bodySmall.copyWith(color: AuraColors.textSecondary)),
                      if (alarm.recurrenceRule != null && alarm.recurrenceRule!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(alarm.recurrenceRule!, style: AuraTypography.caption.copyWith(color: AuraColors.textMuted)),
                        ),
                    ],
                  ),
                ),
                Switch(
                  value: isEnabled,
                  activeColor: accent,
                  onChanged: (_) {},
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
