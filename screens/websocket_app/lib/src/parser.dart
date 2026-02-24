import 'dart:typed_data';
import 'binary_codec.dart';

class MessageParser {
  MessageParser._();

  /// Parse incoming binary data
  static Map<String, dynamic> parse(Uint8List data) {
    try {
      return BinaryCodec.parseBinary(data);
    } catch (e) {
      return {'type': 'error', 'error': 'unparseable', 'details': e.toString()};
    }
  }
}
