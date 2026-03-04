const telemetry = {
  KEYS: {
    SYSTEM_STATUS: 'systemStatus',
    CONNECTION_STATE: 'connectionState',
    ACTIVE_MODE: 'activeMode',
    CPU_USAGE: 'cpuUsage',
    MEMORY_USAGE: 'memoryUsage',
    INTERNAL_TEMP: 'internalTemp',
    IP_ADDRESS: 'ipAddress',
    STORAGE_PERCENT: 'storagePercent',
    FIRMWARE_VERSION: 'firmwareVersion',
    SIGNAL_STRENGTH: 'signalStrength',
    LATENCY: 'latency',
  },
  VALUES: {
    SYSTEM_STATUS: ['ONLINE', 'IDLE'],
    CONNECTION_STATE: ['CONNECTED'],
    ACTIVE_MODE: ['AUTO', 'MANUAL'],
  },
  createPayload() {
    const latencyMs = Math.floor(Math.random() * 80) + 20;
    const ipAddress = '192.168.' + Math.floor(Math.random() * 255) + '.' + Math.floor(Math.random() * 255);

    return {
      [this.KEYS.SYSTEM_STATUS]: Math.random() > 0.5 ? 'ONLINE' : 'IDLE',
      [this.KEYS.CONNECTION_STATE]: 'CONNECTED',
      [this.KEYS.ACTIVE_MODE]: Math.random() > 0.5 ? 'AUTO' : 'MANUAL',
      // Numeric percentages to match COMPUTE telemetry spec (0-100)
      [this.KEYS.CPU_USAGE]: Math.floor(Math.random() * 101),
      [this.KEYS.MEMORY_USAGE]: Math.floor(Math.random() * 101),
      // Temperature as human-readable string
      [this.KEYS.INTERNAL_TEMP]: (Math.floor(Math.random() * 40) + 30) + '\u00b0C',
      [this.KEYS.IP_ADDRESS]: ipAddress,
      [this.KEYS.STORAGE_PERCENT]: Math.floor(Math.random() * 101),
      [this.KEYS.FIRMWARE_VERSION]: 'v1.2.4-stable',
      // WiFi signal strength in dBm (e.g. -45 to -95)
      [this.KEYS.SIGNAL_STRENGTH]: -(Math.floor(Math.random() * 51) + 45),
      // Latency in ms (numeric); the UI can format this if needed
      [this.KEYS.LATENCY]: latencyMs,
    };
  },
};

module.exports = telemetry;
