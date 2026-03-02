import 'dart:ui';

import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class CpuCard extends StatelessWidget {
  final int cpuUsage;

  const CpuCard({super.key, required this.cpuUsage});

  @override
  Widget build(BuildContext context) {
    final clamped = cpuUsage.clamp(0, 100);

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.cardPadding),
          decoration: BoxDecoration(
            color: AppTheme.cardBackground,
            borderRadius: BorderRadius.circular(AppTheme.cardRadius),
            border: Border.all(
              color: AppTheme.cardBorder.withOpacity(0.6),
              width: 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 18,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'CPU USAGE',
                style: TextStyle(
                  color: AppTheme.accentCyan,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Processor load',
                style: TextStyle(
                  color: AppTheme.textSecondary.withOpacity(0.7),
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: SizedBox(
                  width: 110,
                  height: 110,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(
                      begin: 0,
                      end: clamped / 100,
                    ),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) {
                      final ringColor = _cpuUsageColor(clamped.toInt());
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox.expand(
                            child: CustomPaint(
                              painter: _CpuRingPainter(
                                progress: value,
                                color: ringColor,
                              ),
                            ),
                          ),
                          Text(
                            '${(value * 100).round()}%',
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CpuRingPainter extends CustomPainter {
  final double progress;
  final Color color;

  _CpuRingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    const strokeWidth = 8.0;
    final radius = (size.shortestSide - strokeWidth) / 2;

    final trackPaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradient = SweepGradient(
      startAngle: -3.14159 / 2,
      endAngle: 3 * 3.14159 / 2,
      colors: [
        color.withOpacity(0.5),
        color,
      ],
    );

    final progressPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * 3.14159 * progress;
    canvas.drawArc(
      rect,
      -3.14159 / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CpuRingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

Color _cpuUsageColor(int percent) {
  if (percent < 50) {
    return Colors.greenAccent;
  }
  if (percent < 80) {
    return Colors.orangeAccent;
  }
  return Colors.redAccent;
}
