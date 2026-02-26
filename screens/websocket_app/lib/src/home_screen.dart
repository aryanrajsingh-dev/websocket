import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'models/screen_dto.dart';
import 'ws_service.dart';
import 'widgets/top_header.dart';
import 'widgets/left_sidebar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WebSocketService _ws = WebSocketService();
  String _wsUrl = 'ws://localhost:8080';
  String _selectedMenu = 'SYS';
  String _mode = 'SAFE HOLD';
  Duration _upTime = const Duration(hours: 0, minutes: 2, seconds: 17);
  bool _wifiConnected = true;
  double _batteryLevel = 0.15;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _init();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _upTime += const Duration(seconds: 1);
      });
    });
  }

  Future<void> _init() async {
    try {
      final raw = await rootBundle.loadString('assets/config.json');
      final cfg = jsonDecode(raw) as Map<String, dynamic>;
      if (cfg['wsUrl'] is String) _wsUrl = cfg['wsUrl'] as String;
    } catch (e) {
      debugPrint('Failed to load config asset: $e');
    }
    await _ws.connect(_wsUrl);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ws.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          TopHeader(
            mode: _mode,
            upTime: _upTime,
            wifiConnected: _wifiConnected,
            batteryLevel: _batteryLevel,
          ),
          Expanded(
            child: Row(
              children: [
                LeftSidebar(
                  selectedMenu: _selectedMenu,
                  onMenuSelected: (menu) {
                    setState(() {
                      _selectedMenu = menu;
                    });
                  },
                ),
                Expanded(
                  child: _buildMainContent(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Text(
          '$_selectedMenu Screen',
          style: const TextStyle(
            color: Colors.cyan,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
