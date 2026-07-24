import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// AURA Typography System
/// Font: Space Grotesk (Google Fonts)
/// Source: 03_UX/design_system.md — Typography section
abstract final class AuraTypography {
  // ── Font family ───────────────────────────────────────────────────────────
  static const String fontFamily = 'SpaceGrotesk';

  // ── Base TextStyle factory ────────────────────────────────────────────────
  static TextStyle _base({
    required double size,
    required FontWeight weight,
    Color color = const Color(0xFFFFFFFF),
    double? letterSpacing,
    TextDecoration? decoration,
  }) =>
      GoogleFonts.spaceGrotesk(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing,
        decoration: decoration,
      );

  // ── Display / Hero ────────────────────────────────────────────────────────
  /// Large stats, orb label. 36sp ExtraBold.
  static TextStyle get display => _base(size: 36, weight: FontWeight.w800);

  // ── Section Headers ───────────────────────────────────────────────────────
  /// Screen titles, section names. 22sp Bold.
  static TextStyle get sectionHeader => _base(size: 22, weight: FontWeight.w700);

  // ── Card Titles ───────────────────────────────────────────────────────────
  /// Task names, event titles. 17sp SemiBold.
  static TextStyle get cardTitle => _base(size: 17, weight: FontWeight.w600);

  // ── Body ──────────────────────────────────────────────────────────────────
  /// Deadlines, descriptions. 14sp Regular.
  static TextStyle get body => _base(
        size: 14,
        weight: FontWeight.w400,
        color: const Color(0x99FFFFFF),
      );

  /// Body at full white opacity (for primary content in detail screens).
  static TextStyle get bodyPrimary => _base(size: 14, weight: FontWeight.w400);

  // ── Labels / Tags ─────────────────────────────────────────────────────────
  /// Category labels, badges. 11sp Medium, ALL CAPS, letter-spacing 1.2.
  static TextStyle get label => _base(
        size: 11,
        weight: FontWeight.w500,
        color: const Color(0x99FFFFFF),
        letterSpacing: 1.2,
      );

  /// Label variant in lime (active section headers, focus cell numbers).
  static TextStyle get labelLime => _base(
        size: 11,
        weight: FontWeight.w500,
        color: const Color(0xFFC8FF00),
        letterSpacing: 1.2,
      );

  // ── Overline (smaller labels) ─────────────────────────────────────────────
  /// Breadcrumbs, contextual hints. 12sp Regular.
  static TextStyle get overline => _base(
        size: 12,
        weight: FontWeight.w400,
        color: const Color(0x99FFFFFF),
        letterSpacing: 0.8,
      );

  // ── Button labels ─────────────────────────────────────────────────────────
  /// Primary CTA (lime button). 16sp Bold black.
  static TextStyle get buttonPrimary => _base(
        size: 16,
        weight: FontWeight.w700,
        color: const Color(0xFF000000),
      );

  /// Secondary CTA. 15sp SemiBold white.
  static TextStyle get buttonSecondary => _base(size: 15, weight: FontWeight.w600);

  // ── Orb label ─────────────────────────────────────────────────────────────
  /// The "A" on the orb. 24sp ExtraBold black.
  static TextStyle get orbLabel => _base(
        size: 24,
        weight: FontWeight.w800,
        color: const Color(0xFF000000),
      );
}
