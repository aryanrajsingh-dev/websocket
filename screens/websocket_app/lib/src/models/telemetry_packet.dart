import 'dart:convert';
import 'dart:typed_data';

class TelemetryPacket {
  final String systemStatus;
  final String connectionState;
  final String activeMode;
  final int cpuUsage;
  final int memoryUsage;
  final int storagePercent;
  final String internalTemp;
  final String ipAddress;
  final int signalStrength;
  final String firmwareVersion;

  const TelemetryPacket({
    required this.systemStatus,
    required this.connectionState,
    required this.activeMode,
    required this.cpuUsage,
    required this.memoryUsage,
    required this.storagePercent,
    required this.internalTemp,
    required this.ipAddress,
    required this.signalStrength,
    required this.firmwareVersion,
  });

  factory TelemetryPacket.fromBytes(Uint8List bytes) {
    if (bytes.isEmpty || bytes.length < 7) {
      throw ArgumentError('Invalid packet size: ${bytes.length} (expected minimum 7)');
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

    int storagePercent = 0;
    String internalTemp = 'N/A';
    String ipAddress = 'N/A';
    int signalStrength = -100;
    String firmwareVersion = 'N/A';

    if (bytes.length >= 9) {
      storagePercent = data.getUint8(7);
      signalStrength = data.getInt8(8);

      int offset = 9;
      
      if (offset < bytes.length) {
        final tempLen = data.getUint8(offset);
        offset += 1;
        if (offset + tempLen <= bytes.length) {
          internalTemp = utf8.decode(bytes.sublist(offset, offset + tempLen));
          offset += tempLen;
        }
      }

      if (offset < bytes.length) {
        final ipLen = data.getUint8(offset);
        offset += 1;
        if (offset + ipLen <= bytes.length) {
          ipAddress = utf8.decode(bytes.sublist(offset, offset + ipLen));
          offset += ipLen;
        }
      }

      if (offset < bytes.length) {
        final fwLen = data.getUint8(offset);
        offset += 1;
        if (offset + fwLen <= bytes.length) {
          firmwareVersion = utf8.decode(bytes.sublist(offset, offset + fwLen));
        }
      }
    }

    return TelemetryPacket(
      systemStatus: systemStatus,
      connectionState: connectionState,
      activeMode: activeMode,
      cpuUsage: cpuUsage,
      memoryUsage: memoryUsage,
      storagePercent: storagePercent,
      internalTemp: internalTemp,
      ipAddress: ipAddress,
      signalStrength: signalStrength,
      firmwareVersion: firmwareVersion,
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
      'storagePercent': storagePercent,
      'internalTemp': internalTemp,
      'ipAddress': ipAddress,
      'signalStrength': signalStrength,
      'firmwareVersion': firmwareVersion,
    };
  }

  @override
  String toString() {
    return 'TelemetryPacket(status: $systemStatus, conn: $connectionState, '
           'mode: $activeMode, cpu: $cpuUsage%, mem: $memoryUsage%, '
           'storage: $storagePercent%, temp: $internalTemp, ip: $ipAddress, '
           'signal: $signalStrength dBm, fw: $firmwareVersion)';
  }
}