class SystemDisplayModel {
  final String systemStatus;
  final String connectionState;
  final String activeMode;

  final int cpuUsage;
  final int memoryUsage;
  final int storagePercent;

  final String internalTemp;
  final String ipAddress;
  final int signalStrength;
  final String firmwareVersion;

  const SystemDisplayModel({
    required this.systemStatus,
    required this.connectionState,
    required this.activeMode,
    required this.cpuUsage,
    required this.memoryUsage,
    required this.storagePercent,
    required this.internalTemp,
    required this.ipAddress,
    required this.signalStrength,
    required this.firmwareVersion,
  });

  factory SystemDisplayModel.fromTelemetry(Map<String, dynamic> data) {
    return SystemDisplayModel(
      systemStatus: data['systemStatus'] as String? ?? 'UNKNOWN',
      connectionState: data['connectionState'] as String? ?? 'UNKNOWN',
      activeMode: data['activeMode'] as String? ?? 'UNKNOWN',
      cpuUsage: data['cpuUsage'] as int? ?? 0,
      memoryUsage: data['memoryUsage'] as int? ?? 0,
      storagePercent: data['storagePercent'] as int? ?? 0,
      internalTemp: data['internalTemp'] as String? ?? 'N/A',
      ipAddress: data['ipAddress'] as String? ?? 'N/A',
      signalStrength: data['signalStrength'] as int? ?? -100,
      firmwareVersion: data['firmwareVersion'] as String? ?? 'N/A',
    );
  }

  SystemDisplayModel copyWith({
    String? systemStatus,
    String? connectionState,
    String? activeMode,
    int? cpuUsage,
    int? memoryUsage,
    int? storagePercent,
    String? internalTemp,
    String? ipAddress,
    int? signalStrength,
    String? firmwareVersion,
  }) {
    return SystemDisplayModel(
      systemStatus: systemStatus ?? this.systemStatus,
      connectionState: connectionState ?? this.connectionState,
      activeMode: activeMode ?? this.activeMode,
      cpuUsage: cpuUsage ?? this.cpuUsage,
      memoryUsage: memoryUsage ?? this.memoryUsage,
      storagePercent: storagePercent ?? this.storagePercent,
      internalTemp: internalTemp ?? this.internalTemp,
      ipAddress: ipAddress ?? this.ipAddress,
      signalStrength: signalStrength ?? this.signalStrength,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
    );
  }

  @override
  String toString() {
    return 'SystemDisplayModel('
        'status: $systemStatus, conn: $connectionState, mode: $activeMode, '
        'cpu: $cpuUsage%, mem: $memoryUsage%, storage: $storagePercent%, '
        'temp: $internalTemp, ip: $ipAddress, signal: $signalStrength dBm, fw: $firmwareVersion)';
  }
}
