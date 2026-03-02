import 'package:flutter/material.dart';
import '../models/display_model.dart';

class CpuUsageCard extends StatelessWidget {
  final DisplayModel? displayModel;

  const CpuUsageCard({super.key, required this.displayModel});

  @override
  Widget build(BuildContext context) {
    final cpuUsage = displayModel?.cpuUsage ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: Colors.cyan.withOpacity(0.3), width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'CPU USAGE',
            style: TextStyle(
              color: Colors.cyan,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: cpuUsage / 100,
                  strokeWidth: 6,
                  backgroundColor: Colors.grey[800],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getCpuColor(cpuUsage),
                  ),
                ),
                Text(
                  '$cpuUsage%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getCpuColor(int percent) {
    if (percent < 50) return Colors.green;
    if (percent < 80) return Colors.yellow;
    return Colors.red;
  }
}
