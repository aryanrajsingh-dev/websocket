const telemetry = {
  KEYS: {
    CPU_USAGE: 'cpuUsage',
    MEMORY_USAGE: 'memoryUsage',
    TEMPERATURE: 'temperature',
    SOFTWARE_VERSION: 'softwareVersion',
  },
  createPayload() {
    return {
      [this.KEYS.CPU_USAGE]: Math.floor(Math.random() * 101),
      [this.KEYS.MEMORY_USAGE]: Math.floor(Math.random() * 101),
      [this.KEYS.TEMPERATURE]: (Math.floor(Math.random() * 40) + 30) + '\u00b0C',
      [this.KEYS.SOFTWARE_VERSION]: 'v1.2.4-stable',
    };
  },
};

module.exports = telemetry;
