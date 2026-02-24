import 'dart:convert';
import 'package:flutter/material.dart';
import 'models/data_dto.dart';

class DataView extends StatelessWidget {
  final Stream<Map<String, dynamic>> stream;
  const DataView({super.key, required this.stream});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(stream: stream, builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }
      final dataMap = snapshot.data!;
      // debug: show any non-data messages as well
      debugPrint('DataView: snapshot -> $dataMap');
      if (dataMap['type'] != 'data') return Center(child: Text('No data yet (received: ${dataMap['type']})'));
      final dto = DataDto.fromJson(dataMap);

      debugPrint('Received live data');

      final items = dto.payload.entries.map<Widget>((e) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            child: Text('${e.key}: ${e.value}', style: const TextStyle(fontSize: 16)),
          )).toList();

      return ListView(padding: const EdgeInsets.all(16), children: items);
    });
  }
}
