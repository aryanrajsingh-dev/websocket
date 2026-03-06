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
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'MEMORY USAGE',
                    style: TextStyle(
                      color: AppTheme.accentCyan,
                      fontSize: 12,
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
              const SizedBox(height: 8),
              LayoutBuilder(
                builder: (context, constraints) {
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
                        widthFactor: clamped / 100,
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
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    '$usedGb GB / ${totalMemoryGB.toStringAsFixed(0)} GB',
                    style: TextStyle(
                      color: AppTheme.textSecondary.withOpacity(0.75),
                      fontSize: 11,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Free $freeGb GB',
                    style: TextStyle(
                      color: AppTheme.textSecondary.withOpacity(0.85),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.right,
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
