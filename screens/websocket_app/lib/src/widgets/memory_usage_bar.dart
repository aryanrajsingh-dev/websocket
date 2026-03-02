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
