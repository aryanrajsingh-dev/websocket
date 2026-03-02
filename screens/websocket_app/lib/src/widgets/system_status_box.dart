import 'package:flutter/material.dart';
import '../models/display_model.dart';

class SystemStatusBox extends StatelessWidget {
  final DisplayModel? displayModel;

  const SystemStatusBox({super.key, required this.displayModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: Colors.cyan.withOpacity(0.3), width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'SYSTEM INFO',
            style: TextStyle(
              color: Colors.cyan,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatusRow('Status', displayModel?.systemStatus ?? ''),
          const SizedBox(height: 10),
          _buildStatusRow('Connection', displayModel?.connectionState ?? ''),
          const SizedBox(height: 10),
          _buildStatusRow('Mode', displayModel?.activeMode ?? ''),
          const SizedBox(height: 10),
          _buildStatusRow('Firmware', displayModel?.firmwareVersion ?? ''),
          const SizedBox(height: 10),
          _buildStatusRow('Temp', displayModel?.internalTemp ?? ''),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
