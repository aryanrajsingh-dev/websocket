import 'package:flutter/material.dart';
import '../models/display_model.dart';

class ComputeDetailsPanel extends StatelessWidget {
  final DisplayModel? displayModel;

  const ComputeDetailsPanel({super.key, this.displayModel});

  TextStyle get _sectionTitleStyle => const TextStyle(
        color: Colors.cyan,
      fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      );

  TextStyle get _headerStyle => const TextStyle(
        color: Colors.white70,
      fontSize: 10,
        fontWeight: FontWeight.w600,
      );

  TextStyle get _cellStyle => const TextStyle(
        color: Colors.white,
      fontSize: 10,
        fontWeight: FontWeight.w500,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: Colors.cyan.withOpacity(0.3), width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
	  padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('MISSION COMPUTER HEALTH', style: _sectionTitleStyle),
		  const SizedBox(height: 4),
          _buildMissionHealthTable(),
        ],
      ),
    );
  }

  Widget _buildMissionHealthTable() {
    const items = [
      'Hardware interface',
      'CAN Actuator',
      'CAN Sensor',
      'RS 485',
      'Controller',
      'Localization',
      'Navigation',
      'Mission Manager',
      'Display interface',
      'Display App',
      'Logger',
      'Telemetry',
      'Scheduler',
    ];

    return _buildSimpleTable(
      headers: const ['Module', 'Status'],
      rows: items
          .map((name) => [name, 'ACTIVE'])
          .toList(),
    );
  }

  Widget _buildSimpleTable({
    required List<String> headers,
    required List<List<String>> rows,
  }) {
    final isStatusTable = headers.length == 2 && headers[1] == 'Status';

    return Column(
      children: [
        Row(
          children: [
            for (int i = 0; i < headers.length; i++)
              Expanded(
                flex: i == 0 ? 3 : 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 4),
                  child: Text(headers[i], style: _headerStyle),
                ),
              ),
          ],
        ),
        Container(
          height: 1,
          color: Colors.white.withOpacity(0.2),
        ),
        for (final row in rows)
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withOpacity(0.08),
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                for (int i = 0; i < headers.length; i++)
                  Expanded(
                    flex: i == 0 ? 3 : 2,
                    child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 2, horizontal: 4),
                      child: Builder(
                        builder: (context) {
                          final text = i < row.length ? row[i] : '';
                          TextStyle style = _cellStyle;

                          if (isStatusTable && i == 1) {
                            final upper = text.toUpperCase();
                            if (upper == 'ACTIVE') {
                              style = style.copyWith(color: Colors.greenAccent);
                            } else if (upper.contains('NOT') || upper.contains('INACTIVE')) {
                              style = style.copyWith(color: Colors.redAccent);
                            }
                          }

                          return Text(
                            text,
                            style: style,
                            overflow: TextOverflow.ellipsis,
                          );
                        },
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
