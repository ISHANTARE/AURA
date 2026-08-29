import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aura/core/constants/colors.dart';
import 'package:aura/core/constants/spacing.dart';
import 'package:aura/core/constants/typography.dart';
import 'package:aura/core/theme/theme_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuraColors Token Verification', () {
    test('Background layers match OLED dark theme specification', () {
      expect(AuraColors.bgBase, const Color(0xFF0D0D11));
      expect(AuraColors.bgCard, const Color(0xFF16161E));
      expect(AuraColors.bgElevated, const Color(0xFF1F1F2C));
      expect(AuraColors.bgSubtle, const Color(0xFF252534));
    });

    test('Borders match specifications', () {
      expect(AuraColors.border, const Color(0xFF2A2A3C));
      expect(AuraColors.borderMuted, const Color(0xFF1E1E2C));
    });

    test('Typography tokens match hierarchy', () {
      expect(AuraColors.textPrimary, const Color(0xFFE8E8F0));
      expect(AuraColors.textSecondary, const Color(0xFF9898B0));
      expect(AuraColors.textMuted, const Color(0xFF585870));
      expect(AuraColors.textInverse, const Color(0xFF0D0D11));
    });

    test('All 6 accent variants match exact hex codes', () {
      expect(AuraColors.accentIndigo, const Color(0xFF7B6FF0));
      expect(AuraColors.accentCyan, const Color(0xFF22D3EE));
      expect(AuraColors.accentPurple, const Color(0xFFC084FC));
      expect(AuraColors.accentOrange, const Color(0xFFFF9966));
      expect(AuraColors.accentRose, const Color(0xFFF472B6));
      expect(AuraColors.accentLime, const Color(0xFFC8FF00));
    });

    test('Priority colors map correctly', () {
      expect(AuraColors.priorityHigh, const Color(0xFFFF6B6B));
      expect(AuraColors.priorityMedium, const Color(0xFFFBBF24));
      expect(AuraColors.priorityLow, const Color(0xFF34D399));
    });

    test('Semantic status colors match specifications', () {
      expect(AuraColors.accentGreen, const Color(0xFF34D399));
      expect(AuraColors.accentAmber, const Color(0xFFFBBF24));
      expect(AuraColors.accentRed, const Color(0xFFF87171));
    });
  });

  group('AuraSpacing & AuraRadius Verification', () {
    test('AuraSpacing follows 8-point base scale', () {
      expect(AuraSpacing.xs, 4.0);
      expect(AuraSpacing.sm, 8.0);
      expect(AuraSpacing.md, 16.0);
      expect(AuraSpacing.lg, 24.0);
      expect(AuraSpacing.xl, 32.0);
      expect(AuraSpacing.xxl, 48.0);
    });

    test('AuraRadius scale matches specification', () {
      expect(AuraRadius.xs, 4.0);
      expect(AuraRadius.sm, 8.0);
      expect(AuraRadius.md, 12.0);
      expect(AuraRadius.lg, 16.0);
      expect(AuraRadius.xl, 24.0);
      expect(AuraRadius.full, 999.0);
    });
  });

  group('AuraTypography Scale Verification', () {
    test('Typography font sizes match design specifications', () {
      expect(AuraTypography.display.fontSize, 36);
      expect(AuraTypography.displayMedium.fontSize, 28);
      expect(AuraTypography.sectionHeader.fontSize, 22);
      expect(AuraTypography.cardTitle.fontSize, 16);
      expect(AuraTypography.body.fontSize, 14);
      expect(AuraTypography.bodySmall.fontSize, 13);
      expect(AuraTypography.label.fontSize, 12);
      expect(AuraTypography.caption.fontSize, 11);
      expect(AuraTypography.mono.fontSize, 13);
      expect(AuraTypography.orbLabel.fontSize, 18);
    });
  });

  group('ThemeAccent & Notifiers Verification', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('ThemeAccent enum maps to correct colors and names', () {
      expect(ThemeAccent.values.length, 6);
      expect(ThemeAccent.indigo.primaryColor, AuraColors.accentIndigo);
      expect(ThemeAccent.cyan.primaryColor, AuraColors.accentCyan);
      expect(ThemeAccent.purple.primaryColor, AuraColors.accentPurple);
      expect(ThemeAccent.orange.primaryColor, AuraColors.accentOrange);
      expect(ThemeAccent.rose.primaryColor, AuraColors.accentRose);
      expect(ThemeAccent.lime.primaryColor, AuraColors.accentLime);

      expect(ThemeAccent.fromString('orange'), ThemeAccent.orange);
      expect(ThemeAccent.fromString('UNKNOWN'), ThemeAccent.indigo);
      expect(ThemeAccent.fromString(null), ThemeAccent.indigo);
    });

    test('ThemeModeNotifier defaults to dark and toggles correctly', () async {
      final notifier = ThemeModeNotifier();
      expect(notifier.state, ThemeMode.dark);

      await notifier.setThemeMode(ThemeMode.light);
      expect(notifier.state, ThemeMode.light);

      await notifier.toggleTheme();
      expect(notifier.state, ThemeMode.dark);
    });

    test('ThemeAccentNotifier defaults to indigo and updates correctly', () async {
      final notifier = ThemeAccentNotifier();
      expect(notifier.state, ThemeAccent.indigo);

      await notifier.setAccent(ThemeAccent.cyan);
      expect(notifier.state, ThemeAccent.cyan);
    });

    test('AuraTheme builds valid Dark and Light ThemeData', () {
      final darkTheme = AuraTheme.buildDarkTheme(ThemeAccent.indigo);
      expect(darkTheme.scaffoldBackgroundColor, AuraColors.bgBase);
      expect(darkTheme.colorScheme.primary, AuraColors.accentIndigo);
      expect(darkTheme.brightness, Brightness.dark);

      final lightTheme = AuraTheme.buildLightTheme(ThemeAccent.rose);
      expect(lightTheme.scaffoldBackgroundColor, AuraColors.lightBgBase);
      expect(lightTheme.colorScheme.primary, AuraColors.accentRose);
      expect(lightTheme.brightness, Brightness.light);
    });
  });
}
