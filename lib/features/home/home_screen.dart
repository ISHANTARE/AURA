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
import '../../../platform/overlay_channel.dart';

// ── Providers ─────────────────────────────────────────────────────────────────

final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

final todayStatsProvider = FutureProvider.family<Map<String, int>, DateTime>((ref, date) async {
  final dao = ref.watch(itemDaoProvider);
  final startOfDay = DateTime(date.year, date.month, date.day).millisecondsSinceEpoch;
  final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59, 999).millisecondsSinceEpoch;
  final dayItems = await dao.watchTodayItems(startOfDay, endOfDay).first;
  final nonSubtasks = dayItems.where((i) => i.parentId == null).toList();
  final pending = nonSubtasks.where((i) => i.status == 'pending').length;
  final completed = nonSubtasks.where((i) => i.status == 'completed').length;
  return {'pending': pending, 'completed': completed, 'total': nonSubtasks.length};
});

final overdueItemsProvider = FutureProvider<List<Item>>((ref) async {
  final dao = ref.watch(itemDaoProvider);
  final nowMs = DateTime.now().millisecondsSinceEpoch;
  final overdue = await dao.watchOverdue(nowMs).first;
  return overdue.where((i) => i.parentId == null).toList();
});

final weekActivityMapProvider = FutureProvider.family<Map<String, int>, DateTime>((ref, anchor) async {
  final dao = ref.watch(itemDaoProvider);
  final monday = anchor.subtract(Duration(days: anchor.weekday - 1));
  final all = await dao.watchAllActive().first;
  final Map<String, int> map = {};
  for (var i = 0; i < 7; i++) {
    final d = monday.add(Duration(days: i));
    final start = DateTime(d.year, d.month, d.day).millisecondsSinceEpoch;
    final end = DateTime(d.year, d.month, d.day, 23, 59, 59, 999).millisecondsSinceEpoch;
    final key = DateFormat('yyyy-MM-dd').format(d);
    map[key] = all.where((item) {
      final target = item.fireAt ?? item.deadline;
      if (target == null) return false;
      return target >= start && target <= end && item.status == 'pending' && item.parentId == null;
    }).length;
  }
  return map;
});

final dayAgendaProvider = FutureProvider.family<List<Item>, DateTime>((ref, date) async {
  final dao = ref.watch(itemDaoProvider);
  final startOfDay = DateTime(date.year, date.month, date.day).millisecondsSinceEpoch;
  final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59, 999).millisecondsSinceEpoch;
  final all = await dao.watchAllActive().first;
  return all.where((i) {
    if (i.parentId != null) return false;
    final target = i.fireAt ?? i.deadline;
    if (target != null) {
      return target >= startOfDay && target <= endOfDay;
    }
    // Also show items without deadline on today's view
    final isToday = DateFormat('yyyy-MM-dd').format(date) == DateFormat('yyyy-MM-dd').format(DateTime.now());
    return isToday;
  }).toList()
    ..sort((a, b) {
      final aTime = a.fireAt ?? a.deadline ?? 0;
      final bTime = b.fireAt ?? b.deadline ?? 0;
      return aTime.compareTo(bTime);
    });
});

final userNameProvider = StateProvider<String>((ref) => 'Ishan T');

