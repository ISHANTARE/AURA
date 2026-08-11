import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/colors.dart';
import '../constants/typography.dart';
import '../constants/spacing.dart';

/// AURA App Theme — Pure Dark Neubrutalism
/// Source: 03_UX/design_system.md
///
/// Rules baked in:
///   - No border radius on any widget (0px everywhere)
///   - Hard box shadows (blurRadius: 0) on interactive elements
///   - Space Grotesk everywhere
///   - Only two themes: dark (default) and light (minimal variation)
abstract final class AppTheme {
  static ThemeData dark([Color accentColor = AuraColors.accentLime]) {
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

      // ── Bottom navigation ─────────────────────────────────────────────────
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AuraColors.bgBase,
        selectedItemColor: AuraColors.accentLime,
        unselectedItemColor: AuraColors.textSecondary,
        selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
        unselectedLabelStyle: TextStyle(fontSize: 11),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // ── Text theme ────────────────────────────────────────────────────────
      textTheme: GoogleFonts.spaceGroteskTextTheme(base.textTheme).copyWith(
        displayLarge:  AuraTypography.display,
        titleLarge:    AuraTypography.sectionHeader,
        titleMedium:   AuraTypography.cardTitle,
        bodyLarge:     AuraTypography.bodyPrimary,
        bodyMedium:    AuraTypography.body,
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
      // Note: We use custom BentoCard widget — this is for MaterialCard fallbacks
      cardTheme: const CardThemeData(
        color: AuraColors.bgCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero, // CRITICAL: 0 radius
          side: BorderSide(color: AuraColors.border, width: AuraSpacing.borderWidth),
        ),
      ),

      // ── Elevated button (primary CTA — lime) ──────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AuraColors.accentLime,
          foregroundColor: AuraColors.textOnAccent,
          elevation: 0,
          textStyle: AuraTypography.buttonPrimary,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: BorderSide(color: Colors.black, width: AuraSpacing.borderWidth),
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
          side: const BorderSide(color: AuraColors.border, width: AuraSpacing.borderWidth),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AuraSpacing.lg,
            vertical: AuraSpacing.md,
          ),
          minimumSize: const Size(0, 52),
        ),
      ),

      // ── Input / TextField ─────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AuraColors.bgElevated,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: AuraColors.border, width: AuraSpacing.borderWidth),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: AuraColors.border, width: AuraSpacing.borderWidth),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: AuraColors.accentLime, width: AuraSpacing.borderWidth),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: AuraColors.accentRed, width: AuraSpacing.borderWidth),
        ),
        hintStyle: AuraTypography.body,
        labelStyle: AuraTypography.overline,
        contentPadding: const EdgeInsets.all(AuraSpacing.md),
      ),

      // ── Chip ──────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AuraColors.bgCard,
        selectedColor: AuraColors.accentLime,
        side: const BorderSide(color: AuraColors.border, width: 1.5),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        labelStyle: AuraTypography.label,
        padding: const EdgeInsets.symmetric(horizontal: AuraSpacing.sm),
      ),

      // ── Bottom sheet ──────────────────────────────────────────────────────
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AuraColors.bgElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: AuraColors.border, width: AuraSpacing.borderWidth),
        ),
        elevation: 0,
        modalBarrierColor: Color(0x66000000), // rgba(0,0,0,0.4) scrim
      ),

      // ── Dialog ───────────────────────────────────────────────────────────
      dialogTheme: const DialogThemeData(
        backgroundColor: AuraColors.bgElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: AuraColors.border, width: AuraSpacing.borderWidth),
        ),
        elevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: 'SpaceGrotesk',
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AuraColors.textPrimary,
        ),
      ),

      // ── Icon ──────────────────────────────────────────────────────────────
      iconTheme: const IconThemeData(
        color: AuraColors.textPrimary,
        size: AuraIcons.sizeStandard,
      ),

      // ── Snackbar ──────────────────────────────────────────────────────────
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AuraColors.bgElevated,
        contentTextStyle: TextStyle(
          fontFamily: 'SpaceGrotesk',
          color: AuraColors.textPrimary,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: AuraColors.border, width: AuraSpacing.borderWidth),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // ── Progress indicator ────────────────────────────────────────────────
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AuraColors.accentLime,
        linearTrackColor: AuraColors.bgCard,
      ),

      // ── Checkbox ──────────────────────────────────────────────────────────
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AuraColors.accentLime;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AuraColors.textOnAccent),
        side: const BorderSide(color: AuraColors.border, width: AuraSpacing.borderWidth),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
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
