import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeAccent {
  indigoPrimary('Indigo', Color(0xFF7B6FF0)),
  cyberCyan('Cyber Cyan', Color(0xFF22D3EE)),
  electricPurple('Electric Purple', Color(0xFFC084FC)),
  sunsetOrange('Sunset Orange', Color(0xFFFF9966)),
  roseGold('Rose Gold', Color(0xFFF472B6));

  final String label;
  final Color color;
  const ThemeAccent(this.label, this.color);
}

class ThemeAccentNotifier extends StateNotifier<ThemeAccent> {
  ThemeAccentNotifier() : super(ThemeAccent.indigoPrimary) {
    _loadAccent();
  }

  Future<void> _loadAccent() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('THEME_ACCENT') ?? ThemeAccent.indigoPrimary.label;
    state = ThemeAccent.values.firstWhere(
      (a) => a.label == name,
      orElse: () => ThemeAccent.indigoPrimary,
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