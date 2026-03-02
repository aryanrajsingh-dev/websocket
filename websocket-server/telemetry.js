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
      [this.KEYS.CPU_USAGE]: Math.floor(Math.random() * 100) + '%',
      [this.KEYS.MEMORY_USAGE]: Math.floor(Math.random() * 100) + '%',
      [this.KEYS.INTERNAL_TEMP]: (Math.floor(Math.random() * 40) + 30) + '°C',
      [this.KEYS.IP_ADDRESS]: ipAddress,
      [this.KEYS.STORAGE_PERCENT]: Math.floor(Math.random() * 100),
      [this.KEYS.FIRMWARE_VERSION]: 'v1.2.4-stable',
      [this.KEYS.SIGNAL_STRENGTH]: -(Math.floor(Math.random() * 50) + 40),
      [this.KEYS.LATENCY]: latencyMs + 'ms',
    };
  },
};

module.exports = telemetry;
