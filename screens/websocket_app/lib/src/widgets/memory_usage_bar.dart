import 'package:flutter/material.dart';
import '../models/display_model.dart';

class MemoryUsageBar extends StatelessWidget {
  final DisplayModel? displayModel;

  const MemoryUsageBar({super.key, required this.displayModel});

  @override
  Widget build(BuildContext context) {
    final memoryUsage = displayModel?.memoryUsage ?? 0;
    final memPercent = memoryUsage / 100;

    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: Colors.cyan.withOpacity(0.3), width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'MEMORY USAGE',
                style: TextStyle(
                  color: Colors.cyan,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                '$memoryUsage%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: memPercent,
            backgroundColor: Colors.grey[900],
            valueColor: AlwaysStoppedAnimation<Color>(
              _getMemoryColor(memoryUsage),
            ),
          ),
          const SizedBox(height: 10),
          const _MemoryUsageLegend(),
        ],
      ),
    );
  }

  Color _getMemoryColor(int percent) {
    if (percent < 60) return Colors.cyan;
    if (percent < 85) return Colors.yellow;
    return Colors.red;
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
          color: Colors.cyan,
          label: 'Healthy',
          range: '<60%',
        ),
        _MemoryLegendItem(
          color: Colors.yellow,
          label: 'Warning',
          range: '60-84%',
        ),
        _MemoryLegendItem(
          color: Colors.red,
          label: 'Critical',
          range: '\u226585%',
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
            color: color.withOpacity(0.9),
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
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              range,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
