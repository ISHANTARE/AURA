import 'package:flutter/material.dart';

/// AURA Color System
/// Source: 03_UX/design_system.md
/// Every color in the app must come from this class. No hardcoded hex values elsewhere.
abstract final class AuraColors {
  // ── Base Palette ─────────────────────────────────────────────────────────
  static const Color bgBase     = Color(0xFF0D0D0D); // Main app background
  static const Color bgCard     = Color(0xFF141414); // Bento card / cell background
  static const Color bgElevated = Color(0xFF1C1C1C); // Modals, overlays, bottom sheets

  // ── Border / Shadow ───────────────────────────────────────────────────────
  /// All card borders — pure white, full opacity. Never deviate from this.
  static const Color border      = Color(0xFFFFFFFF);
  /// Subtle dividers, inactive states
  static const Color borderMuted = Color(0x26FFFFFF); // rgba(255,255,255,0.15)
  /// Hard neubrutalist shadow color — blurRadius must always be 0
  static const Color shadow      = Color(0xFFFFFFFF);

  // ── Accent Palette ────────────────────────────────────────────────────────
  /// Primary CTA, active states, orb, AURA brand. The ONE lime.
  static const Color accentLime   = Color(0xFFC8FF00);
  /// Events, calendar items
  static const Color accentBlue   = Color(0xFF4DFFFF);
  /// Warnings, medium priority
  static const Color accentOrange = Color(0xFFFF7A29);
  /// Overdue, high priority, urgent
  static const Color accentRed    = Color(0xFFFF3B3B);
  /// Success, completed tasks
  static const Color accentGreen  = Color(0xFF39FF88);
  /// Recurring tasks, habits
  static const Color accentPurple = Color(0xFFB57BFF);

  // ── Text ──────────────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0x99FFFFFF); // rgba(255,255,255,0.6)
  static const Color textDisabled  = Color(0x4DFFFFFF); // rgba(255,255,255,0.3)
  /// Text on lime (#C8FF00) backgrounds — buttons, chips
  static const Color textOnAccent  = Color(0xFF000000);

  // ── Semantic shortcuts ────────────────────────────────────────────────────
  static const Color priorityHigh   = accentRed;
  static const Color priorityMedium = accentOrange;
  static const Color priorityLow    = borderMuted;

  static const Color deadlineSafe    = accentGreen;
  static const Color deadlineWarning = accentOrange;
  static const Color deadlineCritical = accentRed;

  // ── Orb glow — the ONLY glow-style element in the entire app ─────────────
  /// Orb atmospheric glow. blurRadius: 28, spreadRadius: 8, opacity: 8%.
  /// Per ADR (Glow Rule): nothing else uses this.
  static const Color orbGlow      = Color(0x14C8FF00); // rgba(200,255,0,0.08)
  static const Color orbGlowMini  = Color(0x0FC8FF00); // rgba(200,255,0,0.06)
}
