import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dialect.dart';
import 'parser.dart';


class WebSocketService {
  late RawDatagramSocket _socket;
  late final Stream<Map<String, dynamic>> rawStream;
  late final StreamController<Map<String, dynamic>> _ctrl;
  InternetAddress? _serverAddress;
  int _serverPort = 8080;
  late final TelemetryStreamParser _mavParser;

  WebSocketService() : _ctrl = StreamController<Map<String, dynamic>>() {
    rawStream = _ctrl.stream.asBroadcastStream();

    final dialect = DefaultTelemetryDialect(
      telemetryMessageId: 1,
    );
    _mavParser = TelemetryStreamParser(dialect);

    _mavParser.stream.listen((frame) {
      final packet = frame.packet;
      _ctrl.add({
        'type': 'data',
        'cpuUsage': packet.cpuUsage,
        'memoryUsage': packet.memoryUsage,
        'temperature': packet.temperature,
        'softwareVersion': packet.softwareVersion,
      });
    });
  }

  Future<void> connect(String wsUrl) async {
    final uri = Uri.parse(wsUrl.replaceFirst('ws://', 'udp://').replaceFirst('wss://', 'udp://'));
    _serverPort = uri.hasPort ? uri.port : 8080;
    try {
      final addrs = await InternetAddress.lookup(uri.host);
      final ipv4 = addrs.firstWhere((a) => a.type == InternetAddressType.IPv4, orElse: () => addrs.first);
      _serverAddress = ipv4;
    } catch (e) {
      _serverAddress = uri.host == 'localhost' ? InternetAddress.loopbackIPv4 : InternetAddress(uri.host);
    }

    _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    _socket.listen((event) {
      if (event == RawSocketEvent.read) {
        final dg = _socket.receive();
        if (dg == null) return;
        final data = Uint8List.fromList(dg.data);
        _mavParser.parse(data);
        print('[UDPSvc] recv from ${dg.address}:${dg.port} -> ${data.length} bytes');
      }
    });

    sendRegister();
  }

  void sendRegister() {
    if (_serverAddress == null) return;
    final buf = Uint8List.fromList([0]);
    _socket.send(buf, _serverAddress!, _serverPort);
    print('[UDPSvc] sent BINARY REGISTER -> ${_serverAddress}:${_serverPort}');
  }

  void dispose() {
    try { _socket.close(); } catch (_) {}
    try { _ctrl.close(); } catch (_) {}
  }
}
