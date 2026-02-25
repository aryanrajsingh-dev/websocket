import 'dart:typed_data';
import 'models/telemetry_packet.dart';

class BinaryCodec {
  BinaryCodec._();

  static Map<String, dynamic> parseBinary(Uint8List bytes) {
    if (bytes.isEmpty) {
      return {'type': 'error', 'error': 'empty'};
    }

    try {
      final packet = TelemetryPacket.fromBytes(bytes);
      return {
        'type': 'data',
        'systemStatus': packet.systemStatus,
        'connectionState': packet.connectionState,
        'activeMode': packet.activeMode,
        'cpuUsage': packet.cpuUsage,
        'memoryUsage': packet.memoryUsage,
      };
    } catch (e, stack) {
      return {
        'type': 'error',
        'error': 'parse_failed',
        'details': e.toString(),
        'stackTrace': stack.toString(),
      };
    }
  }

  static TelemetryPacket parsePacket(Uint8List bytes) {
    if (bytes.isEmpty) {
      throw ArgumentError('Cannot parse empty byte array');
    }

    return TelemetryPacket.fromBytes(bytes);
  }
}