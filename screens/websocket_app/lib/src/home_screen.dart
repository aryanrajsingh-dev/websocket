import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'models/screen_dto.dart';
import 'ws_service.dart';
import 'data_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final WebSocketService _ws = WebSocketService();
  List<ScreenDto> _screens = [];
  TabController? _tabs;
  String? _errorMessage;
  String _wsUrl = 'ws://localhost:8080';

  @override
  void initState() {
    super.initState();
    _init();
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
    // Single-screen mode: server will push data for the single screen.
    setState(() {
      _screens = [ScreenDto(screenId: '1', title: 'System Status')];
    });
  }

  // single-screen mode: no tab or screen request helpers needed

  @override
  void dispose() {
    if (_tabs != null) {
      _tabs!.dispose();
    }
    _ws.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasTabs = _tabs != null;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Screens'),
        bottom: hasTabs ? TabBar(controller: _tabs, tabs: _screens.map((s) => Tab(text: s.title)).toList()) : null,
      ),
      backgroundColor: Colors.lightBlue[50],
      body: _errorMessage != null
          ? Center(child: Text(_errorMessage!, style: const TextStyle(fontSize: 16, color: Colors.red)))
          : (_screens.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : (hasTabs
                  ? TabBarView(controller: _tabs, children: _screens.map((s) => DataView(stream: _ws.rawStream)).toList())
                  : DataView(stream: _ws.rawStream))),
    );
  }
}
