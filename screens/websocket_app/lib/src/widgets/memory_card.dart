import 'dart:ui';

import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class MemoryCard extends StatelessWidget {
  final int memoryUsage;
  final double totalMemoryGB;

  const MemoryCard({
    super.key,
    required this.memoryUsage,
    this.totalMemoryGB = 16,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = memoryUsage.clamp(0, 100);
    final usedValue = clamped / 100 * totalMemoryGB;
    final usedGb = usedValue.toStringAsFixed(1);
    final freeGb = (totalMemoryGB - usedValue).clamp(0, totalMemoryGB).toStringAsFixed(1);

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
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'MEMORY USAGE',
                    style: TextStyle(
                      color: AppTheme.accentCyan,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Text(
                    '$clamped%',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  return TweenAnimationBuilder<double>(
                    tween: Tween<double>(
                      begin: 0,
                      end: clamped / 100,
                    ),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) {
                      final barColor = _colorForUsage(clamped);
                      return Container(
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: value,
                            child: Container(
                              decoration: BoxDecoration(
                                color: barColor,
                                borderRadius: BorderRadius.circular(7),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 8),
              const _MemoryUsageLegend(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$usedGb GB / ${totalMemoryGB.toStringAsFixed(0)} GB used',
                    style: TextStyle(
                      color: AppTheme.textSecondary.withOpacity(0.75),
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    'Free $freeGb GB',
                    style: TextStyle(
                      color: AppTheme.textSecondary.withOpacity(0.85),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Color _colorForUsage(int percent) {
    if (percent < 60) return const Color(0xFF00E676);
    if (percent < 85) return const Color(0xFFFFC107);
    return const Color(0xFFFF5252);
  }
}

class _MemoryUsageLegend extends StatelessWidget {
  const _MemoryUsageLegend();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        _MemoryLegendItem(
          color: Color(0xFF00E676),
          label: 'Healthy',
          range: '0-59%',
        ),
        _MemoryLegendItem(
          color: Color(0xFFFFC107),
          label: 'Warning',
          range: '60-84%',
        ),
        _MemoryLegendItem(
          color: Color(0xFFFF5252),
          label: 'Critical',
          range: '85-100%',
        ),
      ],
    );
  }
}

class _MemoryLegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String range;

  const _MemoryLegendItem({
    required this.color,
    required this.label,
    required this.range,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 18,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              range,
              style: TextStyle(
                color: AppTheme.textSecondary.withOpacity(0.7),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
