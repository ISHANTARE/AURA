import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/home/presentation/screens/morning_briefing_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/workspaces/presentation/screens/workspace_list_screen.dart';
import '../../features/workspaces/presentation/screens/workspace_detail_screen.dart';
import '../../features/tasks/presentation/screens/task_detail_screen.dart';
import '../../features/tasks/presentation/screens/search_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/alarms/presentation/screens/alarms_screen.dart';
import '../../features/notes/presentation/screens/notes_screen.dart';
import '../../features/capture/presentation/screens/share_receive_screen.dart';
import '../../features/capture/presentation/screens/floating_capture_overlay_screen.dart';

import '../constants/colors.dart';
import '../constants/typography.dart';
import '../widgets/bottom_nav.dart';

/// Route name constants — use these everywhere instead of string literals.
abstract final class Routes {
  static const String home       = '/';
  static const String workspace  = '/workspace/:id';
  static const String task       = '/task/:id';
  static const String calendar   = '/calendar';
  static const String reminders  = '/reminders';
  static const String alarms     = '/alarms';
  static const String notes      = '/notes';
  static const String search     = '/search';
  static const String settings   = '/settings';
  static const String onboarding = '/onboarding';
  static const String briefing   = '/briefing';
  static const String share      = '/share';

  /// Construct workspace route with a specific ID.
  static String workspaceRoute(String id) => '/workspace/$id';
  /// Construct task route with a specific ID.
  static String taskRoute(String id) => '/task/$id';
}

/// Riverpod provider for the go_router instance.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: Routes.home,
    debugLogDiagnostics: false,
    redirect: (context, state) async {
      // Only guard the root route on cold start
      if (state.matchedLocation != Routes.home) return null;
      final prefs = await SharedPreferences.getInstance();
      final onboardingDone = prefs.getBool('onboarding_complete') ?? false;
      if (!onboardingDone) return Routes.onboarding;
      return null;
    },
    routes: [
      // ── Main shell ────────────────────────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => _MainShell(child: child),
        routes: [
          GoRoute(
            path: Routes.home,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: Routes.alarms,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AlarmsScreen(),
            ),
          ),
          GoRoute(
            path: '/workspaces',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: WorkspaceListScreen(),
            ),
          ),
          GoRoute(
            path: Routes.notes,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: NotesScreen(),
            ),
          ),
          GoRoute(
            path: Routes.settings,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsScreen(),
            ),
          ),
        ],
      ),

      // ── Detail screens (full-screen, no shell) ────────────────────────────
      GoRoute(
        path: Routes.workspace,
        builder: (context, state) => WorkspaceDetailScreen(
          workspaceId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: Routes.task,
        builder: (context, state) => TaskDetailScreen(
          taskId: state.pathParameters['id']!,
        ),
      ),

      // ── Onboarding ────────────────────────────────────────────────────────
      GoRoute(
        path: Routes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),

      // ── Deep links & Actions ──────────────────────────────────────────────
      GoRoute(
        path: Routes.briefing,
        builder: (context, state) => const MorningBriefingScreen(),
      ),
      GoRoute(
        path: Routes.search,
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: Routes.share,
        builder: (context, state) => const ShareReceiveScreen(),
      ),
      GoRoute(
        path: '/capture-overlay',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          opaque: false,
          barrierColor: Colors.black.withValues(alpha: 0.5),
          barrierDismissible: true,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: const FloatingCaptureOverlayScreen(),
        ),
      ),
    ],
    errorBuilder: (context, state) => _ErrorScreen(error: state.error),
  );
});

// ── Main navigation shell ──────────────────────────────────────────────────

class _MainShell extends ConsumerStatefulWidget {
  const _MainShell({required this.child});
  final Widget child;

  @override
  ConsumerState<_MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<_MainShell> {
  int _selectedIndex = 0;

  static const _routes = [
    Routes.home,
    Routes.alarms,
    '/workspaces',
    Routes.notes,
    Routes.settings,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuraColors.bgBase,
      body: widget.child,
      bottomNavigationBar: AuraBottomNav(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
          context.go(_routes[index]);
        },
      ),
    );
  }
}

// ── Error screen ──────────────────────────────────────────────────────────

class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen({required this.error});
  final Exception? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuraColors.bgBase,
      body: Center(
        child: Text('Navigation error: $error', style: AuraTypography.body),
      ),
    );
  }
}
