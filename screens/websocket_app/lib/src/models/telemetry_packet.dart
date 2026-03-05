import 'dart:convert';
import 'dart:typed_data';

class TelemetryPacket {
  final int cpuUsage;
  final int memoryUsage;
  final String temperature;
  final String softwareVersion;

  const TelemetryPacket({
    required this.cpuUsage,
    required this.memoryUsage,
    required this.temperature,
    required this.softwareVersion,
  });

  factory TelemetryPacket.fromBytes(Uint8List bytes) {
    if (bytes.isEmpty || bytes.length < 7) {
      throw ArgumentError('Invalid packet size: ${bytes.length} (expected minimum 7)');
    }

    final data = ByteData.sublistView(bytes);

    final cpuUsage = data.getUint16(3, Endian.big);
    final memoryUsage = data.getUint16(5, Endian.big);

    String temperature = 'N/A';
    String softwareVersion = 'N/A';

    if (bytes.length >= 9) {
      int offset = 9;

      if (offset < bytes.length) {
        final tempLen = data.getUint8(offset);
        offset += 1;
        if (offset + tempLen <= bytes.length) {
          temperature = utf8.decode(bytes.sublist(offset, offset + tempLen));
          offset += tempLen;
        }
      }

      if (offset < bytes.length) {
        final ipLen = data.getUint8(offset);
        offset += 1;
        if (offset + ipLen <= bytes.length) {
          offset += ipLen;
        }
      }

      if (offset < bytes.length) {
        final fwLen = data.getUint8(offset);
        offset += 1;
        if (offset + fwLen <= bytes.length) {
          softwareVersion = utf8.decode(bytes.sublist(offset, offset + fwLen));
        }
      }
    }

    return TelemetryPacket(
      cpuUsage: cpuUsage,
      memoryUsage: memoryUsage,
      temperature: temperature,
      softwareVersion: softwareVersion,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cpuUsage': cpuUsage,
      'memoryUsage': memoryUsage,
      'temperature': temperature,
      'softwareVersion': softwareVersion,
    };
  }

  @override
  String toString() {
    return 'TelemetryPacket(cpu: $cpuUsage%, mem: $memoryUsage%, '
        'temp: $temperature, sw: $softwareVersion)';
  }
}