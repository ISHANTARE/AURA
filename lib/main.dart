import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/colors.dart';
import 'core/providers/database_provider.dart';
import 'core/router/app_router.dart';
import 'database/app_database.dart';
import 'features/settings/settings_screen.dart' show themeAccentProvider, SettingsKeys;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final gateNotifier = OnboardingGateNotifier(prefs);
  final database = AppDatabase();

  final savedAccent = prefs.getString(SettingsKeys.themeAccent) ?? 'Indigo';

  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(database),
        onboardingGateProvider.overrideWithValue(gateNotifier),
      ],
      child: AuraApp(
        gateNotifier: gateNotifier,
        initialAccent: savedAccent,
      ),
    ),
  );
}

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

class _AuraAppState extends ConsumerState<AuraApp> {
  late final _router = buildAppRouter(widget.gateNotifier);

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
