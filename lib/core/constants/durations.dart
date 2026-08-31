/// AURA Animation & Timing Durations
/// Source: 03_UX/design_system.md
abstract final class AuraDurations {
  /// Snappy micro-interactions (button press, checkbox toggle)
  static const Duration fast = Duration(milliseconds: 100);

  /// Standard transitions (tab switch, modal slide)
  static const Duration normal = Duration(milliseconds: 250);

  /// Hero animations, orb expansion
  static const Duration slow = Duration(milliseconds: 400);

  /// Waveform update frequency
  static const Duration waveformSample = Duration(milliseconds: 50);

  /// Auto-dismiss delay for toast / status banners
  static const Duration toastDuration = Duration(seconds: 3);
}
