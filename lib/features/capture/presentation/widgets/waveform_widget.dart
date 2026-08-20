import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

/// Neubrutalist Lime Waveform Widget reacting in real-time to audio amplitude.
class WaveformWidget extends StatefulWidget {

  const WaveformWidget({
    super.key,
    required this.audioLevel,
    this.barCount = 14,
    this.height = 24.0,
  });
  final double audioLevel; // 0.0 to 1.0
  final int barCount;
  final double height;

  @override
  State<WaveformWidget> createState() => _WaveformWidgetState();
}

class _WaveformWidgetState extends State<WaveformWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _idleController;
  final Random _random = Random(42);

  @override
  void initState() {
    super.initState();
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _idleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _idleController,
      builder: (context, child) {
        return SizedBox(
          height: widget.height,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(widget.barCount, (index) {
              // Calculate dynamic height ratio per bar
              final centerDistance =
                  (index - widget.barCount / 2).abs() / (widget.barCount / 2);
              final bellCurveFactor = 1.0 - (centerDistance * 0.4);

              final idleNoise =
                  sin((_idleController.value * 2 * pi) + (index * 0.5)) * 0.15;
              final inputLevel = (widget.audioLevel * 1.5).clamp(0.0, 1.0);

              final baseHeightRatio = (inputLevel > 0.05)
                  ? (inputLevel * bellCurveFactor * (0.4 + (_random.nextDouble() * 0.6)))
                  : (0.15 + idleNoise);

              final barHeightRatio = baseHeightRatio.clamp(0.1, 1.0);

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2.0),
                width: 3.5,
                height: widget.height * barHeightRatio,
                decoration: BoxDecoration(
                  color: AuraColors.accentLime,
                  borderRadius: BorderRadius.circular(1.5),
                  border: Border.all(
                    color: Colors.black,
                    width: 0.5,
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
