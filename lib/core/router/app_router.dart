import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  // This must be overridden in ProviderScope with an actual SharedPreferences
  // instance. See main.dart for the override.
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
  static const search = '/search';
  static const reminders = '/reminders';

  /// Un-gated routes that bypass onboarding.
  static const Set<String> whitelist = {
    captureOverlay,
    share,
    onboarding,
  };
}

// ── Router builder ────────────────────────────────────────────────────────────

/// Builds the app-wide [GoRouter] with onboarding gate redirect logic.
///
/// Gated routes redirect to `/onboarding` if onboarding has not been completed.
/// Un-gated whitelist routes ([Routes.whitelist]) are always accessible.
GoRouter buildAppRouter(OnboardingGateNotifier gateNotifier) {
  return GoRouter(
    initialLocation: Routes.home,
    refreshListenable: gateNotifier,
    redirect: (context, state) {
      final isComplete = gateNotifier.isComplete;
      final location = state.uri.toString();

      if (!isComplete) {
        // Allow whitelist routes when onboarding is incomplete.
        final isWhitelisted =
            Routes.whitelist.any((r) => location.startsWith(r));
        if (isWhitelisted) return null;
        return Routes.onboarding;
      }

      // If onboarding is complete and user navigates to /onboarding, redirect to home.
      if (location == Routes.onboarding) return Routes.home;

      return null; // No redirect needed.
    },
    routes: [
      // ── Un-gated routes ──────────────────────────────────────────────────
      GoRoute(
        path: Routes.onboarding,
        builder: (context, state) =>
            const _PlaceholderScreen(name: 'Onboarding'),
      ),
      GoRoute(
        path: Routes.captureOverlay,
        builder: (context, state) =>
            const _PlaceholderScreen(name: 'Voice Capture Overlay'),
      ),
      GoRoute(
        path: Routes.share,
        builder: (context, state) =>
            const _PlaceholderScreen(name: 'Share Receiver'),
      ),

      // ── Gated shell routes ───────────────────────────────────────────────
      GoRoute(
        path: Routes.home,
        builder: (context, state) => const _PlaceholderScreen(name: 'Home'),
      ),
      GoRoute(
        path: Routes.alarms,
        builder: (context, state) => const _PlaceholderScreen(name: 'Alarms'),
      ),
      GoRoute(
        path: Routes.workspaces,
        builder: (context, state) =>
            const _PlaceholderScreen(name: 'Workspaces'),
      ),
      GoRoute(
        path: Routes.workspaceDetail,
        builder: (context, state) => _PlaceholderScreen(
          name: 'Workspace Detail: ${state.pathParameters['id']}',
        ),
      ),
      GoRoute(
        path: Routes.notes,
        builder: (context, state) => const _PlaceholderScreen(name: 'Notes'),
      ),
      GoRoute(
        path: Routes.settings,
        builder: (context, state) =>
            const _PlaceholderScreen(name: 'Settings'),
      ),
      GoRoute(
        path: Routes.taskDetail,
        builder: (context, state) => _PlaceholderScreen(
          name: 'Task Detail: ${state.pathParameters['id']}',
        ),
      ),
      GoRoute(
        path: Routes.briefing,
        builder: (context, state) =>
            const _PlaceholderScreen(name: 'Morning Briefing'),
      ),
      GoRoute(
        path: Routes.search,
        builder: (context, state) =>
            const _PlaceholderScreen(name: 'Search'),
      ),
      GoRoute(
        path: Routes.reminders,
        builder: (context, state) =>
            const _PlaceholderScreen(name: 'Reminders'),
      ),
    ],
  );
}

// ── Placeholder screens (replaced during Phase 7) ────────────────────────────

class _PlaceholderScreen extends StatelessWidget {
  final String name;
  const _PlaceholderScreen({required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D11),
      body: Center(
        child: Text(
          name,
          style: const TextStyle(color: Colors.white70, fontSize: 18),
        ),
      ),
    );
  }
}
