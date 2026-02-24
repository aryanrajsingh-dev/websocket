import 'dart:typed_data';
import 'dart:convert';

class BinaryCodec {
  BinaryCodec._();

  static Map<String, dynamic> parseBinary(Uint8List bytes) {
    if (bytes.isEmpty) return {'type': 'error', 'error': 'empty'};
    final b = bytes.buffer.asByteData();
    int offset = 0;
    final msgType = b.getUint8(offset);
    offset += 1;
    if (msgType == 1) {
      // screens: [1][count][idLen,id...,titleLen,title...]...
      final count = b.getUint8(offset);
      offset += 1;
      final screens = <Map<String, String>>[];
      for (var i = 0; i < count; i++) {
        final idLen = b.getUint8(offset);
        offset += 1;
        final idBytes = bytes.sublist(offset, offset + idLen);
        offset += idLen;
        final titleLen = b.getUint8(offset);
        offset += 1;
        final titleBytes = bytes.sublist(offset, offset + titleLen);
        offset += titleLen;
        screens.add({'screenId': utf8.decode(idBytes), 'title': utf8.decode(titleBytes)});
      }
      return {'type': 'screens', 'screens': screens};
    } else if (msgType == 2) {
 
      offset += 8;
      
      // Read and skip screen id
      final idLen = b.getUint8(offset);
      offset += 1;
      offset += idLen; // skip the id bytes
      
      // Now read pairs count
      final pairs = b.getUint8(offset);
      offset += 1;
      final Map<String, dynamic> payload = {};
      for (var i = 0; i < pairs; i++) {
        final keyLen = b.getUint8(offset);
        offset += 1;
        final keyBytes = bytes.sublist(offset, offset + keyLen);
        offset += keyLen;
        final key = utf8.decode(keyBytes);
        final valLen = b.getUint16(offset);
        offset += 2;
        final valBytes = bytes.sublist(offset, offset + valLen);
        offset += valLen;
        final valStr = utf8.decode(valBytes);
        // try to parse JSON value, otherwise keep as string
        try {
          payload[key] = jsonDecode(valStr);
        } catch (_) {
          payload[key] = valStr;
        }
      }
      return {'type': 'data', ...payload};
    }
    return {'type': 'error', 'error': 'unknown_type'};
  }
}