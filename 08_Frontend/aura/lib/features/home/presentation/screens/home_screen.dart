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
                                  onTap: () {},
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
                          onItemTap: (id) => context.push(Routes.taskRoute(id)),
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
          border: Border.all(color: AuraColors.border, width: AuraSpacing.borderWidth),
          boxShadow: const [
            BoxShadow(
              color: AuraColors.shadow,
              offset: Offset(2, 2),
              blurRadius: 0,
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: AuraColors.textPrimary),
      ),
    );
  }
}
