import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/constants/icons.dart';
import '../widgets/home_bento_cells.dart';

/// Home Screen — Sprint 2.
/// Bento Grid layout matching wireframe 01_home_screen.md.
/// Uses static sample data while Drift DAOs are wired in Sprint 3.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _staggerCtrl;
  final List<Animation<double>> _cellAnims = [];

  // ── Sample data (replaced by Riverpod providers in Sprint 3) ──────────────
  final _urgentItems = [
    {'title': 'ML Assignment', 'deadline': 'Due tonight 11:59 PM', 'isOverdue': false},
    {'title': 'DBMS Quiz', 'deadline': 'Due today 2:00 PM', 'isOverdue': false},
  ];

  final _focusItems = [
    {'title': 'Complete feature engineering', 'estimatedTime': '~2 hrs', 'taskId': '1'},
    {'title': 'Review GATE Algorithms PYQs', 'estimatedTime': '~1 hr', 'taskId': '2'},
    {'title': 'Submit patent draft', 'estimatedTime': '~30 min', 'taskId': '3'},
  ];

  final _nextUpItems = [
    {'title': 'Internship standup', 'subtitle': 'Thu · 10:00 AM', 'isEvent': true},
    {'title': 'Patent submission', 'subtitle': '4 days left', 'isEvent': false},
    {'title': 'Lab Report', 'subtitle': '2 days left', 'isEvent': false},
  ];

  final _habitItems = [
    {'title': 'DSA Practice', 'status': 'missed'},
    {'title': 'Exercise', 'status': 'done'},
    {'title': 'Reading', 'status': 'pending'},
  ];

  final _workspaces = [
    {'name': 'VIT', 'taskCount': 8, 'color': 0xFFB57BFF, 'icon': LucideIcons.graduationCap},
    {'name': 'GATE', 'taskCount': 3, 'color': 0xFFF59E0B, 'icon': LucideIcons.target},
    {'name': 'Intern', 'taskCount': 2, 'color': 0xFF39FF88, 'icon': LucideIcons.briefcase},
    {'name': 'Personal', 'taskCount': 5, 'color': 0xFF4DFFFF, 'icon': LucideIcons.user},
  ];

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
                                  items: _urgentItems,
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
                          items: _focusItems,
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
                                  items: _nextUpItems,
                                  onTap: () => _onNextUpTap(),
                                ),
                              ),
                              const SizedBox(width: AuraSpacing.sm),
                              Expanded(
                                child: HabitsCell(
                                  habits: List<Map<String, dynamic>>.from(_habitItems),
                                  onHabitToggle: (idx) => _toggleHabit(idx),
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
                          workspaces: _workspaces,
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
                Text(dateStr, style: AuraTypography.overline),
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
    // Sprint 3: navigate to urgent tasks filter
  }

  void _onOrbTap() {
    HapticFeedback.mediumImpact();
    // Sprint 4: show voice capture overlay
    _showCaptureSnack();
  }

  void _onTaskTap(String taskId) {
    // Sprint 3: navigate to task detail
  }

  void _onNextUpTap() {
    HapticFeedback.lightImpact();
    // Sprint 5: navigate to calendar
  }

  void _toggleHabit(int idx) {
    setState(() {
      final current = _habitItems[idx]['status'] as String;
      _habitItems[idx]['status'] =
          current == 'done' ? 'pending' : 'done';
    });
  }

  void _onHabitsTap() {
    // Sprint 3: navigate to recurring tasks
  }

  void _onWorkspaceTap(String name) {
    // Sprint 3: navigate to workspace detail
  }

  void _onAddWorkspace() {
    // Sprint 3: show create workspace sheet
    _showCaptureSnack(msg: 'Create workspace — coming in Sprint 3');
  }

  void _onSearchTap() {
    // Sprint 6: search overlay
  }

  void _onProfileTap() {
    // Sprint 7: profile / settings
  }

  void _showCaptureSnack({String? msg}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg ?? 'Voice capture — coming in Sprint 4',
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
    if (hour < 12) return 'Good morning, Ishant.';
    if (hour < 17) return 'Good afternoon, Ishant.';
    return 'Good evening, Ishant.';
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
