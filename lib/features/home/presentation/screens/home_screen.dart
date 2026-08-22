import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/router/app_router.dart';
import '../../../alarms/presentation/widgets/edit_alarm_modal.dart';
import '../../../capture/presentation/widgets/voice_capture_overlay.dart';
import '../../../workspaces/presentation/widgets/create_workspace_modal.dart';
import '../providers/home_providers.dart';
import '../widgets/home_bento_cells.dart';
import '../widgets/quick_stats_row.dart';
import '../widgets/sync_status_badge.dart';

/// Home Screen — AURA v2 Bento Grid layout connected reactively to Drift DB.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _staggerCtrl;
  final List<Animation<double>> _cellAnims = [];

  @override
  void initState() {
    super.initState();
    _staggerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    for (int i = 0; i < 5; i++) {
      final start = (i * 0.12).clamp(0.0, 1.0);
      final end = (start + 0.5).clamp(0.0, 1.0);
      _cellAnims.add(
        CurvedAnimation(
          parent: _staggerCtrl,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _staggerCtrl.forward();
    });
  }

  @override
  void dispose() {
    _staggerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, MMMM d').format(now);
    final mediaQuery = MediaQuery.of(context);

    // Dynamic user name from StateNotifierProvider
    final userName = ref.watch(userNameProvider);
    final greeting = _greeting(now.hour, userName);

    final urgentAsync = ref.watch(urgentItemsProvider);
    final focusAsync = ref.watch(todayFocusItemsProvider);
    final workspacesAsync = ref.watch(workspacesListProvider);
    final statsAsync = ref.watch(quickStatsProvider);

    final List<Map<String, dynamic>> urgentItems = urgentAsync.when(
      data: (items) => items.map((t) => <String, dynamic>{
        'title': t.title,
        'deadline': t.deadline != null
            ? DateFormat('EEE · h:mm a').format(DateTime.fromMillisecondsSinceEpoch(t.deadline!))
            : (t.fireAt != null
                ? DateFormat('EEE · h:mm a').format(DateTime.fromMillisecondsSinceEpoch(t.fireAt!))
                : 'No deadline'),
        'isOverdue': (t.deadline ?? t.fireAt ?? 0) < now.millisecondsSinceEpoch,
      }).toList(),
      loading: () => <Map<String, dynamic>>[],
      error: (_, __) => <Map<String, dynamic>>[],
    );

    final List<Map<String, dynamic>> focusItems = focusAsync.when(
      data: (items) => items.map((t) => <String, dynamic>{
        'title': t.title,
        'estimatedTime': t.priority.toUpperCase(),
        'taskId': t.id,
        'item': t,
      }).toList(),
      loading: () => <Map<String, dynamic>>[],
      error: (_, __) => <Map<String, dynamic>>[],
    );

    final List<Map<String, dynamic>> workspaceItems = workspacesAsync.when(
      data: (workspaces) => workspaces.map((w) {
        final countAsync = ref.watch(workspaceItemCountProvider(w.id));
        final count = countAsync.value ?? 0;
        return <String, dynamic>{
          'id': w.id,
          'name': w.name,
          'taskCount': count,
          'color': int.tryParse(w.colorHex.replaceFirst('#', '0xFF')) ?? 0xFFC8FF00,
          'icon': Icons.folder,
        };
      }).toList(),
      loading: () => <Map<String, dynamic>>[],
      error: (_, __) => <Map<String, dynamic>>[],
    );

    return Scaffold(
      backgroundColor: AuraColors.bgBase,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────
            _buildHeader(greeting, dateStr),

            // ── Bento Grid ──────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AuraSpacing.md),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      const SizedBox(height: AuraSpacing.sm),

                      // Row 0: QUICK STATS
                      _StaggerCell(
                        animation: _cellAnims[0],
                        child: QuickStatsRow(
                          stats: statsAsync,
                        ),
                      ),

                      const SizedBox(height: AuraSpacing.sm),

                      _StaggerCell(
                        animation: _cellAnims[0],
                        child: SizedBox(
                          height: 160,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                flex: 60,
                                child: UrgentCell(
                                  items: urgentItems,
                                  onTap: () => context.push(Routes.search),
                                ),
                              ),
                              const SizedBox(width: AuraSpacing.sm),
                              Expanded(
                                flex: 40,
                                child: OrbCell(
                                  onTap: () => VoiceCaptureOverlay.show(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: AuraSpacing.sm),

                      // Row 2: TODAY'S FOCUS
                      _StaggerCell(
                        animation: _cellAnims[1],
                        child: FocusCell(
                          items: focusItems,
                          onItemTap: (itemMap) {
                            final item = itemMap['item'] as Item?;
                            if (item != null && (item.category == 'alarm' || item.kind == 'alarm')) {
                              EditAlarmModal.show(context, ref, item);
                            } else {
                              final id = itemMap['taskId'] as String;
                              context.push(Routes.taskRoute(id));
                            }
                          },
                        ),
                      ),

                      const SizedBox(height: AuraSpacing.sm),

                      // Row 3: WORKSPACES
                      _StaggerCell(
                        animation: _cellAnims[2],
                        child: WorkspacesCell(
                          workspaces: workspaceItems,
                          onWorkspaceTap: (id) {
                            if (id.isNotEmpty) context.push('/workspace/$id');
                          },
                          onAddTap: () => CreateWorkspaceModal.show(context),
                        ),
                      ),

                      const SizedBox(height: AuraSpacing.sm),

                      // Row 4: RECENT QUICK NOTES
                      _StaggerCell(
                        animation: _cellAnims[3],
                        child: _RecentNotesCell(
                          onViewAllTap: () => context.go(Routes.notes),
                          onNoteTap: (id) => context.push(Routes.taskRoute(id)),
                        ),
                      ),

                      const SizedBox(height: AuraSpacing.sm),

                      // Row 5: ACTIVE ALARMS
                      _StaggerCell(
                        animation: _cellAnims[4],
                        child: _ActiveAlarmsCell(
                          onViewAllTap: () => context.push('/alarms'),
                          onAlarmTap: (id) => context.push('/alarms'),
                        ),
                      ),

                      SizedBox(
                        height: AuraSpacing.orbSize +
                            AuraSpacing.bottomNavHeight +
                            AuraSpacing.md +
                            mediaQuery.padding.bottom,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String greeting, String dateStr) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AuraSpacing.md, AuraSpacing.md, AuraSpacing.md, AuraSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(greeting, style: AuraTypography.sectionHeader),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(dateStr, style: AuraTypography.overline),
                    const SizedBox(width: AuraSpacing.sm),
                    const SyncStatusBadge(),
                  ],
                ),
              ],
            ),
          ),
          _IconButton(
            icon: LucideIcons.search,
            onTap: () => context.push(Routes.search),
          ),
          const SizedBox(width: AuraSpacing.sm),
          _IconButton(
            icon: LucideIcons.settings,
            onTap: () => context.go(Routes.settings),
          ),
        ],
      ),
    );
  }

  String _greeting(int hour, String name) {
    final firstName = name.split(' ').first;
    if (hour < 12) return 'Good morning, $firstName.';
    if (hour < 17) return 'Good afternoon, $firstName.';
    return 'Good evening, $firstName.';
  }
}

