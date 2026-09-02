import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/spacing.dart';

/// Premium Bento Card — soft layered elevation, rounded corners, subtle outline.
/// Base container for home screen widgets.
class BentoCard extends StatefulWidget {
  const BentoCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AuraSpacing.md),
    this.borderRadius = 16.0,
    this.backgroundColor,
    this.borderColor,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;

  @override
  State<BentoCard> createState() => _BentoCardState();
}

class _BentoCardState extends State<BentoCard> {
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
    final bg = widget.backgroundColor ?? AuraColors.cardOf(context);
    final border = widget.borderColor ?? AuraColors.borderOf(context);
    final shadowColor = AuraColors.isDarkMode(context)
        ? AuraColors.shadow
        : AuraColors.lightShadow;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        transform: _pressed
            ? (Matrix4.identity()..scale(0.98))
            : Matrix4.identity(),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(color: border, width: 1),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 16,
              spreadRadius: 0,
              offset: const Offset(0, 4),
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

