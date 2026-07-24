import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/home/presentation/widgets/floating_orb.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/workspaces/presentation/screens/workspace_list_screen.dart';
import '../../features/workspaces/presentation/screens/workspace_detail_screen.dart';
import '../../features/tasks/presentation/screens/task_detail_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../constants/colors.dart';
import '../constants/spacing.dart';
import '../constants/typography.dart';

/// Route name constants — use these everywhere instead of string literals.
abstract final class Routes {
  static const String home       = '/';
  static const String workspace  = '/workspace/:id';
  static const String task       = '/task/:id';
  static const String calendar   = '/calendar';
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
/// Marked as keep-alive so the router is not recreated on every rebuild.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: Routes.home,
    debugLogDiagnostics: false,
    redirect: _handleRedirect,
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
            path: '/workspaces',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: WorkspaceListScreen(),
            ),
          ),
          GoRoute(
            path: '/calendar',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: _PlaceholderScreen(title: 'Calendar'),
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

      // ── Deep links ────────────────────────────────────────────────────────
      GoRoute(
        path: Routes.briefing,
        builder: (context, state) => const _PlaceholderScreen(title: 'Morning Briefing'),
      ),
      GoRoute(
        path: Routes.search,
        builder: (context, state) => const _PlaceholderScreen(title: 'Search'),
      ),
    ],
    errorBuilder: (context, state) => _ErrorScreen(error: state.error),
  );
});

/// Checks if onboarding should be shown on first launch.
Future<String?> _handleRedirect(BuildContext context, GoRouterState state) async {
  final prefs = await SharedPreferences.getInstance();
  final onboardingDone = prefs.getBool('onboarding_complete') ?? false;
  if (!onboardingDone && state.matchedLocation == Routes.home) {
    return Routes.onboarding;
  }
  return null;
}

// ── Main navigation shell ──────────────────────────────────────────────────

/// Bottom navigation shell — wraps all main tabs + floating orb.
class _MainShell extends StatefulWidget {
  const _MainShell({required this.child});
  final Widget child;

  @override
  State<_MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<_MainShell> {
  int _selectedIndex = 0;

  static const _routes = [
    Routes.home,
    '/calendar',
    '/workspaces',
    Routes.settings,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuraColors.bgBase,
      body: Stack(
        children: [
          widget.child,
          // Floating orb — draggable, always above bottom nav
          FloatingOrb(onTap: _onCaptureTap),
        ],
      ),
      bottomNavigationBar: AuraBottomNav(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
          context.go(_routes[index]);
        },
      ),
    );
  }

  void _onCaptureTap() {
    // Sprint 4: open voice capture overlay
  }
}

// ── Placeholder screen ─────────────────────────────────────────────────────

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuraColors.bgBase,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: AuraTypography.sectionHeader),
              const SizedBox(height: AuraSpacing.sm),
              Text('Coming soon.', style: AuraTypography.body),
            ],
          ),
        ),
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
