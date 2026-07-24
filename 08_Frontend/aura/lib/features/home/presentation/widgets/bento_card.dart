import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/spacing.dart';

/// Base bento card — hard drop-shadow, 2px white border, #141414 background.
/// All home screen cells extend this.
class BentoCard extends StatefulWidget {
  const BentoCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AuraSpacing.md),
    this.borderRadius = 0,
    this.backgroundColor = AuraColors.bgCard,
    this.borderColor = AuraColors.border,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color backgroundColor;
  final Color borderColor;

  @override
  State<BentoCard> createState() => _BentoCardState();
}

class _BentoCardState extends State<BentoCard>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;

  void _onTapDown(TapDownDetails _) {
    if (widget.onTap == null) return;
    setState(() => _pressed = true);
  }

  void _onTapUp(TapUpDetails _) {
    if (widget.onTap == null) return;
    setState(() => _pressed = false);
    HapticFeedback.lightImpact();
    widget.onTap!();
  }

  void _onTapCancel() => setState(() => _pressed = false);

  @override
  Widget build(BuildContext context) {
    final offset = _pressed
        ? AuraSpacing.shadowOffsetPressed
        : AuraSpacing.shadowOffset;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        curve: Curves.easeOut,
        transform: _pressed
            ? (Matrix4.identity()
              ..translate(
                  AuraSpacing.shadowOffset - AuraSpacing.shadowOffsetPressed,
                  AuraSpacing.shadowOffset - AuraSpacing.shadowOffsetPressed))
            : Matrix4.identity(),
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(color: widget.borderColor, width: AuraSpacing.borderWidth),
          boxShadow: [
            BoxShadow(
              color: AuraColors.shadow,
              offset: Offset(offset, offset),
              blurRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: Padding(padding: widget.padding, child: widget.child),
        ),
      ),
    );
  }
}
