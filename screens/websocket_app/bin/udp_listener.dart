import 'dart:async';
import 'dart:io';
import 'package:websocket_app/src/ws_service.dart';
import 'package:websocket_app/src/parser.dart';
import 'package:websocket_app/src/models/telemetry_packet.dart';

Future<void> main(List<String> args) async {
  final url = args.isNotEmpty ? args.first : 'ws://localhost:8080';
  final service = WebSocketService();
  await service.connect(url);

  print('Listening on $url. Press Ctrl+C to stop.\n');

  final sub = service.rawStream.listen((msg) {
  }, onError: (error) {
    print('Error: $error');
  });

  final done = Completer<void>();
  ProcessSignal.sigint.watch().listen((_) async {
    await sub.cancel();
    service.dispose();
    done.complete();
  });

  await done.future;
}

void _handleTypedMessage(Map<String, dynamic> msg) {
  try {
    if (msg['type'] == 'data') {
      print('[Telemetry]');
      print('  System Status: ${msg['systemStatus']}');
      print('  Connection: ${msg['connectionState']}');
      print('  Mode: ${msg['activeMode']}');
      print('  CPU: ${msg['cpuUsage']}');
    }
  print('');