// ── Home Screen ───────────────────────────────────────────────────────────────

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedDateProvider);
    final userName = ref.watch(userNameProvider);

    return Scaffold(
      backgroundColor: AuraColors.bgBase,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _HomeHeader(userName: userName),
            const SizedBox(height: AuraSpacing.sm),

            // Bento Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AuraSpacing.md),
              child: Row(
                children: [
                  Expanded(child: _TodayStatsCard(date: selectedDate)),
                  const SizedBox(width: AuraSpacing.sm),
                  const Expanded(child: _OverdueAlertCard()),
                ],
              ),
            ),
            const SizedBox(height: AuraSpacing.sm),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AuraSpacing.md),
              child: Row(
                children: [
                  const Expanded(child: _FloatingOrbCard()),
                  const SizedBox(width: AuraSpacing.sm),
                  Expanded(child: _QuickStatsRow(date: selectedDate)),
                ],
              ),
            ),
            const SizedBox(height: AuraSpacing.md),

            // Date Navigator
            _AuraDateNavigator(anchor: selectedDate),
            const SizedBox(height: AuraSpacing.md),

            // Day Agenda
            Expanded(
              child: _DayAgendaView(date: selectedDate),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _HomeHeader extends StatelessWidget {
  final String userName;
  const _HomeHeader({required this.userName});

  String _greeting(int hour) {
    if (hour >= 5 && hour < 12) return 'Good morning';
    if (hour >= 12 && hour < 17) return 'Good afternoon';
    if (hour >= 17 && hour < 22) return 'Good evening';
    return 'Working late';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final greeting = _greeting(now.hour);
    final dateStr = DateFormat('EEEE, MMMM d').format(now);
    final accent = Theme.of(context).colorScheme.primary;
    final initials = userName.isNotEmpty ? userName[0].toUpperCase() : 'A';

    return Padding(
      padding: const EdgeInsets.fromLTRB(AuraSpacing.md, AuraSpacing.md, AuraSpacing.md, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withOpacity(0.15),
              border: Border.all(color: accent.withOpacity(0.4), width: 1.5),
            ),
            child: Center(
              child: Text(
                initials,
                style: AuraTypography.cardTitle.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: AuraSpacing.sm),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting, $userName',
                  style: AuraTypography.cardTitle.copyWith(
                    color: AuraColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  dateStr,
                  style: AuraTypography.caption.copyWith(color: AuraColors.textMuted),
                ),
              ],
            ),
          ),

          const SyncStatusBadge(isOnline: true),
          const SizedBox(width: AuraSpacing.sm),
          IconButton(
            key: const Key('home_settings_btn'),
            icon: const Icon(LucideIcons.settings, size: 20, color: AuraColors.textSecondary),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
    );
  }
}

// ── Today Stats Card ──────────────────────────────────────────────────────────

class _TodayStatsCard extends ConsumerWidget {
  final DateTime date;
  const _TodayStatsCard({required this.date});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(todayStatsProvider(date));
    final accent = Theme.of(context).colorScheme.primary;

    return BentoCard(
      child: statsAsync.when(
        data: (stats) {
          final total = stats['total'] ?? 0;
          final completed = stats['completed'] ?? 0;
          final percent = total > 0 ? completed / total : 0.0;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("TODAY'S FOCUS",
                  style: AuraTypography.caption.copyWith(
                    color: AuraColors.textMuted,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  )),
              const SizedBox(height: AuraSpacing.xs),
              Text(
                '$completed / $total done',
                style: AuraTypography.cardTitle.copyWith(color: AuraColors.textPrimary),
              ),
              const SizedBox(height: AuraSpacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(AuraRadius.full),
                child: LinearProgressIndicator(
                  value: percent,
                  backgroundColor: AuraColors.bgSubtle,
                  color: accent,
                  minHeight: 4,
                ),
              ),
              const SizedBox(height: AuraSpacing.xs),
              Text(
                '${(percent * 100).toInt()}% complete',
                style: AuraTypography.caption.copyWith(color: accent),
              ),
            ],
          );
        },
        loading: () => const _LoadingShimmer(),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }
}

// ── Overdue Alert ─────────────────────────────────────────────────────────────

class _OverdueAlertCard extends ConsumerWidget {
  const _OverdueAlertCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overdueAsync = ref.watch(overdueItemsProvider);

