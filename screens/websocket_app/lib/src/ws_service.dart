import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'parser.dart';

class WebSocketService {
  late RawDatagramSocket _socket;
  late final Stream<Map<String, dynamic>> rawStream;
  late StreamController<Map<String, dynamic>> _ctrl;
  InternetAddress? _serverAddress;
  int _serverPort = 8080;

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

    _ctrl = StreamController<Map<String, dynamic>>();
    rawStream = _ctrl.stream.asBroadcastStream();

    _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    _socket.listen((event) {
      if (event == RawSocketEvent.read) {
        final dg = _socket.receive();
        if (dg == null) return;
        final data = dg.data;
        final parsed = MessageParser.parse(Uint8List.fromList(data));
        print('[UDPSvc] recv from ${dg.address}:${dg.port} -> ${parsed}');
        _ctrl.add(parsed);
      }
    });

    // auto-register so server knows where to send pushes
    sendRegister();
  }

  void sendRegister() {
    if (_serverAddress == null) return;
    final buf = Uint8List.fromList([0]);
    _socket.send(buf, _serverAddress!, _serverPort);
    print('[UDPSvc] sent BINARY REGISTER -> ${_serverAddress}:${_serverPort}');
  }

  void sendDiscovery() {
    return;
  }

  void requestScreen(String screenId) {
    return;
  }

  void dispose() {
    try { _socket.close(); } catch (_) {}
    try { _ctrl.close(); } catch (_) {}
  }
}
