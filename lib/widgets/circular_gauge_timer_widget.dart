import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/styles.dart';

/// Custom circular arc timer gauge matching the Figma design exactly
class CircularGaugeTimerWidget extends StatelessWidget {
  final String formattedTime;
  final double progress; // 0.0 to 1.0
  final double size;
  final Widget? overlayWidget;

  const CircularGaugeTimerWidget({
    super.key,
    required this.formattedTime,
    this.progress = 0.65,
    this.size = 200,
    this.overlayWidget,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Circular arc painter
          CustomPaint(
            size: Size(size, size),
            painter: _GaugeArcPainter(
              progress: progress,
              strokeWidth: size * 0.08,
              trackColor: const Color(0xFFFBF4E8),
              progressColor: FactoryColors.timerArc,
            ),
          ),

          // Center Time Text
          Center(
            child: Text(
              formattedTime,
              style: FactoryTypography.display.copyWith(
                fontSize: size * 0.16,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                color: FactoryColors.textPrimary,
              ),
            ),
          ),

          // Optional floating overlay (e.g. Worker face bubble)
          if (overlayWidget != null)
            Positioned(
              top: -size * 0.08,
              right: -size * 0.08,
              child: overlayWidget!,
            ),
        ],
      ),
    );
  }
}

class _GaugeArcPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color trackColor;
  final Color progressColor;

  _GaugeArcPainter({
    required this.progress,
    required this.strokeWidth,
    required this.trackColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Full background track circle
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Active progress arc starting from top-left / 135 degrees
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Arc sweeps clockwise
    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugeArcPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor;
  }
}