    return overdueAsync.when(
      data: (items) {
        if (items.isEmpty) return const _EmptyOverdueBento();
        return BentoCard(
          borderColor: AuraColors.accentRed.withOpacity(0.5),
          glowColor: AuraColors.accentRed,
          onTap: () => _showOverdueTriage(context, ref, items),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(LucideIcons.alertTriangle, size: 14, color: AuraColors.accentRed),
                  const SizedBox(width: 4),
                  Text(
                    'OVERDUE',
                    style: AuraTypography.caption.copyWith(
                      color: AuraColors.accentRed,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AuraSpacing.xs),
              Text(
                '${items.length} past due',
                style: AuraTypography.cardTitle.copyWith(color: AuraColors.textPrimary),
              ),
              const SizedBox(height: AuraSpacing.sm),
              Text(
                'TRIAGE NOW →',
                style: AuraTypography.caption.copyWith(
                  color: AuraColors.accentRed,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const BentoCard(child: _LoadingShimmer()),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  void _showOverdueTriage(BuildContext context, WidgetRef ref, List<Item> items) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => OverdueTriageSheet(items: items, ref: ref),
    );
  }
}

class _EmptyOverdueBento extends StatelessWidget {
  const _EmptyOverdueBento();

  @override
  Widget build(BuildContext context) {
    return BentoCard(
      borderColor: AuraColors.accentGreen.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(LucideIcons.checkCircle2, size: 14, color: AuraColors.accentGreen),
          const SizedBox(height: AuraSpacing.xs),
          Text(
            'All clear!',
            style: AuraTypography.cardTitle.copyWith(color: AuraColors.textPrimary),
          ),
          const SizedBox(height: 2),
          Text(
            'No overdue tasks',
            style: AuraTypography.caption.copyWith(color: AuraColors.textMuted),
          ),
        ],
      ),
    );
  }
}

// ── Floating Orb Card ─────────────────────────────────────────────────────────

class _FloatingOrbCard extends StatefulWidget {
  const _FloatingOrbCard();

  @override
  State<_FloatingOrbCard> createState() => _FloatingOrbCardState();
}

class _FloatingOrbCardState extends State<_FloatingOrbCard> {
  final _overlay = OverlayChannel();
  bool _isRunning = false;
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final running = await _overlay.isOverlayRunning();
    final perm = await _overlay.checkOverlayPermission();
    if (mounted) setState(() { _isRunning = running; _hasPermission = perm; });
  }

  Future<void> _toggle() async {
    if (!_hasPermission) {
      await _overlay.requestOverlayPermission();
      await _checkStatus();
      return;
    }
    if (_isRunning) {
      await _overlay.stopOverlay();
    } else {
      await _overlay.startOverlay();
    }
    await _checkStatus();
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return BentoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.orbit, size: 14, color: _isRunning ? accent : AuraColors.textMuted),
              const SizedBox(width: 4),
              Text('ASSISTANT ORB',
                  style: AuraTypography.caption.copyWith(
                    color: AuraColors.textMuted,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  )),
            ],
          ),
          const SizedBox(height: AuraSpacing.xs),
          Text(
            _isRunning ? 'Active on screen' : (_hasPermission ? 'Inactive' : 'No Permission'),
            style: AuraTypography.bodySmall.copyWith(
              color: _isRunning ? accent : AuraColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AuraSpacing.sm),
          GestureDetector(
            onTap: _toggle,
            child: Text(
              _isRunning ? 'HIDE ORB' : (_hasPermission ? 'SHOW ORB' : 'GRANT PERMISSION'),
              style: AuraTypography.caption.copyWith(
                color: accent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Quick Stats Row ───────────────────────────────────────────────────────────

class _QuickStatsRow extends ConsumerWidget {
  final DateTime date;
  const _QuickStatsRow({required this.date});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(todayStatsProvider(date));
    final overdueAsync = ref.watch(overdueItemsProvider);

    return BentoCard(
      child: statsAsync.when(
        data: (stats) {
          final overdue = overdueAsync.valueOrNull?.length ?? 0;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('QUICK STATS',
                  style: AuraTypography.caption.copyWith(
                    color: AuraColors.textMuted,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  )),
              const SizedBox(height: AuraSpacing.xs),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatTile(value: stats['pending'] ?? 0, label: 'Pending', color: AuraColors.accentLime),
                  _StatTile(value: stats['completed'] ?? 0, label: 'Done', color: AuraColors.accentGreen),
                  _StatTile(value: overdue, label: 'Overdue', color: overdue > 0 ? AuraColors.accentRed : AuraColors.textMuted),
                ],
              ),
            ],
          );
        },
        loading: () => const _LoadingShimmer(),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final int value;
  final String label;
  final Color color;
  const _StatTile({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$value',
          style: AuraTypography.sectionHeader.copyWith(color: color, fontWeight: FontWeight.w800),
        ),
        Text(label, style: AuraTypography.caption.copyWith(color: AuraColors.textMuted)),
      ],
    );
  }
}

// ── Date Navigator ────────────────────────────────────────────────────────────

class _AuraDateNavigator extends ConsumerStatefulWidget {
  final DateTime anchor;
  const _AuraDateNavigator({required this.anchor});

  @override
  ConsumerState<_AuraDateNavigator> createState() => _AuraDateNavigatorState();
}

