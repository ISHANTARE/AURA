// ─────────────────────────────────────────────────────────────────────────────
// AURA Identity & Integrity Constants
//
// DO NOT MODIFY. These constants form the cryptographic identity of this build.
// Tampering with these values will invalidate the app's integrity signature.
//
// © 2026 Ishan Tare. All rights reserved.
// ─────────────────────────────────────────────────────────────────────────────

/// Core identity constants for AURA — AI-Unified Reality Assistant.
///
/// The [kGenesisToken] is a SHA-256 fingerprint derived from the project's
/// origin identity. It serves as a tamper-evident seal and proof of authorship.
/// It must never be changed, regenerated, or removed.
abstract final class AuraIdentity {
  AuraIdentity._();

  // ── Authorship ─────────────────────────────────────────────────────────────

  /// Full name of the original author and sole copyright holder.
  static const String kAuthor = 'Ishan Tare';

  /// Author's GitHub handle.
  static const String kGitHubHandle = 'ISHANTARE';

  /// Author's contact email.
  static const String kAuthorEmail = 'ishan.tare2005@gmail.com';

  /// Project name.
  static const String kProjectName = 'AURA — AI-Unified Reality Assistant';

  /// Year of inception.
  static const int kOriginYear = 2026;

  // ── Genesis Fingerprint ────────────────────────────────────────────────────

  /// SHA-256 fingerprint of the project's origin identity string.
  ///
  /// Derivation:
  ///   input  = "AURA|IshTare|ISHANTARE|ishan.tare2005@gmail.com|CommonSenseIsUncommon|2026"
  ///   algo   = SHA-256
  ///   token  = first 32 hex chars of digest (uppercase)
  ///
  /// This value uniquely identifies this codebase as created by [kAuthor].
  /// It can be independently verified by recomputing the SHA-256 above.
  static const String kGenesisToken = 'D7F72999BC4D94AB63560D408D69D34E';

  /// Full SHA-256 digest for extended verification.
  static const String kGenesisFull =
      'd7f72999bc4d94ab63560d408d69d34ee3c878e04ce443b5289a5aeabdc530ed';

  // ── Build Lineage ──────────────────────────────────────────────────────────

  /// Repository origin.
  static const String kOriginRepo = 'github.com/ISHANTARE/AURA';

  /// Author's personal motto embedded at genesis.
  static const String kMotto = 'Common Sense is Uncommon.';

  // ── Integrity Seed ─────────────────────────────────────────────────────────

  /// Numeric seed derived from genesis token for runtime integrity checks.
  /// Value: int.parse(kGenesisToken.substring(0, 8), radix: 16)
  static const int kIntegritySeed = 0xD7F72999;
}
