import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/constants/typography.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../core/widgets/aura_widgets.dart';
import '../../../database/app_database.dart';
import '../home/home_screen.dart' show todayStatsProvider, userNameProvider;

// ── Providers ─────────────────────────────────────────────────────────────────

final todayFocusItemsProvider = FutureProvider<List<Item>>((ref) async {
  final dao = ref.watch(itemDaoProvider);
  final all = await dao.watchAllActive().first;
  final focus = all
      .where((i) => i.status == 'pending' && i.parentId == null)
      .toList()
    ..sort((a, b) {
      final pA = a.priority == 'high' ? 0 : (a.priority == 'medium' ? 1 : 2);
      final pB = b.priority == 'high' ? 0 : (b.priority == 'medium' ? 1 : 2);
      return pA.compareTo(pB);
    });
  return focus.take(5).toList();
});

final urgentItemsProvider = FutureProvider<List<Item>>((ref) async {
  final dao = ref.watch(itemDaoProvider);
  final all = await dao.watchAllActive().first;
  return all.where((i) {
    if (i.status != 'pending') return false;
    if (i.category == 'alarm') return true;
    if (i.priority == 'high') return true;
    return false;
  }).take(3).toList();
});

// ── Morning Briefing Screen ───────────────────────────────────────────────────

class MorningBriefingScreen extends ConsumerWidget {
  const MorningBriefingScreen({super.key});

  String _timeAwareGreeting(int hour, String userName) {
    if (hour >= 5 && hour < 12) return 'Good morning, $userName';
    if (hour >= 12 && hour < 17) return 'Good afternoon, $userName';
    if (hour >= 17 && hour < 22) return 'Good evening, $userName';
    return 'Working late, $userName';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final userName = ref.watch(userNameProvider);
    final statsAsync = ref.watch(todayStatsProvider(now));
    final focusAsync = ref.watch(todayFocusItemsProvider);
    final urgentAsync = ref.watch(urgentItemsProvider);
    final accent = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: AuraColors.bgBase,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AuraSpacing.md, vertical: AuraSpacing.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(LucideIcons.sunMedium, size: 16, color: accent),
                      const SizedBox(width: 6),
                      Text('MORNING BRIEFING', style: AuraTypography.caption.copyWith(color: accent, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x, size: 20, color: AuraColors.textMuted),
                    onPressed: () => context.go(Routes.home),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: AuraSpacing.md),
                children: [
                  // Greeting
                  Text(
                    _timeAwareGreeting(now.hour, userName),
                    style: AuraTypography.displayMedium.copyWith(color: AuraColors.textPrimary, fontWeight: FontWeight.w800),
                  ),
                  Text(
                    DateFormat('EEEE, MMMM d').format(now),
                    style: AuraTypography.bodySmall.copyWith(color: AuraColors.textMuted),
                  ),
                  const SizedBox(height: AuraSpacing.lg),

                  // Today at a Glance
                  _buildSectionHeader('TODAY AT A GLANCE', LucideIcons.layoutDashboard),
                  statsAsync.when(
                    data: (stats) {
                      return Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              count: stats['pending'] ?? 0,
                              label: 'Pending',
                              color: AuraColors.accentLime,
                            ),
                          ),
                          const SizedBox(width: AuraSpacing.xs),
                          Expanded(
                            child: _StatCard(
                              count: stats['completed'] ?? 0,
                              label: 'Done',
                              color: AuraColors.accentGreen,
                            ),
                          ),
                          const SizedBox(width: AuraSpacing.xs),
                          Expanded(
                            child: _StatCard(
                              count: stats['total'] ?? 0,
                              label: 'Total',
                              color: accent,
                            ),
                          ),
                        ],
                      );
                    },
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: AuraSpacing.lg),

                  // Today's Focus
                  _buildSectionHeader("TODAY'S FOCUS", LucideIcons.target),
                  focusAsync.when(
                    data: (items) {
                      if (items.isEmpty) {
                        return BentoCard(
                          child: Text('No high priority tasks scheduled for today. Enjoy the clear schedule!',
                              style: AuraTypography.bodySmall.copyWith(color: AuraColors.textMuted)),
                        );
                      }
                      return Column(
                        children: items.asMap().entries.map((entry) {
                          final idx = entry.key + 1;
                          final item = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: AuraSpacing.xs),
                            child: BentoCard(
                              padding: const EdgeInsets.symmetric(horizontal: AuraSpacing.sm, vertical: AuraSpacing.sm),
                              onTap: () => context.push('/task/${item.id}'),
                              child: Row(
                                children: [
                                  Text('$idx.', style: AuraTypography.bodySmall.copyWith(color: accent, fontWeight: FontWeight.w700)),
                                  const SizedBox(width: AuraSpacing.sm),
                                  Expanded(
                                    child: Text(item.title, style: AuraTypography.bodySmall.copyWith(color: AuraColors.textPrimary)),
                                  ),
                                  PriorityBadge(priority: item.priority),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: AuraSpacing.lg),

                  // Urgent Alarms & Deadlines
                  _buildSectionHeader('URGENT & ALARMS', LucideIcons.alertCircle),
                  urgentAsync.when(
                    data: (items) {
                      if (items.isEmpty) {
                        return BentoCard(
                          child: Text('No urgent alarms firing today.', style: AuraTypography.bodySmall.copyWith(color: AuraColors.textMuted)),
                        );
                      }
                      return Column(
                        children: items.map((item) {
                          final isAlarm = item.category == 'alarm';
                          return Padding(
                            padding: const EdgeInsets.only(bottom: AuraSpacing.xs),
                            child: BentoCard(
                              borderColor: isAlarm ? accent.withValues(alpha: 0.4) : AuraColors.accentRed.withValues(alpha: 0.4),
                              padding: const EdgeInsets.all(AuraSpacing.sm),
                              onTap: () => context.push('/task/${item.id}'),
                              child: Row(
                                children: [
                                  Icon(isAlarm ? LucideIcons.alarmClock : LucideIcons.alertTriangle,
                                      size: 16, color: isAlarm ? accent : AuraColors.accentRed),
                                  const SizedBox(width: AuraSpacing.sm),
                                  Expanded(child: Text(item.title, style: AuraTypography.bodySmall.copyWith(color: AuraColors.textPrimary))),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: AuraSpacing.xl),
                ],
              ),
            ),

            // Start Day CTA
            Padding(
              padding: const EdgeInsets.all(AuraSpacing.md),
              child: AuraButton(
                label: 'START THE DAY →',
                fullWidth: true,
                onPressed: () => context.go(Routes.home),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AuraSpacing.xs),
      child: Row(
        children: [
          Icon(icon, size: 12, color: AuraColors.textMuted),
          const SizedBox(width: 6),
          Text(title, style: AuraTypography.caption.copyWith(color: AuraColors.textMuted, fontWeight: FontWeight.w700, letterSpacing: 1.0)),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final int count;
  final String label;
  final Color color;

  const _StatCard({required this.count, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return BentoCard(
      padding: const EdgeInsets.all(AuraSpacing.sm),
      child: Column(
        children: [
          Text('$count', style: AuraTypography.sectionHeader.copyWith(color: color, fontWeight: FontWeight.w800)),
          Text(label, style: AuraTypography.caption.copyWith(color: AuraColors.textMuted)),
        ],
      ),
    );
  }
}
