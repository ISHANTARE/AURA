import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/colors.dart';
import 'core/providers/service_providers.dart';
import 'core/router/app_router.dart';
import 'features/settings/settings_screen.dart' show themeAccentProvider;
import 'platform/overlay_channel.dart';

/// Central Flutter Application widget managing lifecycle hooks, background sync,
/// deep-link notification routing, and overlay orb integration.
/// Reference: overhaul-docs/09-startup-sequence.md Section 3 & 4
class AuraApp extends ConsumerStatefulWidget {
  final OnboardingGateNotifier gateNotifier;
  final String initialAccent;

  const AuraApp({
    super.key,
    required this.gateNotifier,
    required this.initialAccent,
  });

  @override
  ConsumerState<AuraApp> createState() => _AuraAppState();
}

class _AuraAppState extends ConsumerState<AuraApp> with WidgetsBindingObserver {
  late final _router = buildAppRouter(widget.gateNotifier);
  final _overlay = OverlayChannel();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // 1. Listen to Orb Tap events dispatched from native AuraOverlayService
    _overlay.listenToOrbTaps(() {
      _router.push(Routes.captureOverlay);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 2. Eagerly start DND monitor service
      ref.read(dndServiceProvider);

      // 3. Start offline queue processor and drain pending items
      ref.read(offlineQueueProcessorProvider).drainQueue();

      // 4. Auto-start floating orb if permitted
      _autoStartOrbIfPermitted();

      // 5. Initial health & background synchronization chain
      _onAppActive();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _onAppActive();
    }
  }

  Future<void> _onAppActive() async {
    final lifecycleService = ref.read(lifecycleSyncServiceProvider);
    await lifecycleService.onAppActive();
  }

  Future<void> _autoStartOrbIfPermitted() async {
    final permitted = await _overlay.checkOverlayPermission();
    if (permitted) {
      await _overlay.startOverlay();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Color _accentColor(String name) {
    return switch (name) {
      'Cyan' => const Color(0xFF22D3EE),
      'Purple' => const Color(0xFFC084FC),
      'Orange' => const Color(0xFFFF9966),
      'Rose' => const Color(0xFFF472B6),
      'Lime' => const Color(0xFFC8FF00),
      _ => const Color(0xFF7B6FF0), // Neon Indigo default
    };
  }

  @override
  Widget build(BuildContext context) {
    final activeAccent = ref.watch(themeAccentProvider);
    final accentColor = _accentColor(activeAccent);

    return MaterialApp.router(
      title: 'AURA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: AuraColors.bgBase,
        colorScheme: ColorScheme.dark(
          primary: accentColor,
          surface: AuraColors.bgCard,
        ),
      ),
      routerConfig: _router,
    );
  }
}
