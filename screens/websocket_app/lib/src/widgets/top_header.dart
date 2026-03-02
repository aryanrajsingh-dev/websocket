import 'package:flutter/material.dart';
import 'battery_indicator.dart';
import 'mode_indicator.dart';
import '../utils/time_formatter.dart';

class TopHeader extends StatelessWidget {
  final Duration upTime;
  final bool wifiConnected;
  final double batteryLevel;

  const TopHeader({
    super.key,
    required this.upTime,
    required this.wifiConnected,
    required this.batteryLevel,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 800;
        final gap = isCompact ? 12.0 : 30.0;

        return Container(
          padding: EdgeInsets.symmetric(horizontal: isCompact ? 12 : 20, vertical: 15),
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border(
              bottom: BorderSide(color: Colors.cyan.withOpacity(0.5), width: 1),
            ),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Text(
                  'SCOUT MK1.1',
                  style: TextStyle(
                    color: Colors.cyan,
                    fontSize: isCompact ? 18 : 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(width: gap),
                ModeIndicator(mode: 'SAFE HOLD'),
                SizedBox(width: gap),
                _buildInfoItem('UP TIME', TimeFormatter.formatUpTime(upTime)),
                SizedBox(width: gap),
                Icon(
                  Icons.wifi,
                  color: wifiConnected ? Colors.cyan : Colors.grey,
                  size: 28,
                ),
                SizedBox(width: gap),
                Text(
                  '${TimeFormatter.getCurrentDate()}  ${TimeFormatter.getCurrentTime()}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isCompact ? 16 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: gap),
                BatteryIndicator(batteryLevel: batteryLevel),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$label : ',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

