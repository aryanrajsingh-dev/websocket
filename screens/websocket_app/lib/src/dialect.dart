import 'dart:typed_data';

import 'models/telemetry_packet.dart';

abstract class TelemetryDialect {
  TelemetryPacket? parse(int messageId, ByteData payload);
}

class DefaultTelemetryDialect implements TelemetryDialect {
  final int telemetryMessageId;

  const DefaultTelemetryDialect({
    required this.telemetryMessageId,
  });

  @override
  TelemetryPacket? parse(int messageId, ByteData payload) {
    if (messageId != telemetryMessageId) {
      return null;
    }
    final bytes = Uint8List.view(
      payload.buffer,
      payload.offsetInBytes,
      payload.lengthInBytes,
    );
    return TelemetryPacket.fromBytes(bytes);
  }
}
