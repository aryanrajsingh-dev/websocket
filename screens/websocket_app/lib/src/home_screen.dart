import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'widgets/left_sidebar.dart';
import 'widgets/network_details_box.dart';
import 'widgets/top_header.dart';
import 'widgets/storage_status_box.dart';
import 'widgets/system_status_box.dart';
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
                    batteryLevel: 0.85,
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
    if (_selectedMenu == 'COMPUTE') {
      return _buildComputeDashboard(isDesktopWidth);
    }

    final systemCard = _buildSystemStatusBox();
    final networkCard = NetworkDetailsBox(
      ipAddress: _displayModel?.ipAddress ?? '',
      signalStrength: _displayModel?.signalStrength ?? 0,
      latency: '45ms',
    );
    final storageCard = StorageStatusBox(
      storagePercent: _displayModel?.storagePercent ?? 0,
      diskUsedGB: '128',
      diskTotalGB: '256',
      writeSpeedMBs: '450',
    );

    Widget topRow;
    if (isDesktopWidth) {
      const double topRowHeight = 210;
      topRow = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: SizedBox(height: topRowHeight, child: systemCard),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 1,
            child: SizedBox(height: topRowHeight, child: networkCard),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 1,
            child: SizedBox(height: topRowHeight, child: storageCard),
          ),
        ],
      );
    } else {
      topRow = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          systemCard,
          const SizedBox(height: 24),
          networkCard,
          const SizedBox(height: 24),
          storageCard,
        ],
      );
    }

    Widget perfRow;
    if (isDesktopWidth) {
      const double bottomRowHeight = 220;
      perfRow = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: SizedBox(
              height: bottomRowHeight,
              child: CpuCard(
                cpuUsage: _displayModel?.cpuUsage ?? 0,
              ),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 6,
            child: SizedBox(
              height: bottomRowHeight,
              child: MemoryCard(
                memoryUsage: _displayModel?.memoryUsage ?? 0,
              ),
            ),
          ),
        ],
      );
    } else {
      perfRow = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CpuCard(
            cpuUsage: _displayModel?.cpuUsage ?? 0,
          ),
          const SizedBox(height: 24),
          MemoryCard(
            memoryUsage: _displayModel?.memoryUsage ?? 0,
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        topRow,
        const SizedBox(height: 24),
        perfRow,
      ],
    );
  }

  Widget _buildSystemStatusBox() {
    return SystemStatusBox(displayModel: _displayModel);
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
    final fw = _displayModel?.firmwareVersion.isNotEmpty == true
        ? _displayModel!.firmwareVersion
        : 'v1.2.4-stable';
    final temp = _displayModel?.internalTemp.isNotEmpty == true
        ? _displayModel!.internalTemp
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
                fw,
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