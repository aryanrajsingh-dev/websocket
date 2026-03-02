import 'package:flutter/material.dart';

class NetworkDetailsBox extends StatelessWidget {
  final String ipAddress;
  final int signalStrength;
  final String latency;

  const NetworkDetailsBox({
    super.key,
    required this.ipAddress,
    required this.signalStrength,
    required this.latency,
  });

  Color _getSignalColor(int dBm) {
    if (dBm >= -50) return Colors.green;
    if (dBm >= -70) return Colors.cyan;
    if (dBm >= -85) return Colors.yellow;
    return Colors.red;
  }

  String _getSignalLabel(int dBm) {
    if (dBm >= -50) return 'Excellent';
    if (dBm >= -70) return 'Good';
    if (dBm >= -85) return 'Fair';
    return 'Poor';
  }

  @override
  Widget build(BuildContext context) {
    final signalColor = _getSignalColor(signalStrength);
    final signalLabel = _getSignalLabel(signalStrength);

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
          Text(
            'NETWORK DETAILS',
            style: TextStyle(
              color: Colors.cyan,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow('IP Address', ipAddress, Colors.white),
          const SizedBox(height: 12),
          _buildSignalRow(signalStrength, signalLabel, signalColor),
          const SizedBox(height: 12),
          _buildDetailRow('Latency', latency, Colors.white),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              fontFamily: 'monospace',
            ),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildSignalRow(int dBm, String label, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Flexible(
          child: Text(
            'Signal Strength',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '$dBm dBm',
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    border: Border.all(color: color, width: 0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}