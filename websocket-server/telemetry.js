const telemetry = {
  KEYS: {
    SYSTEM_STATUS: 'systemStatus',
    CONNECTION_STATE: 'connectionState',
    ACTIVE_MODE: 'activeMode',
    CPU_USAGE: 'cpuUsage',
    MEMORY_USAGE: 'memoryUsage',
  },
  VALUES: {
    SYSTEM_STATUS: ['ONLINE', 'IDLE'],
    CONNECTION_STATE: ['CONNECTED'],
    ACTIVE_MODE: ['AUTO', 'MANUAL'],
  },
  createPayload() {
    return {
      [this.KEYS.SYSTEM_STATUS]: Math.random() > 0.5 ? 'ONLINE' : 'IDLE',
      [this.KEYS.CONNECTION_STATE]: 'CONNECTED',
      [this.KEYS.ACTIVE_MODE]: Math.random() > 0.5 ? 'AUTO' : 'MANUAL',
      [this.KEYS.CPU_USAGE]: Math.floor(Math.random() * 100) + '%',
      [this.KEYS.MEMORY_USAGE]: Math.floor(Math.random() * 100) + '%',
    };
  },
};

module.exports = telemetry;
