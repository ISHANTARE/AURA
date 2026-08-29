import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/colors.dart';
import '../constants/spacing.dart';

/// 6 Selectable Accent Variants for AURA.
/// Reference: overhaul-docs/08-design-system.md
enum ThemeAccent {
  indigo,
  cyan,
  purple,
  orange,
  rose,
  lime;

  String get displayName => switch (this) {
        ThemeAccent.indigo => 'Neon Indigo',
        ThemeAccent.cyan => 'Cyber Cyan',
        ThemeAccent.purple => 'Electric Purple',
        ThemeAccent.orange => 'Sunset Orange',
        ThemeAccent.rose => 'Rose Gold',
        ThemeAccent.lime => 'Acid Lime',
      };

  Color get primaryColor => switch (this) {
        ThemeAccent.indigo => AuraColors.accentIndigo,
        ThemeAccent.cyan => AuraColors.accentCyan,
        ThemeAccent.purple => AuraColors.accentPurple,
        ThemeAccent.orange => AuraColors.accentOrange,
        ThemeAccent.rose => AuraColors.accentRose,
        ThemeAccent.lime => AuraColors.accentLime,
      };

  static ThemeAccent fromString(String? value) {
    if (value == null) return ThemeAccent.indigo;
    return ThemeAccent.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => ThemeAccent.indigo,
    );
  }
}

/// State notifier managing user selected ThemeAccent persisted in SharedPreferences.
class ThemeAccentNotifier extends StateNotifier<ThemeAccent> {
  static const String prefKey = 'THEME_ACCENT';

  ThemeAccentNotifier([SharedPreferences? prefs]) : super(ThemeAccent.indigo) {
    _init(prefs);
  }

  Future<void> _init(SharedPreferences? prefs) async {
    final sp = prefs ?? await SharedPreferences.getInstance();
    final saved = sp.getString(prefKey);
    if (saved != null) {
      state = ThemeAccent.fromString(saved);
    }
  }

  Future<void> setAccent(ThemeAccent accent) async {
    state = accent;
    final sp = await SharedPreferences.getInstance();
    await sp.setString(prefKey, accent.name);
  }
}

/// State notifier managing ThemeMode (Dark default vs Light), persisted in SharedPreferences.
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  static const String prefKey = 'THEME_MODE';

  ThemeModeNotifier([SharedPreferences? prefs]) : super(ThemeMode.dark) {
    _init(prefs);
  }

  Future<void> _init(SharedPreferences? prefs) async {
    final sp = prefs ?? await SharedPreferences.getInstance();
    final saved = sp.getString(prefKey);
    if (saved != null) {
      if (saved == 'light') {
        state = ThemeMode.light;
      } else {
        state = ThemeMode.dark;
      }
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final sp = await SharedPreferences.getInstance();
    await sp.setString(prefKey, mode == ThemeMode.light ? 'light' : 'dark');
  }

  Future<void> toggleTheme() async {
    final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(next);
  }
}

/// Builder creating customized ThemeData for Dark (OLED) and Light modes.
abstract final class AuraTheme {
  static ThemeData buildDarkTheme(ThemeAccent accent) {
    final primary = accent.primaryColor;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AuraColors.bgBase,
      canvasColor: AuraColors.bgBase,
      cardColor: AuraColors.bgCard,
      colorScheme: ColorScheme.dark(
        primary: primary,
        secondary: primary,
        surface: AuraColors.bgCard,
        surfaceContainerHighest: AuraColors.bgElevated,
        surfaceContainerLow: AuraColors.bgSubtle,
        error: AuraColors.accentRed,
        onPrimary: AuraColors.textInverse,
        onSurface: AuraColors.textPrimary,
        outline: AuraColors.border,
        outlineVariant: AuraColors.borderMuted,
      ),
      textTheme: ThemeData.dark().textTheme.apply(
        fontFamily: 'Inter',
        bodyColor: AuraColors.textPrimary,
        displayColor: AuraColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AuraColors.bgBase,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          color: AuraColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: AuraColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: AuraColors.bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AuraRadius.lg),
          side: const BorderSide(color: AuraColors.border, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AuraColors.borderMuted,
        thickness: 1,
        space: 1,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AuraColors.bgBase,
        selectedItemColor: AuraColors.textPrimary,
        unselectedItemColor: AuraColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }

  static ThemeData buildLightTheme(ThemeAccent accent) {
    final primary = accent.primaryColor;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AuraColors.lightBgBase,
      canvasColor: AuraColors.lightBgBase,
      cardColor: AuraColors.lightBgCard,
      colorScheme: ColorScheme.light(
        primary: primary,
        secondary: primary,
        surface: AuraColors.lightBgCard,
        surfaceContainerHighest: AuraColors.lightBgElevated,
        error: AuraColors.accentRed,
        onPrimary: Colors.white,
        onSurface: AuraColors.lightTextPrimary,
        outline: AuraColors.lightBorder,
      ),
      textTheme: ThemeData.light().textTheme.apply(
        fontFamily: 'Inter',
        bodyColor: AuraColors.lightTextPrimary,
        displayColor: AuraColors.lightTextPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AuraColors.lightBgBase,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          color: AuraColors.lightTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: AuraColors.lightTextPrimary),
      ),
      cardTheme: CardThemeData(
        color: AuraColors.lightBgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AuraRadius.lg),
          side: const BorderSide(color: AuraColors.lightBorder, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AuraColors.lightBorder,
        thickness: 1,
        space: 1,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AuraColors.lightBgBase,
        selectedItemColor: AuraColors.lightTextPrimary,
        unselectedItemColor: AuraColors.lightTextMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}

// ── Global Riverpod Providers ───────────────────────────────────────────────
final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

final themeAccentProvider =
    StateNotifierProvider<ThemeAccentNotifier, ThemeAccent>((ref) {
  return ThemeAccentNotifier();
});

final darkThemeProvider = Provider<ThemeData>((ref) {
  final accent = ref.watch(themeAccentProvider);
  return AuraTheme.buildDarkTheme(accent);
});

final lightThemeProvider = Provider<ThemeData>((ref) {
  final accent = ref.watch(themeAccentProvider);
  return AuraTheme.buildLightTheme(accent);
});
