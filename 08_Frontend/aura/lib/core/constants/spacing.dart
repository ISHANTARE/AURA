/// AURA Spacing System — 8dp base grid
/// Source: 03_UX/design_system.md — Spacing section
/// Use these tokens everywhere. No literal dp values in widget files.
abstract final class AuraSpacing {
  static const double xs   = 4;   // Icon padding, tight gaps
  static const double sm   = 8;   // Between related elements
  static const double md   = 16;  // Card internal padding
  static const double lg   = 24;  // Section gaps
  static const double xl   = 32;  // Major screen sections
  static const double xl2  = 48;  // Hero/display spacing
  static const double xl3  = 64;  // Full-screen spacing

  /// Standard card padding — used in every BentoCard, TaskCard, etc.
  static const double cardPadding = md;

  /// Border width — neubrutalism rule: always 2px, no exceptions
  static const double borderWidth = 2.0;

  /// Shadow offset — neubrutalist hard drop shadow
  static const double shadowOffset = 4.0;

  /// Shadow offset for pressed/active state (pushes in)
  static const double shadowOffsetPressed = 2.0;

  /// Priority stripe width on task list items
  static const double priorityStripe = 4.0;

  /// Floating orb diameter
  static const double orbSize = 56.0;

  /// Mini orb diameter (in voice capture popup)
  static const double orbMiniSize = 32.0;

  /// Bottom navigation height
  static const double bottomNavHeight = 56.0;

  /// App bar height
  static const double appBarHeight = 56.0;

  /// Voice capture popup height (35% of screen)
  static const double capturePopupHeightFraction = 0.35;
}
