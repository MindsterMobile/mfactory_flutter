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
  final bool isPaused;
  final String? statusText;
  final Color? progressColor;

  const CircularGaugeTimerWidget({
    super.key,
    required this.formattedTime,
    this.progress = 0.0,
    this.size = 200,
    this.overlayWidget,
    this.isPaused = false,
    this.statusText,
    this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveProgressColor = progressColor ??
        (isPaused ? const Color(0xFFF59E0B) : FactoryColors.timerArc);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Smoothly animated circular arc painter
          TweenAnimationBuilder<double>(
            key: ValueKey(isPaused),
            tween: Tween<double>(
              begin: progress,
              end: progress,
            ),
            duration: isPaused
                ? const Duration(milliseconds: 250)
                : (progress <= 0.02
                    ? Duration.zero
                    : const Duration(milliseconds: 950)),
            curve: Curves.linear,
            builder: (context, animatedProgress, child) {
              return CustomPaint(
                size: Size(size, size),
                painter: _GaugeArcPainter(
                  progress: animatedProgress,
                  strokeWidth: size * 0.08,
                  trackColor: const Color(0xFFFBF4E8),
                  progressColor: effectiveProgressColor,
                ),
              );
            },
          ),

          // Center Time Text and optional Status Badge
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  formattedTime,
                  style: FactoryTypography.display.copyWith(
                    fontSize: size * 0.16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: isPaused
                        ? const Color(0xFF475569)
                        : FactoryColors.textPrimary,
                  ),
                ),
                if (statusText != null && statusText!.isNotEmpty) ...[
                  SizedBox(height: size * 0.025),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: size * 0.05,
                      vertical: size * 0.015,
                    ),
                    decoration: BoxDecoration(
                      color: isPaused
                          ? const Color(0xFFFEF3C7)
                          : const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(size * 0.05),
                      border: Border.all(
                        color: isPaused
                            ? const Color(0xFFF59E0B)
                            : const Color(0xFF16A34A),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      statusText!,
                      style: TextStyle(
                        fontSize: size * 0.052,
                        fontWeight: FontWeight.w700,
                        color: isPaused
                            ? const Color(0xFFD97706)
                            : const Color(0xFF15803D),
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ],
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

    if (progress <= 0.0) return;

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
