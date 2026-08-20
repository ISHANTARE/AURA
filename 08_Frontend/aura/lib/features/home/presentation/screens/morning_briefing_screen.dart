import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/providers/providers.dart';
import '../../../../core/router/app_router.dart';

/// Morning Briefing Screen — AURA v2 Morning Briefing.
/// Shows: user greeting, today's focus tasks, urgent alarms, and quick stats.
class MorningBriefingScreen extends ConsumerWidget {
  const MorningBriefingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, MMMM d').format(now);

    final userName = ref.watch(userNameProvider);
    final firstName = userName.split(' ').first;

    final focusAsync = ref.watch(todayFocusItemsProvider);
    final urgentAsync = ref.watch(urgentItemsProvider);
    final statsAsync = ref.watch(quickStatsProvider);

    return Scaffold(
      backgroundColor: AuraColors.bgBase,
      appBar: AppBar(
        backgroundColor: AuraColors.bgBase,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.x, color: AuraColors.textPrimary),
          onPressed: () => context.go(Routes.home),
        ),
        title: Text('MORNING BRIEFING', style: AuraTypography.screenHeader),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AuraSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Greeting ───────────────────────────────────────────────
              Text(
                'Good morning, $firstName.',
                style: AuraTypography.display.copyWith(fontSize: 22),
              ),
              const SizedBox(height: 4),
              Text(dateStr, style: AuraTypography.overline),

              const SizedBox(height: AuraSpacing.lg),

              // ── Quick Stats ────────────────────────────────────────────
              statsAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (s) => _BriefingSection(
                  title: 'TODAY AT A GLANCE',
                  child: Row(
                    children: [
                      _StatTile(
                          label: 'Pending', value: '${s.pending}',
                          color: AuraColors.accentLime),
                      const SizedBox(width: AuraSpacing.sm),
                      _StatTile(
                          label: 'Completed', value: '${s.completed}',
                          color: AuraColors.accentGreen),
                      const SizedBox(width: AuraSpacing.sm),
                      _StatTile(
                          label: 'Overdue', value: '${s.overdue}',
                          color: s.overdue > 0
                              ? AuraColors.accentRed
                              : AuraColors.textDisabled),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AuraSpacing.lg),

              // ── Today's Focus ──────────────────────────────────────────
              _BriefingSection(
                title: "TODAY'S FOCUS",
                badge: const _AiBadge(),
                child: focusAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          AuraColors.accentLime),
                      strokeWidth: 2,
                    ),
                  ),
                  error: (e, __) => Text('Error: $e', style: AuraTypography.body),
                  data: (items) {
                    if (items.isEmpty) {
                      return Padding(
                        padding:
                            const EdgeInsets.symmetric(vertical: AuraSpacing.sm),
                        child: Text(
                          'Nothing on your focus list. Enjoy a calm morning!',
                          style: AuraTypography.body.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: items
                          .take(5)
                          .toList()
                          .asMap()
                          .entries
                          .map((e) => _FocusRow(
                                index: e.key + 1,
                                item: e.value,
                                onTap: () => context
                                    .push(Routes.taskRoute(e.value.id)),
                              ))
                          .toList(),
                    );
                  },
                ),
              ),

              const SizedBox(height: AuraSpacing.lg),

              // ── Urgent Alarms ──────────────────────────────────────────
              _BriefingSection(
                title: 'URGENT ALARMS & DEADLINES',
                child: urgentAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (items) {
                    if (items.isEmpty) {
                      return Text(
                        'No urgent items.',
                        style: AuraTypography.body.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      );
                    }
                    return Column(
                      children: items
                          .take(3)
                          .map((item) => _UrgentRow(item: item))
                          .toList(),
                    );
                  },
                ),
              ),

              const SizedBox(height: AuraSpacing.xl),

              // ── CTA ────────────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => context.go(Routes.home),
                  child: Text(
                    'START THE DAY →',
                    style: AuraTypography.label.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _BriefingSection extends StatelessWidget {
  const _BriefingSection({
    required this.title,
    required this.child,
    this.badge,
  });

  final String title;
  final Widget child;
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(title, style: AuraTypography.label),
            if (badge != null) ...[
              const SizedBox(width: AuraSpacing.sm),
              badge!,
            ],
          ],
        ),
        const SizedBox(height: AuraSpacing.xs),
        Container(height: 1, color: AuraColors.borderMuted),
        const SizedBox(height: AuraSpacing.sm),
        child,
      ],
    );
  }
}

class _AiBadge extends StatelessWidget {
  const _AiBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: AuraColors.accentLime.withValues(alpha: 0.5)),
        color: AuraColors.accentLime.withValues(alpha: 0.08),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.sparkles, size: 10, color: AuraColors.accentLime),
          const SizedBox(width: 3),
          Text(
            'AI suggested',
            style: AuraTypography.label.copyWith(
              color: AuraColors.accentLime,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AuraSpacing.sm, vertical: AuraSpacing.sm),
        decoration: BoxDecoration(
          color: AuraColors.bgCard,
          border: Border.all(color: AuraColors.border, width: 2),
          boxShadow: const [
            BoxShadow(
                color: AuraColors.shadow, offset: Offset(3, 3), blurRadius: 0),
          ],
        ),
        child: Column(
          children: [
            Text(value,
                style: AuraTypography.bentoMetricValue.copyWith(
                  color: color,
                  fontSize: 24,
                )),
            const SizedBox(height: 2),
            Text(label, style: AuraTypography.overline),
          ],
        ),
      ),
    );
  }
}

class _FocusRow extends StatelessWidget {
  const _FocusRow({
    required this.index,
    required this.item,
    required this.onTap,
  });

  final int index;
  final Item item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AuraSpacing.xs + 2),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              child: Text(
                '$index.',
                style: AuraTypography.cardTitle.copyWith(
                  color: AuraColors.accentLime,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: AuraSpacing.sm),
            Expanded(
              child: Text(
                item.title,
                style: AuraTypography.cardTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              color: _priorityColor(item.priority).withValues(alpha: 0.15),
              child: Text(
                item.priority.toUpperCase(),
                style: AuraTypography.label.copyWith(
                  color: _priorityColor(item.priority),
                  fontSize: 9,
                ),
              ),
            ),
            const SizedBox(width: AuraSpacing.xs),
            const Icon(LucideIcons.chevronRight,
                size: 14, color: AuraColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Color _priorityColor(String? priority) {
    switch (priority) {
      case 'high':
        return AuraColors.accentRed;
      case 'medium':
        return AuraColors.accentOrange;
      default:
        return AuraColors.textSecondary;
    }
  }
}

class _UrgentRow extends StatelessWidget {
  const _UrgentRow({required this.item});
  final Item item;

  @override
  Widget build(BuildContext context) {
    final deadline = item.deadline ?? item.fireAt;
    final deadlineStr = deadline != null
        ? DateFormat('EEE · h:mm a')
            .format(DateTime.fromMillisecondsSinceEpoch(deadline))
        : 'No deadline';

    final isOverdue = (deadline ?? 0) < DateTime.now().millisecondsSinceEpoch;

    return Padding(
      padding: const EdgeInsets.only(bottom: AuraSpacing.sm),
      child: Row(
        children: [
          Container(
            width: AuraSpacing.priorityStripe,
            height: 36,
            color: isOverdue ? AuraColors.accentRed : AuraColors.accentOrange,
          ),
          const SizedBox(width: AuraSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: AuraTypography.bodyPrimary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(deadlineStr, style: AuraTypography.overline),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
