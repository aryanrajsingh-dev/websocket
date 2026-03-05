import 'dart:async';
import 'dart:typed_data';

import 'dialect.dart';
import 'frame.dart';

enum _ParserState {
  init,
  waitPayloadLength,
  waitIncompatibilityFlags,
  waitCompatibilityFlags,
  waitPacketSequence,
  waitSystemId,
  waitComponentId,
  waitMessageIdLow,
  waitMessageIdMiddle,
  waitMessageIdHigh,
  waitPayloadEnd,
  waitCrcLowByte,
  waitCrcHighByte,
}

class TelemetryStreamParser {
  static const int _mavlinkMaximumPayloadSize = 255;
  static const int _mavlinkIflagSigned = 0x01;

  static const int mavlinkStxV1 = 0xFE;
  static const int mavlinkStxV2 = 0xFD;

  final TelemetryDialect _dialect;
  final _streamController = StreamController<TelemetryFrame>();

  _ParserState _state = _ParserState.init;

  TelemetryProtocolVersion _version = TelemetryProtocolVersion.v1;
  int _payloadLength = -1;
  int _incompatibilityFlags = -1;
  int _compatibilityFlags = -1;
  int _sequence = -1;
  int _systemId = -1;
  int _componentId = -1;
  int _messageIdLow = -1;
  int _messageIdMiddle = -1;
  int _messageIdHigh = -1;
  int _messageId = -1;
  final Uint8List _payload = Uint8List(_mavlinkMaximumPayloadSize);
  int _payloadCursor = -1;
  int _crcLowByte = -1;
  int _crcHighByte = -1;

  TelemetryStreamParser(this._dialect);

  void _resetContext() {
    _version = TelemetryProtocolVersion.v1;
    _payloadLength = -1;
    _incompatibilityFlags = -1;
    _compatibilityFlags = -1;
    _sequence = -1;
    _systemId = -1;
    _componentId = -1;
    _messageIdLow = -1;
    _messageIdMiddle = -1;
    _messageIdHigh = -1;
    _messageId = -1;
    _payloadCursor = -1;
    _crcLowByte = -1;
    _crcHighByte = -1;
  }

  void parse(Uint8List data) {
    for (final value in data) {
      final d = value & 0xFF;
      switch (_state) {
        case _ParserState.init:
          switch (d) {
            case mavlinkStxV1:
              _version = TelemetryProtocolVersion.v1;
              _state = _ParserState.waitPayloadLength;
              break;
            case mavlinkStxV2:
              _version = TelemetryProtocolVersion.v2;
              _state = _ParserState.waitPayloadLength;
              break;
            default:
              break;
          }
          break;

        case _ParserState.waitPayloadLength:
          _payloadLength = d;
          if (_payloadLength < 0 || _payloadLength > _mavlinkMaximumPayloadSize) {
            _resetContext();
            _state = _ParserState.init;
            break;
          }
          if (_version == TelemetryProtocolVersion.v1) {
            _state = _ParserState.waitPacketSequence;
          } else {
            _state = _ParserState.waitIncompatibilityFlags;
          }
          break;

        case _ParserState.waitIncompatibilityFlags:
          _incompatibilityFlags = d;
          _state = _ParserState.waitCompatibilityFlags;
          break;

        case _ParserState.waitCompatibilityFlags:
          _compatibilityFlags = d;
          _state = _ParserState.waitPacketSequence;
          break;

        case _ParserState.waitPacketSequence:
          _sequence = d;
          _state = _ParserState.waitSystemId;
          break;

        case _ParserState.waitSystemId:
          _systemId = d;
          _state = _ParserState.waitComponentId;
          break;

        case _ParserState.waitComponentId:
          _componentId = d;
          if (_version == TelemetryProtocolVersion.v1) {
            _state = _ParserState.waitMessageIdHigh;
          } else {
            _state = _ParserState.waitMessageIdLow;
          }
          break;

        case _ParserState.waitMessageIdLow:
          _messageIdLow = d;
          _state = _ParserState.waitMessageIdMiddle;
          break;

        case _ParserState.waitMessageIdMiddle:
          _messageIdMiddle = d;
          _state = _ParserState.waitMessageIdHigh;
          break;

        case _ParserState.waitMessageIdHigh:
          if (_version == TelemetryProtocolVersion.v1) {
            _messageId = d;
          } else {
            _messageIdHigh = d;
            _messageId = (_messageIdHigh << 16) | (_messageIdMiddle << 8) | _messageIdLow;
          }

          if (_payloadLength == 0) {
            _state = _ParserState.waitCrcLowByte;
          } else {
            _state = _ParserState.waitPayloadEnd;
            _payloadCursor = 0;
          }
          break;

        case _ParserState.waitPayloadEnd:
          if (_payloadCursor >= 0 && _payloadCursor < _payloadLength) {
            _payload[_payloadCursor++] = d;
          }

          if (_payloadCursor == _payloadLength) {
            _state = _ParserState.waitCrcLowByte;
          }
          break;

        case _ParserState.waitCrcLowByte:
          _crcLowByte = d;
          _state = _ParserState.waitCrcHighByte;
          break;

        case _ParserState.waitCrcHighByte:
          _crcHighByte = d;

          if (_version == TelemetryProtocolVersion.v2 &&
              (_incompatibilityFlags & _mavlinkIflagSigned) == _mavlinkIflagSigned) {
            _resetContext();
            _state = _ParserState.init;
            break;
          }

          _addTelemetryFrameToStream();

          _resetContext();
          _state = _ParserState.init;
          break;
      }
    }
  }

  bool _addTelemetryFrameToStream() {
    final message = _dialect.parse(
      _messageId,
      _payload.buffer.asByteData(0, _payloadLength),
    );

    if (message == null) {
      return false;
    }

    final frame = TelemetryFrame(
      _version,
      _sequence,
      _systemId,
      _componentId,
      _messageId,
      message,
    );
    _streamController.add(frame);
    return true;
  }

  Stream<TelemetryFrame> get stream => _streamController.stream;
}
