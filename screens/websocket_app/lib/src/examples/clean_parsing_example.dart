import 'dart:typed_data';
import 'package:websocket_app/src/parser.dart';
import 'package:websocket_app/src/models/telemetry_packet.dart';

void main() {
  final Uint8List incomingData = _simulateServerData();

  print('=== Example 1: Using Typed API (Recommended) ===\n');
  _exampleTypedAPI(incomingData);

  print('\n=== Example 2: Using Legacy Map API (Backwards Compatible) ===\n');
  _exampleLegacyAPI(incomingData);
}

void _exampleTypedAPI(Uint8List data) {
  try {
    final packet = MessageParser.parseTyped(data);

    print('System Status: ${packet.systemStatus}');
    print('Connection: ${packet.connectionState}');
    print('Mode: ${packet.activeMode}');
    print('CPU Usage: ${packet.cpuUsage}%');
    print('Memory Usage: ${packet.memoryUsage}%');
  } catch (e) {
    print('Parse error: $e');
  }
}

void _exampleLegacyAPI(Uint8List data) {
  final result = MessageParser.parse(data);

  if (result['type'] == 'data') {
    print('System Status: ${result['systemStatus']}');
    print('Connection: ${result['connectionState']}');
    print('Mode: ${result['activeMode']}');
    print('CPU: ${result['cpuUsage']}%');
    print('Memory: ${result['memoryUsage']}%');
  } else if (result['type'] == 'error') {
    print('Error: ${result['error']}');
  }
}

Uint8List _simulateServerData() {
  final headerByte = (2 << 2) | 1;
  return Uint8List.fromList([
    headerByte,
    0x00, 0x01,
    0x00, 0x10,
    0x00, 0x32,
  ]);
}
