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
import '../../../../core/utils/greeting.dart';
import '../../../capture/presentation/widgets/voice_capture_overlay.dart';
import '../providers/home_providers.dart';
import '../widgets/aura_date_navigator.dart';
import '../widgets/day_agenda_view.dart';
import '../widgets/home_bento_cells.dart';
import '../widgets/quick_stats_row.dart';
import '../widgets/sync_status_badge.dart';

/// Home Screen — AURA Daily Cockpit with Day-Specific Agenda & Real-Time Stats.
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

    for (int i = 0; i < 4; i++) {
      final start = (i * 0.12).clamp(0.0, 1.0);
      final end = (start + 0.50).clamp(0.0, 1.0);
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
    final greeting = timeAwareGreeting(now.hour, userName: userName);

    final urgentAsync = ref.watch(urgentItemsProvider);

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

    final bg = AuraColors.bgOf(context);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────
            _buildHeader(greeting, dateStr),

            // ── Cockpit Content ─────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AuraSpacing.md),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      const SizedBox(height: AuraSpacing.xs),

                      // 1. Top Quick Stats Row (Always Today's data)
                      _StaggerCell(
                        animation: _cellAnims[0],
                        child: const QuickStatsRow(),
                      ),

                      const SizedBox(height: AuraSpacing.sm),

                      // 2. Row 1: URGENT (58%) + ORB (42%)
                      _StaggerCell(
                        animation: _cellAnims[1],
                        child: SizedBox(
                          height: 148,
                          child: Row(
                            children: [
                              Expanded(
                                flex: 58,
                                child: UrgentCell(
                                  items: urgentItems,
                                  onTap: () => context.push(Routes.search),
                                ),
                              ),
                              const SizedBox(width: AuraSpacing.sm),
                              Expanded(
                                flex: 42,
                                child: OrbCell(
                                  onTap: () => VoiceCaptureOverlay.show(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: AuraSpacing.sm),

                      // 3. Day Navigation Control (< -> Date -> >) + [Pending | Done] Box
                      _StaggerCell(
                        animation: _cellAnims[2],
                        child: const AuraDateNavigator(),
                      ),

                      const SizedBox(height: AuraSpacing.sm),

                      // 4. Day-Specific Agenda / Task List
                      _StaggerCell(
                        animation: _cellAnims[3],
                        child: const DayAgendaView(),
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
                Text(
                  greeting,
                  style: AuraTypography.sectionHeader.copyWith(
                    color: AuraColors.textPrimaryOf(context),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      dateStr,
                      style: AuraTypography.overline.copyWith(
                        color: AuraColors.textMutedOf(context),
                      ),
                    ),
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
}

// ── Animation & UI Helpers ────────────────────────────────────────────────────

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
          offset: Offset(0, 10 * (1 - animation.value)),
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
    final cardBg = AuraColors.cardOf(context);
    final borderColor = AuraColors.borderOf(context);
    final textPrimary = AuraColors.textPrimaryOf(context);

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Icon(icon, size: 20, color: textPrimary),
      ),
    );
  }
}
