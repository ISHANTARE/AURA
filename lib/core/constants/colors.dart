import 'package:flutter/material.dart';

/// AURA's neo-brutalist OLED color palette, semantic tokens, and accent variants.
/// Reference: overhaul-docs/08-design-system.md
abstract final class AuraColors {
  // ── Background Layers (OLED Dark Theme) ───────────────────────────────────
  static const Color bgBase = Color(0xFF0D0D11); // OLED Black - deepest background
  static const Color bgCard = Color(0xFF16161E); // Card/surface layer
  static const Color bgElevated = Color(0xFF1F1F2C); // Elevated modals/sheets
  static const Color bgSubtle = Color(0xFF252534); // Input fields / hover states

  // ── Borders & Dividers ───────────────────────────────────────────────────
  static const Color border = Color(0xFF2A2A3C); // Standard border
  static const Color borderMuted = Color(0xFF1E1E2C); // Subtle dividers

  // ── Typography Hierarchy ─────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFE8E8F0); // Main text, headings
  static const Color textSecondary = Color(0xFF9898B0); // Labels, metadata
  static const Color textMuted = Color(0xFF585870); // Timestamps, hints, placeholders
  static const Color textInverse = Color(0xFF0D0D11); // Text on light/colored backgrounds

  // ── 6 Selectable Accent Variants ─────────────────────────────────────────
  static const Color accentIndigo = Color(0xFF7B6FF0); // Neon Indigo (Default)
  static const Color accentCyan = Color(0xFF22D3EE); // Cyber Cyan
  static const Color accentPurple = Color(0xFFC084FC); // Electric Purple
  static const Color accentOrange = Color(0xFFFF9966); // Sunset Orange
  static const Color accentRose = Color(0xFFF472B6); // Rose Gold
  static const Color accentLime = Color(0xFFC8FF00); // Acid Lime

  // ── Semantic Status Colors ───────────────────────────────────────────────
  static const Color accentGreen = Color(0xFF34D399); // Success, completed
  static const Color accentAmber = Color(0xFFFBBF24); // Warning, upcoming
  static const Color accentRed = Color(0xFFF87171); // Error, overdue, urgent

  // ── Priority Color Mapping ───────────────────────────────────────────────
  static const Color priorityHigh = Color(0xFFFF6B6B); // Red-coral (urgent)
  static const Color priorityMedium = Color(0xFFFBBF24); // Amber (important)
  static const Color priorityLow = Color(0xFF34D399); // Green (tracked)

  // ── Light Theme Overrides (when THEME_MODE = 'light') ────────────────────
  static const Color lightBgBase = Color(0xFFF5F5F7);
  static const Color lightBgCard = Color(0xFFFFFFFF);
  static const Color lightBgElevated = Color(0xFFE8E8EF);
  static const Color lightTextPrimary = Color(0xFF1A1A2E);
  static const Color lightTextSecondary = Color(0xFF4A4A6A);
  static const Color lightTextMuted = Color(0xFF9898B0);
  static const Color lightBorder = Color(0xFFE0E0EE);
}
