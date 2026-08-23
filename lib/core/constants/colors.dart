import 'package:flutter/material.dart';

/// AURA Color System — Premium Dark Productivity
/// Rebuilt from neubrutalist lime to a calm, premium dark + indigo/violet palette.
/// Every color in the app must come from this class. No hardcoded hex values elsewhere.
abstract final class AuraColors {
  // ── Base Backgrounds ─────────────────────────────────────────────────────
  /// Main app background — deepest layer
  static const Color bgBase     = Color(0xFF0D0F14);
  /// Card / cell background — second layer
  static const Color bgCard     = Color(0xFF13151C);
  /// Modals, bottom sheets, overlays — elevated layer
  static const Color bgElevated = Color(0xFF1C1F2B);
  /// Hover / pressed state surface
  static const Color bgHover    = Color(0xFF222536);

  // ── Border / Divider ─────────────────────────────────────────────────────
  /// Subtle card outline — low opacity
  static const Color border      = Color(0xFF2A2D3E);
  /// Ultra-subtle divider lines
  static const Color borderMuted = Color(0x1AFFFFFF); // rgba(255,255,255,0.10)
  /// Soft drop shadow color — used in BoxShadow across cards and overlays
  static const Color shadow      = Color(0x40000000); // rgba(0,0,0,0.25)

  // ── Accent Palette ────────────────────────────────────────────────────────
  /// Primary CTA, active states, orb, AURA brand — indigo/violet
  static const Color accentPrimary = Color(0xFF7B6FF0);
  /// Softer glow variant of primary (for shadow/glow uses)
  static const Color accentPrimaryMuted = Color(0x337B6FF0); // 20% opacity

  /// Events, calendar items — soft teal
  static const Color accentBlue   = Color(0xFF4FC3F7);
  /// Warnings, medium priority — amber
  static const Color accentOrange = Color(0xFFFF9966);
  /// Overdue, high priority, urgent — soft red
  static const Color accentRed    = Color(0xFFFF5C72);
  /// Success, completed tasks — soft green
  static const Color accentGreen  = Color(0xFF4ADE80);
  /// Recurring tasks, habits — lavender
  static const Color accentPurple = Color(0xFFC084FC);

  // ── Text ──────────────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFFF0F0F5);
  static const Color textSecondary = Color(0xFF8A8EA8);
  static const Color textMuted     = Color(0xFF4A4E6A);
  static const Color textDisabled  = Color(0x4DF0F0F5); // 30% opacity

  /// Text on accent-colored backgrounds
  static const Color textOnAccent  = Color(0xFFFFFFFF);

  // ── Semantic shortcuts ────────────────────────────────────────────────────
  static const Color priorityHigh   = accentRed;
  static const Color priorityMedium = accentOrange;
  static const Color priorityLow    = textMuted;

  static const Color deadlineSafe     = accentGreen;
  static const Color deadlineWarning  = accentOrange;
  static const Color deadlineCritical = accentRed;

  // ── Orb ───────────────────────────────────────────────────────────────────
  /// Orb glow — soft indigo atmospheric glow
  static const Color orbGlow     = Color(0x287B6FF0); // rgba(123,111,240,0.16)
  static const Color orbGlowMini = Color(0x1A7B6FF0); // rgba(123,111,240,0.10)

  // ── Gradient stops ────────────────────────────────────────────────────────
  /// Used in orb, onboarding hero, and capture overlay background gradient
  static const Color gradientStart = Color(0xFF1A1730);
  static const Color gradientEnd   = Color(0xFF0D0F14);

  // ── Legacy alias (kept for safe migration — points to new primary) ────────
  /// @deprecated Use [accentPrimary] instead.
  /// Keeping this so existing screens compile without changes during migration.
  static const Color accentLime = accentPrimary;
}

/// Parses a `#RRGGBB` (or `#AARRGGBB`) hex string, falling back to
/// [fallback] for malformed input. Single source of truth — four screens
/// previously duplicated this logic.
Color hexToColor(String hex, {Color fallback = AuraColors.accentPrimary}) {
  final cleaned = hex.trim().replaceFirst('#', '');
  if (cleaned.length == 6) {
    final value = int.tryParse(cleaned, radix: 16);
    if (value != null) return Color(0xFF000000 | value);
  }
  if (cleaned.length == 8) {
    final value = int.tryParse(cleaned, radix: 16);
    if (value != null) return Color(value);
  }
  return fallback;
}
