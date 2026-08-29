import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app_shell.dart';
import '../../features/alarms/alarms_screen.dart';
import '../../features/briefing/briefing_screen.dart';
import '../../features/capture/presentation/capture_overlay_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/notes/notes_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/share/share_receiver_screen.dart';
import '../../features/tasks/task_detail_screen.dart';
import '../../features/workspaces/workspace_screens.dart';

// ── Onboarding Gate ───────────────────────────────────────────────────────────

/// Manages the onboarding gate state, reading and persisting completion status
/// to [SharedPreferences].
///
/// Extends [ChangeNotifier] so it can be used as [GoRouter.refreshListenable].
class OnboardingGateNotifier extends ChangeNotifier {
  static const _key = 'ONBOARDING_COMPLETED';
  final SharedPreferences _prefs;

  bool _isComplete;

  OnboardingGateNotifier(this._prefs)
      : _isComplete = _prefs.getBool(_key) ?? false;

  /// Whether onboarding has been completed.
  bool get isComplete => _isComplete;

  /// Marks onboarding as complete and unlocks all gated routes.
  Future<void> complete() async {
    await _prefs.setBool(_key, true);
    _isComplete = true;
    notifyListeners();
  }

  /// Resets onboarding (e.g. on app data reset), immediately locking all
  /// gated routes without requiring an app restart.
  Future<void> reset() async {
    await _prefs.remove(_key);
    _isComplete = false;
    notifyListeners();
  }
}

/// Riverpod provider for [OnboardingGateNotifier].
final onboardingGateProvider = Provider<OnboardingGateNotifier>((ref) {
  throw UnimplementedError(
      'onboardingGateProvider must be overridden in ProviderScope.');
});

// ── Route Names ───────────────────────────────────────────────────────────────

abstract final class Routes {
  static const home = '/';
  static const onboarding = '/onboarding';
  static const captureOverlay = '/capture-overlay';
  static const share = '/share';
  static const alarms = '/alarms';
  static const workspaces = '/workspaces';
  static const workspaceDetail = '/workspace/:id';
  static const notes = '/notes';
  static const settings = '/settings';
  static const taskDetail = '/task/:id';
  static const briefing = '/briefing';

  /// Un-gated routes that bypass onboarding.
  static const Set<String> whitelist = {
    captureOverlay,
    share,
    onboarding,
  };
}

// ── Router builder ────────────────────────────────────────────────────────────

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

/// Builds the app-wide [GoRouter] with onboarding gate redirect logic and ShellRoute.
GoRouter buildAppRouter(OnboardingGateNotifier gateNotifier) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: Routes.home,
    refreshListenable: gateNotifier,
    redirect: (context, state) {
      final isComplete = gateNotifier.isComplete;
      final location = state.uri.toString();

      if (!isComplete) {
        final isWhitelisted =
            Routes.whitelist.any((r) => location.startsWith(r));
        if (isWhitelisted) return null;
        return Routes.onboarding;
      }

      if (location == Routes.onboarding) return Routes.home;

      return null;
    },
    routes: [
      // ── Un-gated standalone routes ───────────────────────────────────────
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: Routes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: Routes.captureOverlay,
        builder: (context, state) => const FloatingCaptureOverlayScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: Routes.share,
        builder: (context, state) => const ShareReceiverScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: Routes.briefing,
        builder: (context, state) => const MorningBriefingScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: Routes.taskDetail,
        builder: (context, state) => TaskDetailScreen(
          taskId: state.pathParameters['id'] ?? '',
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: Routes.workspaceDetail,
        builder: (context, state) => WorkspaceDetailScreen(
          workspaceId: state.pathParameters['id'] ?? '',
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: Routes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),

      // ── Gated Shell navigation (BottomNav tabs) ──────────────────────────
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => AppShell(child: child),
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
            path: Routes.workspaces,
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
        ],
      ),
    ],
  );
}