class _StaggerCell extends StatelessWidget {
  const _StaggerCell({required this.animation, required this.child});
  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) => Opacity(
        opacity: animation.value,
        child: Transform.translate(
          offset: Offset(0, 8 * (1 - animation.value)),
          child: child,
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AuraColors.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AuraColors.border, width: 1),
        ),
        child: Icon(icon, size: 20, color: AuraColors.textPrimary),
      ),
    );
  }
}

class _RecentNotesCell extends ConsumerWidget {
  const _RecentNotesCell({
    required this.onViewAllTap,
    required this.onNoteTap,
  });

  final VoidCallback onViewAllTap;
  final ValueChanged<String> onNoteTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(notesListProvider);
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(AuraSpacing.md),
      decoration: BoxDecoration(
        color: AuraColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AuraColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(LucideIcons.fileText, color: primaryColor, size: 18),
                  const SizedBox(width: 8),
                  Text('RECENT QUICK NOTES', style: AuraTypography.cardTitle),
                ],
              ),
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onViewAllTap();
                },
                child: Row(
                  children: [
                    Text('VIEW ALL', style: AuraTypography.overline.copyWith(color: primaryColor)),
                    const SizedBox(width: 2),
                    Icon(LucideIcons.chevronRight, size: 14, color: primaryColor),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AuraSpacing.sm),
          notesAsync.when(
            data: (notes) {
              if (notes.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'No quick notes saved. Tap the orb or say "Note down meeting ideas" to record one.',
                    style: AuraTypography.body.copyWith(fontStyle: FontStyle.italic),
                  ),
                );
              }
              final recent = notes.take(3).toList();
              return SizedBox(
                height: 90,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: recent.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final note = recent[index];
                    return GestureDetector(
                      onTap: () => onNoteTap(note.id),
                      child: Container(
                        width: 170,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AuraColors.bgElevated,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AuraColors.border, width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              note.title,
                              style: AuraTypography.bodyPrimary.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              note.notes ?? 'No additional details',
                              style: AuraTypography.caption,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
            loading: () => const SizedBox(height: 60, child: Center(child: CircularProgressIndicator())),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _ActiveAlarmsCell extends ConsumerWidget {
  const _ActiveAlarmsCell({
    required this.onViewAllTap,
    required this.onAlarmTap,
  });

  final VoidCallback onViewAllTap;
  final ValueChanged<String> onAlarmTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alarmsAsync = ref.watch(alarmsListProvider);
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(AuraSpacing.md),
      decoration: BoxDecoration(
        color: AuraColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AuraColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(LucideIcons.alarmClock, color: primaryColor, size: 18),
                  const SizedBox(width: 8),
                  Text('ACTIVE ALARMS', style: AuraTypography.cardTitle),
                ],
              ),
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onViewAllTap();
                },
                child: Row(
                  children: [
                    Text('MANAGE', style: AuraTypography.overline.copyWith(color: primaryColor)),
                    const SizedBox(width: 2),
                    Icon(LucideIcons.chevronRight, size: 14, color: primaryColor),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AuraSpacing.sm),
          alarmsAsync.when(
            data: (alarms) {
              if (alarms.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'No alarms currently scheduled. Tap the orb or say "Set an alarm for 7 AM" to create one.',
                    style: AuraTypography.body.copyWith(fontStyle: FontStyle.italic),
                  ),
                );
              }
              final active = alarms.take(2).toList();
              return Column(
                children: active.map((alarm) {
                  final fireAtDt = alarm.fireAt != null
                      ? DateTime.fromMillisecondsSinceEpoch(alarm.fireAt!)
                      : null;
                  final timeStr = fireAtDt != null
                      ? DateFormat('h:mm a').format(fireAtDt)
                      : 'Daily Alarm';

                  return GestureDetector(
                    onTap: () => onAlarmTap(alarm.id),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: AuraColors.bgElevated,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AuraColors.border, width: 1),
                      ),
                      child: Row(
                        children: [
                          Icon(LucideIcons.bell, size: 16, color: primaryColor),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              alarm.title,
                              style: AuraTypography.bodyPrimary,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            timeStr,
                            style: AuraTypography.cardTitle.copyWith(
                              color: primaryColor,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const SizedBox(height: 50, child: Center(child: CircularProgressIndicator())),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
