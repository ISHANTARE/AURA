import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/constants/typography.dart';
import 'bento_card.dart';

/// Bento Row 1 Left — URGENT cell.
/// Shows up to 3 tasks due today or overdue.
class UrgentCell extends StatelessWidget {
  const UrgentCell({
    super.key,
    required this.items,
    this.onTap,
  });

  /// Each item: {title, deadline, isOverdue}
  final List<Map<String, dynamic>> items;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return BentoCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AuraSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────
          Row(
            children: [
              Text('URGENT', style: AuraTypography.label),
              const Spacer(),
              if (items.isNotEmpty)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AuraColors.accentRed,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AuraSpacing.sm),

          // ── Divider ─────────────────────────────────────────────────
          Container(height: 1, color: AuraColors.borderMuted),
          const SizedBox(height: AuraSpacing.sm),

          // ── Content ─────────────────────────────────────────────────
          if (items.isEmpty)
            Expanded(
              child: Center(
                child: Text(
                  'Nothing urgent.\nGood work.',
                  style: AuraTypography.body.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: items.take(2).map((item) => _UrgentItem(item: item)).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _UrgentItem extends StatelessWidget {
  const _UrgentItem({required this.item});
  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final isOverdue = item['isOverdue'] as bool? ?? false;
    return Padding(
      padding: const EdgeInsets.only(bottom: AuraSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Priority stripe
          Container(
            width: AuraSpacing.priorityStripe,
            height: 32,
            color: isOverdue ? AuraColors.accentRed : AuraColors.accentOrange,
          ),
          const SizedBox(width: AuraSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'] as String? ?? '',
                  style: AuraTypography.cardTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  item['deadline'] as String? ?? '',
                  style: AuraTypography.overline,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── ORB CELL ────────────────────────────────────────────────────────────────

/// Bento Row 1 Right — Orb call-to-action cell.
/// Static representation of the floating orb (not the actual draggable orb).
class OrbCell extends StatefulWidget {
  const OrbCell({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  State<OrbCell> createState() => _OrbCellState();
}

class _OrbCellState extends State<OrbCell> with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BentoCard(
      onTap: () {
        HapticFeedback.mediumImpact();
        widget.onTap();
      },
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Orb with pulse animation
          AnimatedBuilder(
            animation: _pulseAnim,
            builder: (context, child) => Transform.scale(
              scale: _pulseAnim.value,
              child: child,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Glow
                Container(
                  width: AuraSpacing.orbSize + 16,
                  height: AuraSpacing.orbSize + 16,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AuraColors.orbGlow,
                        blurRadius: 24,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                ),
                // Orb body
                Container(
                  width: AuraSpacing.orbSize,
                  height: AuraSpacing.orbSize,
                  decoration: BoxDecoration(
                    color: AuraColors.accentLime,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AuraColors.shadow,
                      width: 3,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: AuraColors.shadow,
                        offset: Offset(3, 3),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text('A', style: AuraTypography.orbLabel),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AuraSpacing.sm),
          Text('Tap to capture', style: AuraTypography.label),
        ],
      ),
    );
  }
}

// ── FOCUS CELL ──────────────────────────────────────────────────────────────

/// Bento Row 2 — TODAY'S FOCUS (full width).
/// AI-suggested ordered task list.
class FocusCell extends StatelessWidget {
  const FocusCell({
    super.key,
    required this.items,
    this.onItemTap,
  });

  /// Each item: {title, estimatedTime, taskId}
  final List<Map<String, dynamic>> items;
  final void Function(String taskId)? onItemTap;

  @override
  Widget build(BuildContext context) {
    return BentoCard(
      padding: const EdgeInsets.all(AuraSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────
          Row(
            children: [
              Text("TODAY'S FOCUS", style: AuraTypography.label),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AuraSpacing.sm, vertical: 2),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: AuraColors.accentLime.withValues(alpha: 0.4)),
                  color: AuraColors.accentLime.withValues(alpha: 0.08),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.sparkles,
                        size: 10, color: AuraColors.accentLime),
                    const SizedBox(width: 3),
                    Text('AI suggested',
                        style: AuraTypography.label.copyWith(
                          color: AuraColors.accentLime,
                          letterSpacing: 0.5,
                        )),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AuraSpacing.sm),
          Container(height: 1, color: AuraColors.borderMuted),
          const SizedBox(height: AuraSpacing.xs),

          // ── Items ───────────────────────────────────────────────────
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AuraSpacing.sm),
              child: Text(
                'Add some tasks to get focus suggestions.',
                style: AuraTypography.body,
              ),
            )
          else
            ...items.take(3).toList().asMap().entries.map((entry) {
              final idx = entry.key;
              final item = entry.value;
              return _FocusItem(
                index: idx + 1,
                item: item,
                onTap: onItemTap == null
                    ? null
                    : () => onItemTap!(item['taskId'] as String),
              );
            }),
        ],
      ),
    );
  }
}

class _FocusItem extends StatelessWidget {
  const _FocusItem({
    required this.index,
    required this.item,
    this.onTap,
  });

  final int index;
  final Map<String, dynamic> item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AuraSpacing.xs + 2),
        child: Row(
          children: [
            // Number indicator in lime
            SizedBox(
              width: 20,
              child: Text(
                '$index',
                style: AuraTypography.cardTitle.copyWith(
                  color: AuraColors.accentLime,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: AuraSpacing.sm),
            // Task name
            Expanded(
              child: Text(
                item['title'] as String? ?? '',
                style: AuraTypography.cardTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Estimated time
            Text(
              item['estimatedTime'] as String? ?? '',
              style: AuraTypography.overline,
            ),
            const SizedBox(width: AuraSpacing.xs),
            const Icon(LucideIcons.chevronRight,
                size: AuraSpacing.sm + 4,
                color: AuraColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

// ── NEXT UP CELL ─────────────────────────────────────────────────────────────

/// Bento Row 3 Left — NEXT UP cell.
class NextUpCell extends StatelessWidget {
  const NextUpCell({
    super.key,
    required this.items,
    this.onTap,
  });

  /// Each item: {title, subtitle, isEvent}
  final List<Map<String, dynamic>> items;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return BentoCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AuraSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text('NEXT UP', style: AuraTypography.label),
              const Spacer(),
              if (items.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AuraSpacing.sm - 2, vertical: 1),
                  decoration: BoxDecoration(
                    color: AuraColors.bgBase,
                    border: Border.all(color: AuraColors.border, width: 1.5),
                  ),
                  child: Text(
                    '${items.length}',
                    style: AuraTypography.label.copyWith(
                      color: AuraColors.textPrimary,
                      letterSpacing: 0,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AuraSpacing.sm),
          Container(height: 1, color: AuraColors.borderMuted),
          const SizedBox(height: AuraSpacing.sm),

          if (items.isEmpty)
            Expanded(
              child: Center(
                child: Text('Nothing scheduled.', style: AuraTypography.body),
              ),
            )
          else
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: items.take(2).map((item) => _NextUpItem(item: item)).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _NextUpItem extends StatelessWidget {
  const _NextUpItem({required this.item});
  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final isEvent = item['isEvent'] as bool? ?? false;
    final indicatorColor =
        isEvent ? AuraColors.accentBlue : AuraColors.textPrimary;

    return Padding(
      padding: const EdgeInsets.only(bottom: AuraSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: AuraSpacing.priorityStripe,
            height: 32,
            color: indicatorColor,
          ),
          const SizedBox(width: AuraSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'] as String? ?? '',
                  style: AuraTypography.bodyPrimary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  item['subtitle'] as String? ?? '',
                  style: AuraTypography.overline,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── HABITS CELL ──────────────────────────────────────────────────────────────

/// Bento Row 3 Right — HABITS cell.
class HabitsCell extends StatelessWidget {
  const HabitsCell({
    super.key,
    required this.habits,
    this.onHabitToggle,
    this.onTap,
  });

  /// Each habit: {title, status: 'done'|'missed'|'pending'}
  final List<Map<String, dynamic>> habits;
  final void Function(int index)? onHabitToggle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return BentoCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AuraSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('HABITS', style: AuraTypography.label),
          const SizedBox(height: AuraSpacing.sm),
          Container(height: 1, color: AuraColors.borderMuted),
          const SizedBox(height: AuraSpacing.sm),
          if (habits.isEmpty)
            Expanded(
              child: Center(
                child: Text('No habits yet.', style: AuraTypography.body),
              ),
            )
          else
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: habits.take(3).toList().asMap().entries.map((entry) {
                  final idx = entry.key;
                  final h = entry.value;
                  return _HabitRow(
                    habit: h,
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      onHabitToggle?.call(idx);
                    },
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _HabitRow extends StatelessWidget {
  const _HabitRow({required this.habit, required this.onTap});
  final Map<String, dynamic> habit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final status = habit['status'] as String? ?? 'pending';
    final (icon, color) = switch (status) {
      'done' => (LucideIcons.check, AuraColors.accentGreen),
      'missed' => (LucideIcons.x, AuraColors.accentRed),
      _ => (LucideIcons.minus, AuraColors.textDisabled),
    };

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: AuraSpacing.sm),
        child: Row(
          children: [
            Expanded(
              child: Text(
                habit['title'] as String? ?? '',
                style: AuraTypography.bodyPrimary,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(icon, size: 14, color: color),
          ],
        ),
      ),
    );
  }
}

// ── WORKSPACES CELL ──────────────────────────────────────────────────────────

/// Bento Row 4 — WORKSPACES horizontal scroll.
class WorkspacesCell extends StatelessWidget {
  const WorkspacesCell({
    super.key,
    required this.workspaces,
    this.onWorkspaceTap,
    this.onAddTap,
  });

  /// Each workspace: {name, taskCount, color (int ARGB), icon (IconData)}
  final List<Map<String, dynamic>> workspaces;
  final void Function(String name)? onWorkspaceTap;
  final VoidCallback? onAddTap;

  @override
  Widget build(BuildContext context) {
    return BentoCard(
      padding: const EdgeInsets.all(AuraSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('WORKSPACES', style: AuraTypography.label),
          const SizedBox(height: AuraSpacing.sm),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ...workspaces.map((ws) => Padding(
                      padding: const EdgeInsets.only(right: AuraSpacing.sm),
                      child: _WorkspaceChip(
                        workspace: ws,
                        onTap: () =>
                            onWorkspaceTap?.call(ws['name'] as String? ?? ''),
                      ),
                    )),
                // Add chip
                _AddWorkspaceChip(onTap: onAddTap),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkspaceChip extends StatelessWidget {
  const _WorkspaceChip({required this.workspace, required this.onTap});
  final Map<String, dynamic> workspace;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = Color(workspace['color'] as int? ?? 0xFFFFFFFF);
    final icon = workspace['icon'] as IconData? ?? LucideIcons.folder;
    final name = workspace['name'] as String? ?? '';
    final count = workspace['taskCount'] as int? ?? 0;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AuraSpacing.md, vertical: AuraSpacing.sm - 2),
        decoration: BoxDecoration(
          color: AuraColors.bgCard,
          border: Border.all(color: AuraColors.border, width: AuraSpacing.borderWidth),
          boxShadow: const [
            BoxShadow(
                color: AuraColors.shadow,
                offset: Offset(2, 2),
                blurRadius: 0),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: AuraSpacing.xs),
            Text(name, style: AuraTypography.bodyPrimary.copyWith(fontSize: 13)),
            const SizedBox(width: AuraSpacing.xs),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              color: color.withValues(alpha: 0.2),
              child: Text(
                '$count',
                style: AuraTypography.label.copyWith(
                  color: color,
                  letterSpacing: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddWorkspaceChip extends StatelessWidget {
  const _AddWorkspaceChip({this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap?.call();
      },
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AuraColors.bgCard,
          border: Border.all(
              color: AuraColors.border, width: AuraSpacing.borderWidth),
          boxShadow: const [
            BoxShadow(
                color: AuraColors.shadow,
                offset: Offset(2, 2),
                blurRadius: 0),
          ],
        ),
        child: const Icon(LucideIcons.plus,
            size: 16, color: AuraColors.textPrimary),
      ),
    );
  }
}
