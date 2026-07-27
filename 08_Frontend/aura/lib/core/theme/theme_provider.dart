import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeAccent {
  neonLime('Neon Lime', Color(0xFFC8FF00)),
  cyberCyan('Cyber Cyan', Color(0xFF00E5FF)),
  electricPurple('Electric Purple', Color(0xFFB57BFF)),
  sunsetOrange('Sunset Orange', Color(0xFFFF6B00));

  final String label;
  final Color color;
  const ThemeAccent(this.label, this.color);
}

class ThemeAccentNotifier extends StateNotifier<ThemeAccent> {
  ThemeAccentNotifier() : super(ThemeAccent.neonLime) {
    _loadAccent();
  }

  Future<void> _loadAccent() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('THEME_ACCENT') ?? 'Neon Lime';
    state = ThemeAccent.values.firstWhere(
      (a) => a.label == name,
      orElse: () => ThemeAccent.neonLime,
    );
  }

  Future<void> setAccent(ThemeAccent accent) async {
    state = accent;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('THEME_ACCENT', accent.label);
  }
}

final themeAccentProvider =
    StateNotifierProvider<ThemeAccentNotifier, ThemeAccent>((ref) {
  return ThemeAccentNotifier();
});
