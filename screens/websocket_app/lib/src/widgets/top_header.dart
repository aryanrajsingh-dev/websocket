import 'package:flutter/material.dart';
import 'battery_indicator.dart';
import 'mode_indicator.dart';
import '../utils/time_formatter.dart';

class TopHeader extends StatelessWidget {
  final String mode;
  final Duration upTime;
  final bool wifiConnected;
  final double batteryLevel;

  const TopHeader({
    super.key,
    required this.mode,
    required this.upTime,
    required this.wifiConnected,
    required this.batteryLevel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(
          bottom: BorderSide(color: Colors.cyan.withOpacity(0.5), width: 1),
        ),
      ),
      child: Row(
        children: [
          Text(
            'SCOUT MK1.1  UI : AZ001',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          ModeIndicator(mode: mode),
          const SizedBox(width: 30),
          _buildInfoItem('UP TIME', TimeFormatter.formatUpTime(upTime)),
          const SizedBox(width: 30),
          Icon(
            Icons.wifi,
            color: wifiConnected ? Colors.cyan : Colors.grey,
            size: 28,
          ),
          const SizedBox(width: 30),
          Text(
            TimeFormatter.getCurrentDate(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 15),
          Text(
            TimeFormatter.getCurrentTime(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 20),
          BatteryIndicator(batteryLevel: batteryLevel),
        ],
      ),
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
              fontSize: 16,
            ),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
