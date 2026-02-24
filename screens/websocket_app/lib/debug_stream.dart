import 'src/ws_service.dart';
import 'dart:async';

void main() async {
  final service = WebSocketService();
  
  int eventCount = 0;
  service.rawStream.listen(
    (data) {
      eventCount++;
      print('\n[Event #$eventCount] ${DateTime.now()}');
      print('  Type: ${data['type']}');
      print('  Data: $data');
      if (data.containsKey('systemStatus')) {
        print('  └─ System Status: ${data['systemStatus']}');
      }
      if (data.containsKey('connectionState')) {
        print('  └─ Connection State: ${data['connectionState']}');
      }
      if (data.containsKey('cpuUsage')) {
        print('  └─ CPU Usage: ${data['cpuUsage']}');
      }
    },
    onError: (e) => print('❌ Error: $e'),
    onDone: () => print('✅ Stream closed'),
  );

  await service.connect('ws://localhost:8080');
  print('🚀 Connected! Watching streams...\n');
  await Future.delayed(Duration(minutes: 10));
  service.dispose();
}
