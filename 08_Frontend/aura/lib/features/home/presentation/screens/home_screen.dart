import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/constants/icons.dart';
import '../../../../database/daos/task_dao.dart';
import '../providers/home_providers.dart';
import '../widgets/home_bento_cells.dart';
import '../widgets/sync_status_badge.dart';
import '../../../capture/presentation/widgets/voice_capture_overlay.dart';
import '../../../workspaces/presentation/widgets/create_workspace_modal.dart';

/// Home Screen — Sprint 4b.
/// Bento Grid layout connected reactively to Drift DB.
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
    // Stagger animation: 5 cells × 40ms apart
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

    WidgetsBinding.instance.addPostFrameCallback((_) => _staggerCtrl.forward());
  }

  @override
  void dispose() {
    _staggerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final greeting = _greeting(now.hour);
    final dateStr = DateFormat('EEEE, MMMM d').format(now);
    final mediaQuery = MediaQuery.of(context);

    // Watch real streams from Drift DB via Riverpod
    final urgentAsync = ref.watch(urgentTasksProvider);
    final focusAsync = ref.watch(focusTasksProvider);
    final habitsAsync = ref.watch(habitsProvider);
    final workspacesAsync = ref.watch(homeWorkspacesProvider);

    // Map tasks to widget item maps
    final List<Map<String, dynamic>> urgentItems = urgentAsync.when(
      data: (tasks) => tasks.map((t) => <String, dynamic>{
        'title': t.name,
        'deadline': t.deadline != null
            ? DateFormat('EEE · h:mm a').format(DateTime.fromMillisecondsSinceEpoch(t.deadline!))
            : 'No deadline',
        'isOverdue': t.deadline != null && t.deadline! < now.millisecondsSinceEpoch,
      }).toList(),
      loading: () => <Map<String, dynamic>>[],
      error: (_, __) => <Map<String, dynamic>>[],
    );

    final List<Map<String, dynamic>> focusItems = focusAsync.when(
      data: (tasks) => tasks.map((t) => <String, dynamic>{
        'title': t.name,
        'estimatedTime': t.priority.toUpperCase(),
        'taskId': t.id,
      }).toList(),
      loading: () => <Map<String, dynamic>>[],
      error: (_, __) => <Map<String, dynamic>>[],
    );

    final List<Map<String, dynamic>> nextUpItems = focusAsync.when(
      data: (tasks) => tasks.map((t) => <String, dynamic>{
        'title': t.name,
        'subtitle': t.deadline != null
            ? DateFormat('EEE · h:mm a').format(DateTime.fromMillisecondsSinceEpoch(t.deadline!))
            : 'Active Task',
        'isEvent': false,
      }).toList(),
      loading: () => <Map<String, dynamic>>[],
      error: (_, __) => <Map<String, dynamic>>[],
    );

    final List<Map<String, dynamic>> habitItems = habitsAsync.when(
      data: (tasks) => tasks.map((t) => <String, dynamic>{
        'id': t.id,
        'title': t.name,
        'status': t.status == 'done' ? 'done' : 'pending',
      }).toList(),
      loading: () => <Map<String, dynamic>>[],
      error: (_, __) => <Map<String, dynamic>>[],
    );

    final List<Map<String, dynamic>> workspaceItems = workspacesAsync.when(
      data: (workspaces) => workspaces.map((w) {
        final countAsync = ref.watch(workspaceTaskCountProvider(w.id));
        final count = countAsync.value ?? 0;
        return <String, dynamic>{
          'id': w.id,
          'name': w.name,
          'taskCount': count,
          'color': int.tryParse(w.colorHex.replaceFirst('#', '0xFF')) ?? 0xFFB57BFF,
          'icon': Icons.folder,
        };
      }).toList(),
      loading: () => <Map<String, dynamic>>[
        {'id': '', 'name': 'General', 'taskCount': 0, 'color': 0xFFB57BFF, 'icon': Icons.folder},
      ],
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

                      // Row 1: URGENT + ORB (60% / 40%)
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
                                  onTap: () => _onUrgentTap(),
                                ),
                              ),
                              const SizedBox(width: AuraSpacing.sm),
                              Expanded(
                                flex: 40,
                                child: OrbCell(
                                  onTap: () => _onOrbTap(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: AuraSpacing.sm),

                      // Row 2: TODAY'S FOCUS (full width)
                      _StaggerCell(
                        animation: _cellAnims[1],
                        child: FocusCell(
                          items: focusItems,
                          onItemTap: (taskId) => _onTaskTap(taskId),
                        ),
                      ),

                      const SizedBox(height: AuraSpacing.sm),

                      // Row 3: NEXT UP + HABITS (50% / 50%)
                      _StaggerCell(
                        animation: _cellAnims[2],
                        child: SizedBox(
                          height: 160,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: NextUpCell(
                                  items: nextUpItems,
                                  onTap: () => _onNextUpTap(),
                                ),
                              ),
                              const SizedBox(width: AuraSpacing.sm),
                              Expanded(
                                child: HabitsCell(
                                  habits: habitItems,
                                  onHabitToggle: (idx) {
                                    if (idx < habitItems.length) {
                                      final habit = habitItems[idx];
                                      final habitId = habit['id'] as String?;
                                      final currentStatus = habit['status'] as String?;
                                      if (habitId != null) {
                                        _toggleHabitInDb(habitId, currentStatus == 'done');
                                      }
                                    }
                                  },
                                  onTap: () => _onHabitsTap(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: AuraSpacing.sm),

                      // Row 4: WORKSPACES (full width)
                      _StaggerCell(
                        animation: _cellAnims[3],
                        child: WorkspacesCell(
                          workspaces: workspaceItems,
                          onWorkspaceTap: (name) => _onWorkspaceTap(name),
                          onAddTap: () => _onAddWorkspace(),
                        ),
                      ),

                      // Space for floating orb + bottom nav
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
          // Search icon button
          _IconButton(
            icon: AuraIcons.search,
            onTap: () => _onSearchTap(),
          ),
          const SizedBox(width: AuraSpacing.sm),
          // Profile icon button
          _IconButton(
            icon: AuraIcons.profile,
            onTap: () => _onProfileTap(),
          ),
        ],
      ),
    );
  }

  // ── Interaction handlers ──────────────────────────────────────────────────

  void _onUrgentTap() {
    HapticFeedback.lightImpact();
  }

  void _onOrbTap() {
    HapticFeedback.mediumImpact();
    VoiceCaptureOverlay.show(context);
  }

  void _onTaskTap(String taskId) {
    HapticFeedback.lightImpact();
  }

  void _onNextUpTap() {
    HapticFeedback.lightImpact();
  }

  Future<void> _toggleHabitInDb(String taskId, bool currentlyDone) async {
    HapticFeedback.mediumImpact();
    final taskDao = ref.read(taskDaoProvider);
    if (currentlyDone) {
      await taskDao.markTodo(taskId);
    } else {
      await taskDao.markDone(taskId);
    }
  }

  void _onHabitsTap() {
    HapticFeedback.lightImpact();
  }

  void _onWorkspaceTap(String id) {
    if (id.isEmpty) return;
    HapticFeedback.lightImpact();
    context.push('/workspace/$id');
  }

  void _onAddWorkspace() {
    HapticFeedback.mediumImpact();
    CreateWorkspaceModal.show(context);
  }

  void _onSearchTap() {
    _showCaptureSnack(msg: 'Search — coming in Sprint 7');
  }

  void _onProfileTap() {
    _showCaptureSnack(msg: 'Settings — coming in Sprint 10');
  }

  void _showCaptureSnack({required String msg}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: AuraTypography.bodyPrimary.copyWith(fontSize: 13),
        ),
        backgroundColor: AuraColors.bgCard,
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: AuraColors.border, width: AuraSpacing.borderWidth),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _greeting(int hour) {
    if (hour < 12) return 'Good morning, Ishan.';
    if (hour < 17) return 'Good afternoon, Ishan.';
    return 'Good evening, Ishan.';
  }
}

// ── Stagger cell animation wrapper ───────────────────────────────────────────

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

// ── Small icon button ─────────────────────────────────────────────────────────

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
          border: Border.all(color: AuraColors.border, width: AuraSpacing.borderWidth),
          boxShadow: const [
            BoxShadow(
              color: AuraColors.shadow,
              offset: Offset(2, 2),
              blurRadius: 0,
            ),
          ],
        ),
        child: Icon(icon, size: AuraIcons.sizeStandard, color: AuraColors.textPrimary),
      ),
    );
  }
}