class _AuraDateNavigatorState extends ConsumerState<_AuraDateNavigator> {
  late DateTime _weekStart;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _weekStart = now.subtract(Duration(days: now.weekday - 1));
  }

  @override
  Widget build(BuildContext context) {
    final selected = ref.watch(selectedDateProvider);
    final today = DateTime.now();
    final activityAsync = ref.watch(weekActivityMapProvider(_weekStart));
    final accent = Theme.of(context).colorScheme.primary;
    final activity = activityAsync.valueOrNull ?? {};

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AuraSpacing.md),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(LucideIcons.chevronLeft, size: 18, color: AuraColors.textSecondary),
            onPressed: () => setState(() => _weekStart = _weekStart.subtract(const Duration(days: 7))),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (i) {
                final day = _weekStart.add(Duration(days: i));
                final key = DateFormat('yyyy-MM-dd').format(day);
                final isToday = DateFormat('yyyy-MM-dd').format(today) == key;
                final isSelected = DateFormat('yyyy-MM-dd').format(selected) == key;
                final count = activity[key] ?? 0;

                return GestureDetector(
                  onTap: () => ref.read(selectedDateProvider.notifier).state = day,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 36,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected ? accent.withOpacity(0.15) : Colors.transparent,
                      borderRadius: BorderRadius.circular(AuraRadius.md),
                      border: isToday
                          ? Border.all(color: accent, width: 1.5)
                          : Border.all(color: Colors.transparent),
                    ),
                    child: Column(
                      children: [
                        Text(
                          DateFormat('E').format(day)[0],
                          style: AuraTypography.caption.copyWith(
                            color: isSelected ? accent : AuraColors.textMuted,
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          '${day.day}',
                          style: AuraTypography.bodySmall.copyWith(
                            color: isSelected ? accent : AuraColors.textPrimary,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 4,
                          height: 4,
                          margin: const EdgeInsets.only(top: 2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: count > 0 ? accent : Colors.transparent,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          IconButton(
            icon: const Icon(LucideIcons.chevronRight, size: 18, color: AuraColors.textSecondary),
            onPressed: () => setState(() => _weekStart = _weekStart.add(const Duration(days: 7))),
          ),
        ],
      ),
    );
  }
}

// ── Day Agenda View ───────────────────────────────────────────────────────────

class _DayAgendaView extends ConsumerWidget {
  final DateTime date;
  const _DayAgendaView({required this.date});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agendaAsync = ref.watch(dayAgendaProvider(date));
    final accent = Theme.of(context).colorScheme.primary;

    return agendaAsync.when(
      data: (items) {
        if (items.isEmpty) {
          return _EmptyDayState(date: date);
        }

        final timed = items.where((i) => i.fireAt != null && i.fireAt! > 0).toList();
        final anytime = items.where((i) => i.fireAt == null || i.fireAt == 0).toList();

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: AuraSpacing.md),
          children: [
            if (timed.isNotEmpty) ...[
              const _AgendaSectionHeader(label: 'TIMED ITEMS', icon: LucideIcons.clock),
              ...timed.map((item) => _TimedAgendaItem(item: item)),
            ],
            if (anytime.isNotEmpty) ...[
              const _AgendaSectionHeader(label: 'ANYTIME CHECKLIST', icon: LucideIcons.listChecks),
              ...anytime.map((item) => _AnytimeChecklistItem(item: item, ref: ref, accent: accent)),
            ],
            const SizedBox(height: 80),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text('Error: $e', style: const TextStyle(color: AuraColors.accentRed)),
      ),
    );
  }
}

class _AgendaSectionHeader extends StatelessWidget {
  final String label;
  final IconData icon;
  const _AgendaSectionHeader({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AuraSpacing.sm, bottom: AuraSpacing.xs),
      child: Row(
        children: [
          Icon(icon, size: 12, color: AuraColors.textMuted),
          const SizedBox(width: 6),
          Text(label,
              style: AuraTypography.caption.copyWith(
                color: AuraColors.textMuted,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              )),
          const SizedBox(width: AuraSpacing.sm),
          Expanded(child: Container(height: 1, color: AuraColors.border)),
        ],
      ),
    );
  }
}

class _TimedAgendaItem extends StatelessWidget {
  final Item item;
  const _TimedAgendaItem({required this.item});

