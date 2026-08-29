import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/colors.dart';
import '../constants/spacing.dart';
import '../constants/typography.dart';

// ── BentoCard ─────────────────────────────────────────────────────────────────

/// Primary neo-brutalist Bento container. Renders a bordered, filled card with
/// optional tap-ripple and accent glow.
class BentoCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderRadius;
  final Color? glowColor;
  final VoidCallback? onTap;

  const BentoCard({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.glowColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = Theme.of(context).colorScheme.primary;
    final glow = glowColor ?? (onTap != null ? accentColor : null);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: backgroundColor ?? AuraColors.bgCard,
        borderRadius: BorderRadius.circular(borderRadius ?? AuraRadius.lg),
        border: Border.all(
          color: borderColor ?? AuraColors.border,
          width: 1.0,
        ),
        boxShadow: glow != null
            ? [BoxShadow(color: glow.withValues(alpha: 0.12), blurRadius: 16, spreadRadius: 0)]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius ?? AuraRadius.lg),
        child: InkWell(
          onTap: onTap != null
              ? () {
                  HapticFeedback.lightImpact();
                  onTap!();
                }
              : null,
          borderRadius: BorderRadius.circular(borderRadius ?? AuraRadius.lg),
          splashColor: accentColor.withValues(alpha: 0.08),
          highlightColor: accentColor.withValues(alpha: 0.04),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(AuraSpacing.md),
            child: child,
          ),
        ),
      ),
    );
  }
}

// ── GlassmorphicContainer ─────────────────────────────────────────────────────

/// Blurred-backdrop glassmorphic surface for modals, overlays, and capture UI.
class GlassmorphicContainer extends StatelessWidget {
  final Widget child;
  final double? borderRadius;
  final EdgeInsets? padding;
  final double blurSigma;
  final Color? borderColor;

  const GlassmorphicContainer({
    super.key,
    required this.child,
    this.borderRadius,
    this.padding,
    this.blurSigma = 20.0,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius ?? AuraRadius.xl),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          decoration: BoxDecoration(
            color: AuraColors.bgBase.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(borderRadius ?? AuraRadius.xl),
            border: Border.all(
              color: borderColor ?? Colors.white.withValues(alpha: 0.08),
              width: 1,
            ),
          ),
          padding: padding ?? const EdgeInsets.all(AuraSpacing.md),
          child: child,
        ),
      ),
    );
  }
}

// ── AuraButton ────────────────────────────────────────────────────────────────

enum AuraButtonVariant { primary, secondary, outline, destructive }

/// Styled action button with 4 variants and haptic feedback.
class AuraButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AuraButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;

  const AuraButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AuraButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    Color bg;
    Color fg;
    Color border;

    switch (variant) {
      case AuraButtonVariant.primary:
        bg = accent;
        fg = AuraColors.textInverse;
        border = accent;
      case AuraButtonVariant.secondary:
        bg = AuraColors.bgElevated;
        fg = AuraColors.textPrimary;
        border = AuraColors.border;
      case AuraButtonVariant.outline:
        bg = Colors.transparent;
        fg = accent;
        border = accent;
      case AuraButtonVariant.destructive:
        bg = AuraColors.accentRed.withValues(alpha: 0.12);
        fg = AuraColors.accentRed;
        border = AuraColors.accentRed.withValues(alpha: 0.4);
    }

    final content = isLoading
        ? SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: fg,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: fg),
                const SizedBox(width: AuraSpacing.xs),
              ],
              Text(
                label,
                style: AuraTypography.label.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          );

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(AuraRadius.md),
        child: InkWell(
          onTap: onPressed != null && !isLoading
              ? () {
                  HapticFeedback.lightImpact();
                  onPressed!();
                }
              : null,
          borderRadius: BorderRadius.circular(AuraRadius.md),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: border, width: 1),
              borderRadius: BorderRadius.circular(AuraRadius.md),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AuraSpacing.md,
              vertical: AuraSpacing.sm + 2,
            ),
            child: Center(child: content),
          ),
        ),
      ),
    );
  }
}

// ── AuraChip ──────────────────────────────────────────────────────────────────

/// Styled chip for workspace tags, priority badges, and filter selectors.
class AuraChip extends StatelessWidget {
  final String label;
  final Color? color;
  final bool selected;
  final VoidCallback? onTap;
  final IconData? icon;

  const AuraChip({
    super.key,
    required this.label,
    this.color,
    this.selected = false,
    this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: AuraSpacing.sm + 2,
          vertical: AuraSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: selected ? chipColor.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(AuraRadius.full),
          border: Border.all(
            color: selected ? chipColor : AuraColors.border,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 12, color: selected ? chipColor : AuraColors.textSecondary),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: AuraTypography.caption.copyWith(
                color: selected ? chipColor : AuraColors.textSecondary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── StatusBadge ───────────────────────────────────────────────────────────────

enum StatusBadgeType { online, offline, pending }

/// Compact connection status badge used in the home screen header.
class SyncStatusBadge extends StatelessWidget {
  final bool isOnline;

  const SyncStatusBadge({super.key, required this.isOnline});

  @override
  Widget build(BuildContext context) {
    final color = isOnline ? AuraColors.accentGreen : AuraColors.accentAmber;
    final label = isOnline ? 'Live' : 'Offline';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AuraRadius.full),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AuraTypography.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── PriorityBadge ─────────────────────────────────────────────────────────────

/// Visual badge for task priority levels.
class PriorityBadge extends StatelessWidget {
  final String priority;

  const PriorityBadge({super.key, required this.priority});

  static Color colorFor(String priority) {
    return switch (priority.toLowerCase()) {
      'high' => AuraColors.accentRed,
      'medium' => AuraColors.accentAmber,
      _ => AuraColors.accentGreen,
    };
  }

  @override
  Widget build(BuildContext context) {
    final color = colorFor(priority);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AuraRadius.xs),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(
        priority.toUpperCase(),
        style: AuraTypography.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 10,
        ),
      ),
    );
  }
}
