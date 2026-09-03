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
import '../../features/reminders/presentation/screens/reminders_screen.dart';
import '../../features/capture/presentation/screens/share_receive_screen.dart';
import '../../features/capture/presentation/screens/floating_capture_overlay_screen.dart';

import '../constants/colors.dart';
import '../constants/typography.dart';
import '../widgets/bottom_nav.dart';
import '../../features/home/presentation/widgets/floating_orb.dart';
import '../../features/capture/presentation/widgets/voice_capture_overlay.dart';
import '../../platform/overlay_channel.dart';

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

/// Onboarding gate state. Lives in Riverpod (not a global mutable flag) so
/// Reset App Data can invalidate it — previously the stale `true` let users
/// skip onboarding after clearing data, and deep links bypassed the guard
/// entirely.
class OnboardingGateNotifier extends StateNotifier<bool> {
  OnboardingGateNotifier() : super(false) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return; // provider may have been disposed mid-load (tests)
    state = prefs.getBool('onboarding_complete') ?? false;
  }

  /// Syncs the gate from a redirect-time disk read (avoids a race where the
  /// async constructor load lands after a redirect already checked).
  void hydrate(bool value) {
    if (!mounted) return;
    if (value && !state) state = true;
  }

  Future<void> complete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    if (!mounted) return;
    state = true;
  }

  /// Called by Reset App Data: re-locks every route behind onboarding.
  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('onboarding_complete');
    if (!mounted) return;
    state = false;
  }
}

final onboardingGateProvider =
    StateNotifierProvider<OnboardingGateNotifier, bool>((ref) {
  return OnboardingGateNotifier();
});

/// Routes reachable before onboarding completes (share target and the
/// capture overlay must work regardless of setup state).
const _preOnboardingAllowedLocations = {Routes.onboarding, Routes.share, '/capture-overlay'};

/// Riverpod provider for the go_router instance.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: Routes.home,
    debugLogDiagnostics: false,
    redirect: (context, state) async {
      // Allow-list short-circuit (share engine / capture overlay / onboarding).
      if (_preOnboardingAllowedLocations.contains(state.matchedLocation)) {
        return null;
      }

      final onboarded = ref.read(onboardingGateProvider);
      if (onboarded) return null;

      // Gate not yet hydrated from disk — check directly to avoid flashing.
      final prefs = await SharedPreferences.getInstance();
      final done = prefs.getBool('onboarding_complete') ?? false;
      ref.read(onboardingGateProvider.notifier).hydrate(done);
      return done ? null : Routes.onboarding;
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
        path: Routes.reminders,
        builder: (context, state) => const RemindersScreen(),
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

class _MainShellState extends ConsumerState<_MainShell> with WidgetsBindingObserver {
  static const _routes = [
    Routes.home,
    Routes.alarms,
    '/workspaces',
    Routes.notes,
    Routes.settings,
  ];

  // Default to true to prevent the in-app orb from briefly flashing on app launch
  // while checking if the native overlay service is running.
  bool _isOverlayRunning = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkOverlayStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkOverlayStatus();
    }
  }

  Future<void> _checkOverlayStatus() async {
    final running = await OverlayChannel.isRunning();
    if (mounted && running != _isOverlayRunning) {
      setState(() => _isOverlayRunning = running);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Derive the active tab purely from the current router location so that
    // deep links and programmatic pushes always keep the nav bar in sync.
    final location = GoRouterState.of(context).matchedLocation;
    final idx = _routes.indexWhere((r) => r == '/' ? location == '/' : location.startsWith(r));
    final effectiveIndex = idx < 0 ? 0 : idx;

    return Scaffold(
      backgroundColor: AuraColors.bgOf(context),
      body: Stack(
        children: [
          widget.child,
          if (!_isOverlayRunning)
            FloatingOrb(
              onTap: () => VoiceCaptureOverlay.show(context),
            ),
        ],
      ),
      bottomNavigationBar: AuraBottomNav(
        selectedIndex: effectiveIndex,
        onDestinationSelected: (index) {
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
