import 'package:flutter/material.dart';

class BatteryIndicator extends StatelessWidget {
  final double batteryLevel;

  const BatteryIndicator({
    super.key,
    required this.batteryLevel,
  });

  @override
  Widget build(BuildContext context) {
    Color batteryColor = Colors.green;
    if (batteryLevel < 0.2) {
      batteryColor = Colors.red;
    } else if (batteryLevel < 0.5) {
      batteryColor = Colors.orange;
    }

    return Container(
      width: 40,
      height: 20,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 2),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 1,
            top: 1,
            bottom: 1,
            child: Container(
              width: (36 * batteryLevel).clamp(0.0, 36.0),
              decoration: BoxDecoration(
                color: batteryColor,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
          Positioned(
            right: -3,
            top: 6,
            child: Container(
              width: 3,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(2),
                  bottomRight: Radius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
