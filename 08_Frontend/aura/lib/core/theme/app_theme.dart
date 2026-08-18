import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/colors.dart';
import '../constants/typography.dart';
import '../constants/spacing.dart';

/// AURA App Theme — Premium Dark Productivity
/// Rebuilt from neubrutalism to a calm, premium aesthetic.
///
/// Design principles:
///   - Soft rounded corners (16–20px on cards, 24px on bottom sheets)
///   - Subtle box shadows (blur: 12–24, spread: 0, low opacity)
///   - Inter font throughout
///   - Deep dark backgrounds with layered elevation
///   - Accent color propagates via colorScheme.primary (theme changer works)
abstract final class AppTheme {
  static ThemeData dark([Color accentColor = AuraColors.accentPrimary]) {
    final base = ThemeData.dark(useMaterial3: true);

    return base.copyWith(
      // ── Scaffold ─────────────────────────────────────────────────────────
      scaffoldBackgroundColor: AuraColors.bgBase,

      // ── Color scheme ─────────────────────────────────────────────────────
      colorScheme: ColorScheme.dark(
        surface: AuraColors.bgBase,
        onSurface: AuraColors.textPrimary,
        primary: accentColor,
        onPrimary: AuraColors.textOnAccent,
        secondary: AuraColors.accentBlue,
        onSecondary: AuraColors.textOnAccent,
        error: AuraColors.accentRed,
        onError: AuraColors.textPrimary,
        outline: AuraColors.border,
        surfaceContainerHighest: AuraColors.bgElevated,
        surfaceContainerHigh: AuraColors.bgCard,
        surfaceContainer: AuraColors.bgCard,
      ),

      // ── App bar ───────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: AuraColors.bgBase,
        foregroundColor: AuraColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: AuraColors.bgBase,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: AuraTypography.sectionHeader,
        iconTheme: const IconThemeData(
          color: AuraColors.textPrimary,
          size: AuraIcons.sizeNavBar,
        ),
      ),

      // ── Navigation bar (Material 3) ───────────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AuraColors.bgCard,
        indicatorColor: accentColor.withValues(alpha: 0.18),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: accentColor, size: 22);
          }
          return const IconThemeData(color: AuraColors.textMuted, size: 22);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AuraTypography.label.copyWith(color: accentColor);
          }
          return AuraTypography.label;
        }),
        elevation: 0,
        height: AuraSpacing.bottomNavHeight,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
      ),

      // ── Legacy bottom nav bar (fallback) ─────────────────────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AuraColors.bgCard,
        selectedItemColor: accentColor,
        unselectedItemColor: AuraColors.textMuted,
        selectedLabelStyle: const TextStyle(fontSize: 0), // icon-only
        unselectedLabelStyle: const TextStyle(fontSize: 0),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // ── Text theme ────────────────────────────────────────────────────────
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        displayLarge:  AuraTypography.display,
        headlineMedium: AuraTypography.headline,
        titleLarge:    AuraTypography.sectionHeader,
        titleMedium:   AuraTypography.cardTitle,
        bodyLarge:     AuraTypography.bodyPrimary,
        bodyMedium:    AuraTypography.body,
        bodySmall:     AuraTypography.bodySmall,
        labelSmall:    AuraTypography.label,
        labelMedium:   AuraTypography.overline,
      ),

      // ── Divider ───────────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AuraColors.borderMuted,
        thickness: 1,
        space: 0,
      ),

      // ── Card ──────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: AuraColors.bgCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AuraColors.border, width: 1),
        ),
        shadowColor: Colors.black.withValues(alpha: 0.3),
      ),

      // ── Elevated button (primary CTA) ─────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: AuraColors.textOnAccent,
          elevation: 0,
          textStyle: AuraTypography.buttonPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AuraSpacing.lg,
            vertical: AuraSpacing.md,
          ),
          minimumSize: const Size(0, 52),
        ),
      ),

      // ── Outlined button (secondary CTA) ───────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AuraColors.textPrimary,
          elevation: 0,
          textStyle: AuraTypography.buttonSecondary,
          side: const BorderSide(color: AuraColors.border, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AuraSpacing.lg,
            vertical: AuraSpacing.md,
          ),
          minimumSize: const Size(0, 52),
        ),
      ),

      // ── Text button ───────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentColor,
          textStyle: AuraTypography.buttonSecondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      // ── FAB ───────────────────────────────────────────────────────────────
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accentColor,
        foregroundColor: AuraColors.textOnAccent,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // ── Input / TextField ─────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AuraColors.bgElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AuraColors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AuraColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accentColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AuraColors.accentRed, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AuraColors.accentRed, width: 1.5),
        ),
        hintStyle: AuraTypography.body,
        labelStyle: AuraTypography.overline,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AuraSpacing.md,
          vertical: AuraSpacing.md,
        ),
      ),

      // ── Chip ──────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AuraColors.bgElevated,
        selectedColor: accentColor.withValues(alpha: 0.2),
        side: const BorderSide(color: AuraColors.border, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        labelStyle: AuraTypography.label,
        padding: const EdgeInsets.symmetric(horizontal: AuraSpacing.sm),
      ),

      // ── Bottom sheet ──────────────────────────────────────────────────────
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AuraColors.bgElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        elevation: 0,
        modalBarrierColor: Color(0x80000000), // rgba(0,0,0,0.5) scrim
        dragHandleColor: AuraColors.border,
        showDragHandle: true,
      ),

      // ── Dialog ────────────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: AuraColors.bgElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        titleTextStyle: AuraTypography.sectionHeader,
        contentTextStyle: AuraTypography.body,
      ),

      // ── Icon ──────────────────────────────────────────────────────────────
      iconTheme: const IconThemeData(
        color: AuraColors.textPrimary,
        size: AuraIcons.sizeStandard,
      ),

      // ── Snackbar ──────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AuraColors.bgElevated,
        contentTextStyle: AuraTypography.body.copyWith(
          color: AuraColors.textPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 4,
      ),

      // ── Progress indicator ────────────────────────────────────────────────
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: accentColor,
        linearTrackColor: AuraColors.bgElevated,
        circularTrackColor: AuraColors.bgElevated,
      ),

      // ── Checkbox ──────────────────────────────────────────────────────────
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return accentColor;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AuraColors.textOnAccent),
        side: const BorderSide(color: AuraColors.border, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      // ── Switch ────────────────────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AuraColors.textOnAccent;
          return AuraColors.textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return accentColor;
          return AuraColors.bgHover;
        }),
      ),

      // ── List tile ─────────────────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        tileColor: Colors.transparent,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AuraSpacing.lg,
          vertical: AuraSpacing.xs,
        ),
        titleTextStyle: AuraTypography.cardTitle,
        subtitleTextStyle: AuraTypography.body,
        iconColor: AuraColors.textSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

// Keep AuraIcons accessible here too (needed in appBarTheme above)
// ignore: avoid_classes_with_only_static_members
abstract class AuraIcons {
  static const double sizeNavBar = 24.0;
  static const double sizeStandard = 20.0;
}
