import 'dart:typed_data';
import 'binary_codec.dart';
import 'models/telemetry_packet.dart';

class MessageParser {
  MessageParser._();

  static Map<String, dynamic> parse(Uint8List data) {
    try {
      return BinaryCodec.parseBinary(data);
    } catch (e) {
      return {'type': 'error', 'error': 'unparseable', 'details': e.toString()};
    }
  }

  static TelemetryPacket parseTyped(Uint8List data) {
    if (data.isEmpty) {
      throw ArgumentError('Cannot parse empty data');
    }
    return BinaryCodec.parsePacket(data);
  }
}
