import 'dart:async';
import 'package:flutter/material.dart';
import 'widgets/left_sidebar.dart';
import 'widgets/network_details_box.dart';
import 'widgets/top_header.dart';
import 'widgets/storage_status_box.dart';
import 'widgets/system_status_box.dart';
import 'widgets/cpu_usage_card.dart';
import 'widgets/memory_usage_bar.dart';
import 'widgets/star_field_painter.dart';
import 'models/display_model.dart';
import '../src/ws_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> {
  String _selectedMenu = 'SYS';

  DisplayModel? _displayModel;
  late final WebSocketService _wsService;
  StreamSubscription<Map<String, dynamic>>? _wsSub;

  Duration _upTime = Duration.zero;
  Timer? _upTimeTimer;

  @override
  void initState() {
    super.initState();
    _startUpTime();
    _wsService = WebSocketService();
    _wsService.connect('ws://localhost:8080');
    _wsSub = _wsService.rawStream.listen((msg) {
      if (msg['type'] == 'data') {
        setState(() {
          _displayModel = DisplayModel(
            ipAddress: msg['ipAddress'] ?? '',
            signalStrength: msg['signalStrength'] ?? 0,
            storagePercent: msg['storagePercent'] ?? 0,
            systemStatus: msg['systemStatus'] ?? '',
            connectionState: msg['connectionState'] ?? '',
            activeMode: msg['activeMode'] ?? '',
            firmwareVersion: msg['firmwareVersion'] ?? '',
            internalTemp: msg['internalTemp'] ?? '',
            cpuUsage: msg['cpuUsage'] ?? 0,
            memoryUsage: msg['memoryUsage'] ?? 0,
          );
        });
      }
    });
  }

  void _startUpTime() {
    _upTime = Duration.zero;
    _upTimeTimer?.cancel();
    _upTimeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _upTime += const Duration(seconds: 1);
      });
    });
  }
  @override
  void dispose() {
    _wsSub?.cancel();
    _wsService.dispose();
    _upTimeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0A0F1A),
                  Color(0xFF1B2233),
                  Color(0xFF232A3D),
                ],
              ),
            ),
          ),
          CustomPaint(
            painter: StarFieldPainter(),
            child: Container(),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmallScreen = constraints.maxWidth < 600;
              return Column(
                children: [
                  TopHeader(
                    upTime: _upTime,
                    wifiConnected: true,
                    batteryLevel: 0.85,
                  ),
                  Expanded(
                    child: isSmallScreen
                        ? SingleChildScrollView(
                            child: _buildMainContent(),
                          )
                        : Row(
                            children: [
                              SizedBox(
                                width: 200,
                                child: LeftSidebar(
                                  selectedMenu: _selectedMenu,
                                  onMenuSelected: (menu) {
                                    setState(() {
                                      _selectedMenu = menu;
                                    });
                                  },
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.blueAccent
                                            .withOpacity(0.3),
                                        blurRadius: 16,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                    border: Border.all(
                                      color: Colors.blueAccent
                                          .withOpacity(0.5),
                                      width: 2,
                                    ),
                                  ),
                                  child: _buildMainContent(),
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    if (_selectedMenu != 'SYS') {
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

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(
                flex: 2,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildSystemStatusBox(),
                      
                      const SizedBox(height: 20),
                      CpuUsageCard(displayModel: _displayModel),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Flexible(
                flex: 3,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            flex: 1,
                            child: NetworkDetailsBox(
                                ipAddress: _displayModel?.ipAddress ?? '',
                                signalStrength:
                                  _displayModel?.signalStrength ?? 0,
                              latency: '45ms',
                            ),
                          ),
                          const SizedBox(width: 20),
                          Flexible(
                            flex: 1,
                            child: StorageStatusBox(
                                storagePercent:
                                  _displayModel?.storagePercent ?? 0,
                              diskUsedGB: '128',
                              diskTotalGB: '256',
                              writeSpeedMBs: '450',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      MemoryUsageBar(displayModel: _displayModel),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSystemStatusBox() {
    return SystemStatusBox(displayModel: _displayModel);
  }
}