import 'models/telemetry_packet.dart';

enum TelemetryProtocolVersion { v1, v2 }

class TelemetryFrame {
  final TelemetryProtocolVersion version;
  final int sequence;
  final int systemId;
  final int componentId;
  final int messageId;
  final TelemetryPacket packet;

  const TelemetryFrame(
    this.version,
    this.sequence,
    this.systemId,
    this.componentId,
    this.messageId,
    this.packet,
  );
}
