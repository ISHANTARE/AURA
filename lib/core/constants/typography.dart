import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';

/// AURA Typography System — Inter
/// Migrated from Space Grotesk to Inter for a cleaner, modern productivity feel.
/// Type scale: Display → Headline → Title → Body → Caption → Label
abstract final class AuraTypography {
  // ── Font family ───────────────────────────────────────────────────────────
  static const String fontFamily = 'Inter';

  // ── Base TextStyle factory ────────────────────────────────────────────────
  static TextStyle _base({
    required double size,
    required FontWeight weight,
    Color? color,
    double? letterSpacing,
    double? height,
    TextDecoration? decoration,
  }) =>
      GoogleFonts.inter(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
        decoration: decoration,
      );

  // ── Display / Hero ────────────────────────────────────────────────────────
  /// Large stats, welcome screens, orb label. 40sp ExtraBold.
  static TextStyle get display => _base(
        size: 40,
        weight: FontWeight.w800,
        height: 1.1,
      );

  // ── Headline ──────────────────────────────────────────────────────────────
  /// Screen titles, onboarding headings. 28sp Bold.
  static TextStyle get headline => _base(
        size: 28,
        weight: FontWeight.w700,
        height: 1.2,
      );

  // ── Screen / Section Headers ──────────────────────────────────────────────
  /// App bar titles, section names. 20sp SemiBold.
  static TextStyle get sectionHeader => _base(
        size: 20,
        weight: FontWeight.w600,
        height: 1.3,
      );

  /// Alias for sectionHeader — used in screen app bars.
  static TextStyle get screenHeader => sectionHeader;

  // ── Title ─────────────────────────────────────────────────────────────────
  /// Card titles, list item primaries. 16sp SemiBold.
  static TextStyle get cardTitle => _base(
        size: 16,
        weight: FontWeight.w600,
        height: 1.4,
      );

  // ── Body ──────────────────────────────────────────────────────────────────
  /// Primary body content. 15sp Regular.
  static TextStyle get bodyPrimary => _base(
        size: 15,
        weight: FontWeight.w400,
        height: 1.5,
      );

  /// Standard body — 14sp Regular.
  static TextStyle get body => _base(
        size: 14,
        weight: FontWeight.w400,
        height: 1.5,
      );

  /// Body medium — 15sp Regular.
  static TextStyle get bodyMedium => bodyPrimary;

  /// Body small — 13sp Regular.
  static TextStyle get bodySmall => _base(
        size: 13,
        weight: FontWeight.w400,
        height: 1.5,
      );

  // ── Caption ───────────────────────────────────────────────────────────────
  /// Timestamps, meta info, breadcrumbs. 12sp Regular.
  static TextStyle get caption => _base(
        size: 12,
        weight: FontWeight.w400,
        height: 1.4,
      );

  // ── Labels / Tags / Overline ──────────────────────────────────────────────
  /// Category labels, badges. 11sp Medium, letter-spacing 0.8.
  static TextStyle get label => _base(
        size: 11,
        weight: FontWeight.w500,
        letterSpacing: 0.8,
      );

  /// Overline — section markers, ALL CAPS hints. 11sp Medium.
  static TextStyle get overline => _base(
        size: 11,
        weight: FontWeight.w500,
        letterSpacing: 1.2,
      );

  /// Badge / chip text. 11sp SemiBold.
  static TextStyle get badgeText => _base(
        size: 11,
        weight: FontWeight.w600,
        letterSpacing: 0.5,
      );

  // ── Stat / Metric Values ──────────────────────────────────────────────────
  /// Large stat numbers in dashboard cards. 32sp ExtraBold.
  static TextStyle get bentoMetricValue => _base(
        size: 32,
        weight: FontWeight.w800,
        height: 1.1,
      );

  /// Stat metric labels beneath numbers. 11sp Bold.
  static TextStyle get bentoMetricLabel => _base(
        size: 11,
        weight: FontWeight.w700,
        letterSpacing: 0.8,
      );

  // ── Button labels ─────────────────────────────────────────────────────────
  /// Primary CTA button label. 15sp Bold white.
  static TextStyle get buttonPrimary => _base(
        size: 15,
        weight: FontWeight.w700,
      );

  /// Alias for buttonPrimary.
  static TextStyle get buttonText => buttonPrimary;

  /// Secondary CTA. 15sp SemiBold.
  static TextStyle get buttonSecondary => _base(
        size: 15,
        weight: FontWeight.w600,
        color: AuraColors.textSecondary,
      );

  // ── Orb label ─────────────────────────────────────────────────────────────
  /// The "A" on the orb. 22sp ExtraBold white.
  static TextStyle get orbLabel => _base(
        size: 22,
        weight: FontWeight.w800,
      );

  // ── Legacy alias ──────────────────────────────────────────────────────────
  /// @deprecated Use [label] instead.
  static TextStyle get labelLime => _base(
        size: 11,
        weight: FontWeight.w500,
        color: AuraColors.accentPrimary,
        letterSpacing: 0.8,
      );
}
