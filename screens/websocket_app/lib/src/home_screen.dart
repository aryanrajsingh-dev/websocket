import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'widgets/left_sidebar.dart';
import 'widgets/top_header.dart';
import 'widgets/star_field_painter.dart';
import 'widgets/cpu_card.dart';
import 'widgets/memory_card.dart';
import 'models/display_model.dart';
import '../src/ws_service.dart';
import 'widgets/compute_details_panel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> {
  String _selectedMenu = 'COMPUTE';

  DisplayModel? _displayModel;
  late final WebSocketService _wsService;
  StreamSubscription<Map<String, dynamic>>? _wsSub;

  Duration _upTime = Duration.zero;
  Timer? _upTimeTimer;
  double _batteryLevel = 0.85;

  @override
  void initState() {
    super.initState();
    _startUpTime();
    _wsService = WebSocketService();
    final host = Platform.isAndroid ? '10.0.2.2' : 'localhost';
    _wsService.connect('ws://$host:8080');
    _wsSub = _wsService.rawStream.listen((msg) {
      if (msg['type'] == 'data') {
        setState(() {
          _displayModel = DisplayModel(
            cpuUsage: msg['cpuUsage'] ?? 0,
            memoryUsage: msg['memoryUsage'] ?? 0,
            temperature: msg['temperature'] ?? '',
            softwareVersion: msg['softwareVersion'] ?? '',
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
        if (_upTime.inSeconds > 0 && _upTime.inSeconds % (4 * 60) == 0) {
          _batteryLevel = (_batteryLevel - 0.02).clamp(0.0, 1.0);
        }
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
          Builder(
            builder: (context) {
              final width = MediaQuery.of(context).size.width;
              final isSmallScreen = width < 700;
              final isCompute = _selectedMenu == 'COMPUTE';
              final useRowLayout = isCompute || !isSmallScreen;

              return Column(
                children: [
                  TopHeader(
                    upTime: _upTime,
                    wifiConnected: true,
                    batteryLevel: _batteryLevel,
                  ),
                  Expanded(
                    child: useRowLayout
                        ? Row(
                            children: [
                              SizedBox(
                                width: 100,
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
                                child: Padding(
								  padding: const EdgeInsets.fromLTRB(
									  12, 4, 12, 14),
                                  child: SingleChildScrollView(
                                    child: _buildDashboardGrid(true),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : SingleChildScrollView(
                            padding:
                                const EdgeInsets.fromLTRB(24, 0, 24, 24),
                            child: _buildDashboardGrid(false),
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

  Widget _buildDashboardGrid(bool isDesktopWidth) {
    return _buildComputeDashboard(isDesktopWidth);
  }

  Widget _buildComputeDashboard(bool isDesktopWidth) {
    final computePanel = ComputeDetailsPanel(displayModel: _displayModel);

    final cpuCard = CpuCard(cpuUsage: _displayModel?.cpuUsage ?? 0);
    final memoryCard = MemoryCard(memoryUsage: _displayModel?.memoryUsage ?? 0);

    if (isDesktopWidth) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: computePanel,
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                cpuCard,
                const SizedBox(height: 8),
                memoryCard,
                const SizedBox(height: 4),
                _buildSoftwareAndTempRow(),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        computePanel,
        const SizedBox(height: 16),
        cpuCard,
        const SizedBox(height: 12),
        memoryCard,
        const SizedBox(height: 8),
        _buildSoftwareAndTempRow(),
      ],
    );
  }

  Widget _buildSoftwareAndTempRow() {
    final softwareVersionText = _displayModel?.softwareVersion.isNotEmpty == true
        ? _displayModel!.softwareVersion
        : 'v1.2.4-stable';
    final temp = _displayModel?.temperature.isNotEmpty == true
      ? _displayModel!.temperature
        : 'N/A';

    const labelStyle = TextStyle(
      color: Colors.white70,
      fontSize: 11,
      fontWeight: FontWeight.w600,
    );
    const valueStyle = TextStyle(
      color: Colors.white,
      fontSize: 11,
      fontWeight: FontWeight.w500,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Software Version', style: labelStyle),
            Flexible(
              child: Text(
                softwareVersionText,
                style: valueStyle,
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Temperature', style: labelStyle),
            Text(
              temp,
              style: valueStyle,
            ),
          ],
        ),
      ],
    );
  }
}