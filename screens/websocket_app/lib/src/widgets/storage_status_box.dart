import 'package:flutter/material.dart';

class StorageStatusBox extends StatelessWidget {
  final int storagePercent;
  final String diskUsedGB;
  final String diskTotalGB;
  final String writeSpeedMBs;

  const StorageStatusBox({
    super.key,
    required this.storagePercent,
    required this.diskUsedGB,
    required this.diskTotalGB,
    required this.writeSpeedMBs,
  });

  Color _getStorageColor(int percent) {
    if (percent < 60) return Colors.green;
    if (percent < 80) return Colors.yellow;
    return Colors.red;
  }

  String _getStorageLabel(int percent) {
    if (percent < 60) return 'Normal';
    if (percent < 80) return 'Warning';
    return 'Critical';
  }

  @override
  Widget build(BuildContext context) {
    final storageColor = _getStorageColor(storagePercent);
    final storageLabel = _getStorageLabel(storagePercent);

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
            'STORAGE STATUS',
            style: TextStyle(
              color: Colors.cyan,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          _buildStorageBar(storageColor),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                storageLabel,
                style: TextStyle(
                  color: storageColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$storagePercent%',
                style: TextStyle(
                  color: storageColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildDetailRow('Used / Total', '$diskUsedGB GB / $diskTotalGB GB'),
          const SizedBox(height: 10),
          _buildDetailRow('Write Speed', '$writeSpeedMBs MB/s'),
        ],
      ),
    );
  }

  Widget _buildStorageBar(Color color) {
    return Column(
      children: [
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: Colors.cyan.withOpacity(0.2), width: 0.5),
          ),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: FractionallySizedBox(
                  widthFactor: storagePercent / 100,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color.withOpacity(0.6), color],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
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
            style: const TextStyle(
              color: Colors.white,
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
}
