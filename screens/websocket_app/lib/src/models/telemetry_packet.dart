import 'dart:convert';
import 'dart:typed_data';

class TelemetryPacket {
  final String systemStatus;
  final String connectionState;
  final String activeMode;
  final int cpuUsage;
  final int memoryUsage;

  const TelemetryPacket({
    required this.systemStatus,
    required this.connectionState,
    required this.activeMode,
    required this.cpuUsage,
    required this.memoryUsage,
  });

  factory TelemetryPacket.fromBytes(Uint8List bytes) {
    if (bytes.isEmpty || bytes.length < 7) {
      throw ArgumentError('Invalid packet size: ${bytes.length} (expected 7)');
    }

    final data = ByteData.sublistView(bytes);

    final headerByte = data.getUint8(0);
    final statusCode = (headerByte >> 2) & 0x03;
    final connCode = headerByte & 0x03;
    
    final systemStatus = _decodeStatus(statusCode);
    final connectionState = _decodeConnection(connCode);

    final modeValue = data.getUint16(1, Endian.big);
    final activeMode = _decodeMode(modeValue);

    final cpuUsage = data.getUint16(3, Endian.big);
    final memoryUsage = data.getUint16(5, Endian.big);

    return TelemetryPacket(
      systemStatus: systemStatus,
      connectionState: connectionState,
      activeMode: activeMode,
      cpuUsage: cpuUsage,
      memoryUsage: memoryUsage,
    );
  }

  static String _decodeStatus(int code) {
    switch (code) {
      case 1:
        return 'IDLE';
      case 2:
        return 'ONLINE';
      default:
        return 'UNKNOWN';
    }
  }

  static String _decodeConnection(int code) {
    switch (code) {
      case 1:
        return 'CONNECTED';
      default:
        return 'UNKNOWN';
    }
  }

  static String _decodeMode(int code) {
    switch (code) {
      case 0:
        return 'MANUAL';
      case 1:
        return 'AUTO';
      default:
        return 'UNKNOWN';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'systemStatus': systemStatus,
      'connectionState': connectionState,
      'activeMode': activeMode,
      'cpuUsage': cpuUsage,
      'memoryUsage': memoryUsage,
    };
  }

  @override
  String toString() {
    return 'TelemetryPacket(status: $systemStatus, conn: $connectionState, '
           'mode: $activeMode, cpu: $cpuUsage%, mem: $memoryUsage%)';
  }
}