const cpu = require('./cpu');
const memory = require('./memory');

const telemetry = {
  KEYS: {
    CPU_USAGE: 'cpuUsage',
    MEMORY_USAGE: 'memoryUsage',
    TEMPERATURE: 'temperature',
    SOFTWARE_VERSION: 'softwareVersion',
  },

  recordActivity() {},

  createPayload() {
    const cpuValue = cpu.getCpuUsagePercent();
    const memoryValue = memory.getMemoryUsagePercent();
    const baseTemp = 40;
    const maxTemp = 80;
    const clampedCpu = Math.max(0, Math.min(100, Number.isFinite(cpuValue) ? cpuValue : 0));
    const tempValue = baseTemp + ((maxTemp - baseTemp) * clampedCpu) / 100;
    const temperature = Math.round(tempValue) + '\u00b0C';
    return {
      [this.KEYS.CPU_USAGE]: cpuValue,
      [this.KEYS.MEMORY_USAGE]: memoryValue,
      [this.KEYS.TEMPERATURE]: temperature,
      [this.KEYS.SOFTWARE_VERSION]: 'v1.2.4-stable',
    };
  },
};

module.exports = telemetry;
