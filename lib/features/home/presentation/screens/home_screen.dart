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
import '../providers/home_providers.dart';
import '../widgets/aura_date_navigator.dart';
import '../widgets/day_agenda_view.dart';
import '../widgets/quick_stats_row.dart';
import '../widgets/sync_status_badge.dart';

/// Home Screen — AURA Daily Cockpit with Split Stats, Date Navigator & Day Agenda.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _staggerCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _staggerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(
      parent: _staggerCtrl,
      curve: Curves.easeOut,
    );

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

    final userName = ref.watch(userNameProvider);
    final greeting = timeAwareGreeting(now.hour, userName: userName);

    return Scaffold(
      backgroundColor: AuraColors.bgBase,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────
            _buildHeader(greeting, dateStr),

            // ── Daily Cockpit Content ───────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AuraSpacing.md),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AuraSpacing.xs),

                        // Top Row: Split Stats (Today's Pending/Done + Overdue Accumulator)
                        const QuickStatsRow(),

                        const SizedBox(height: 12),

                        // Middle: 3-Part Date Switcher & Mini-Week Activity Bar
                        const AuraDateNavigator(),

                        const SizedBox(height: 14),

                        // Bottom: Swipeable Day Agenda (Timed & Anytime)
                        const DayAgendaView(),

                        SizedBox(
                          height: AuraSpacing.orbSize +
                              AuraSpacing.bottomNavHeight +
                              AuraSpacing.lg +
                              mediaQuery.padding.bottom,
                        ),
                      ],
                    ),
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
