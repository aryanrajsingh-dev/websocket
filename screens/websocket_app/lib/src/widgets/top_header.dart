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

        final titleWidget = Text(
          'SCOUT MK1.1',
          style: TextStyle(
            color: Colors.cyan,
            fontSize: isCompact ? 18 : 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        );

        final modeWidget = ModeIndicator(mode: 'SAFE HOLD');

        final uptimeWidget = _buildInfoItem('UP TIME', TimeFormatter.formatUpTime(upTime));

        final wifiWidget = Icon(
          Icons.wifi,
          color: wifiConnected ? Colors.cyan : Colors.grey,
          size: 28,
        );

        final dateTimeWidget = Text(
          '${TimeFormatter.getCurrentDate()}  ${TimeFormatter.getCurrentTime()}',
          style: TextStyle(
            color: Colors.white,
            fontSize: isCompact ? 16 : 18,
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.fade,
          softWrap: false,
        );

        final batteryWidget = BatteryIndicator(batteryLevel: batteryLevel);

        // On very narrow widths, keep a horizontally scrollable row to avoid overflow.
        final isVeryNarrow = constraints.maxWidth < 700;

        if (isVeryNarrow) {
          return Container(
            width: double.infinity,
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
                  titleWidget,
                  SizedBox(width: gap),
                  modeWidget,
                  SizedBox(width: gap),
                  uptimeWidget,
                  SizedBox(width: gap),
                  wifiWidget,
                  SizedBox(width: gap),
                  dateTimeWidget,
                  SizedBox(width: gap),
                  batteryWidget,
                ],
              ),
            ),
          );
        }

        // On wider screens, split content into left and right clusters that
        // automatically share the available space.
        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: isCompact ? 16 : 24, vertical: 15),
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border(
              bottom: BorderSide(color: Colors.cyan.withOpacity(0.5), width: 1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  titleWidget,
                  SizedBox(width: gap),
                  modeWidget,
                ],
              ),
              Flexible(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Flexible(child: uptimeWidget),
                    SizedBox(width: gap),
                    wifiWidget,
                    SizedBox(width: gap),
                    Flexible(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: dateTimeWidget,
                      ),
                    ),
                    SizedBox(width: gap),
                    batteryWidget,
                  ],
                ),
              ),
            ],
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