  @override
  Widget build(BuildContext context) {
    final ms = item.fireAt;
    final time = ms != null ? DateFormat('hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(ms)) : '';
    final accent = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: AuraSpacing.xs),
      child: BentoCard(
        padding: const EdgeInsets.all(AuraSpacing.sm),
        onTap: () => context.push('/task/${item.id}'),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AuraRadius.xs),
              ),
              child: Text(
                time,
                style: AuraTypography.mono.copyWith(color: accent, fontSize: 11),
              ),
            ),
            const SizedBox(width: AuraSpacing.sm),
            Expanded(
              child: Text(
                item.title,
                style: AuraTypography.bodySmall.copyWith(color: AuraColors.textPrimary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnytimeChecklistItem extends StatelessWidget {
  final Item item;
  final WidgetRef ref;
  final Color accent;
  const _AnytimeChecklistItem({required this.item, required this.ref, required this.accent});

  @override
  Widget build(BuildContext context) {
    final isDone = item.status == 'completed';

    return Padding(
      padding: const EdgeInsets.only(bottom: AuraSpacing.xs),
      child: BentoCard(
        padding: const EdgeInsets.symmetric(horizontal: AuraSpacing.sm, vertical: AuraSpacing.xs + 2),
        onTap: () => context.push('/task/${item.id}'),
        child: Row(
          children: [
            GestureDetector(
              onTap: () async {
                final dao = ref.read(itemDaoProvider);
                await dao.completeItem(item.id, !isDone, DateTime.now().millisecondsSinceEpoch);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDone ? accent : Colors.transparent,
                  border: Border.all(
                    color: isDone ? accent : AuraColors.border,
                    width: 1.5,
                  ),
                ),
                child: isDone
                    ? const Icon(LucideIcons.check, size: 12, color: Colors.black)
                    : null,
              ),
            ),
            const SizedBox(width: AuraSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: AuraTypography.bodySmall.copyWith(
                      color: isDone ? AuraColors.textMuted : AuraColors.textPrimary,
                      decoration: isDone ? TextDecoration.lineThrough : null,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            PriorityBadge(priority: item.priority),
          ],
        ),
      ),
    );
  }
}

class _EmptyDayState extends StatelessWidget {
  final DateTime date;
  const _EmptyDayState({required this.date});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.sunMedium, size: 40, color: AuraColors.textMuted.withOpacity(0.3)),
          const SizedBox(height: AuraSpacing.md),
          Text(
            'Nothing scheduled for this day',
            style: AuraTypography.body.copyWith(color: AuraColors.textMuted),
          ),
          const SizedBox(height: AuraSpacing.md),
          AuraButton(
            label: 'ADD TASK',
            variant: AuraButtonVariant.outline,
            icon: LucideIcons.plus,
            onPressed: () => context.push('/capture-overlay'),
          ),
        ],
      ),
    );
  }
}

// ── Overdue Triage Sheet ──────────────────────────────────────────────────────

class OverdueTriageSheet extends ConsumerWidget {
  final List<Item> items;
  final WidgetRef ref;
  const OverdueTriageSheet({super.key, required this.items, required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef watchRef) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      builder: (ctx, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AuraColors.bgElevated,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AuraRadius.xl)),
            border: Border(top: BorderSide(color: AuraColors.border, width: 1)),
          ),
          child: Column(
            children: [
              Container(
                width: 40, height: 4,
                margin: const EdgeInsets.symmetric(vertical: AuraSpacing.sm),
                decoration: BoxDecoration(
                  color: AuraColors.border,
                  borderRadius: BorderRadius.circular(AuraRadius.full),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AuraSpacing.md),
                child: Row(
                  children: [
                    const Icon(LucideIcons.alertTriangle, size: 16, color: AuraColors.accentRed),
                    const SizedBox(width: AuraSpacing.xs),
                    Text(
                      '${items.length} Overdue Tasks',
                      style: AuraTypography.cardTitle.copyWith(color: AuraColors.accentRed, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AuraSpacing.sm),

              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: AuraSpacing.md),
                  itemCount: items.length,
                  itemBuilder: (_, i) {
                    final item = items[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AuraSpacing.xs),
                      child: BentoCard(
                        padding: const EdgeInsets.all(AuraSpacing.sm),
                        child: Text(item.title, style: AuraTypography.bodySmall.copyWith(color: AuraColors.textPrimary)),
                      ),
                    );
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(AuraSpacing.md),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: AuraButton(
                            label: 'RESCHEDULE TODAY',
                            variant: AuraButtonVariant.secondary,
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        const SizedBox(width: AuraSpacing.sm),
                        Expanded(
                          child: AuraButton(
                            label: 'TOMORROW',
                            variant: AuraButtonVariant.secondary,
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AuraSpacing.sm),
                    AuraButton(
                      label: 'MARK ALL COMPLETE',
                      variant: AuraButtonVariant.outline,
                      fullWidth: true,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Shimmer ───────────────────────────────────────────────────────────────────

class _LoadingShimmer extends StatelessWidget {
  const _LoadingShimmer();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(height: 10, width: 80, color: AuraColors.bgSubtle),
        const SizedBox(height: 6),
        Container(height: 16, width: 120, color: AuraColors.bgSubtle),
      ],
    );
  }
}
