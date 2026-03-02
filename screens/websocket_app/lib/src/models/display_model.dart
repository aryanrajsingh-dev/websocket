class DisplayModel {
  final String ipAddress;
  final int signalStrength;
  final int storagePercent;
  final String systemStatus;
  final String connectionState;
  final String activeMode;
  final String firmwareVersion;
  final String internalTemp;
  final int cpuUsage;
  final int memoryUsage;

  const DisplayModel({
    required this.ipAddress,
    required this.signalStrength,
    required this.storagePercent,
    required this.systemStatus,
    required this.connectionState,
    required this.activeMode,
    required this.firmwareVersion,
    required this.internalTemp,
    required this.cpuUsage,
    required this.memoryUsage,
  });
}
