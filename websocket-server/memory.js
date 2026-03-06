const fs = require('fs');

let previousUsage = null;

function getMemoryUsagePercent() {
  try {
    const data = fs.readFileSync('/proc/meminfo', 'utf8');
    let memTotal;
    let memFree;
    let buffers;
    let cached;
    const lines = data.split('\n');
    for (const line of lines) {
      if (line.startsWith('MemTotal:')) {
        memTotal = parseInt(line.replace(/[^0-9]/g, ''), 10);
      } else if (line.startsWith('MemFree:')) {
        memFree = parseInt(line.replace(/[^0-9]/g, ''), 10);
      } else if (line.startsWith('Buffers:')) {
        buffers = parseInt(line.replace(/[^0-9]/g, ''), 10);
      } else if (line.startsWith('Cached:')) {
        cached = parseInt(line.replace(/[^0-9]/g, ''), 10);
      }
    }
    if (!memTotal || memTotal <= 0) {
      return 0;
    }
    const free = (memFree || 0) + (buffers || 0) + (cached || 0);
    const used = memTotal - free;
    let usage = (used / memTotal) * 100;
    if (!Number.isFinite(usage)) {
      usage = 0;
    }
    if (usage < 0) {
      usage = 0;
    }
    if (usage > 100) {
      usage = 100;
    }
    if (previousUsage == null) {
      previousUsage = usage;
    } else {
      const alpha = 0.2;
      previousUsage = previousUsage + (usage - previousUsage) * alpha;
    }
    return Math.round(previousUsage);
  } catch (e) {
    return 0;
  }
}

module.exports = {
  getMemoryUsagePercent,
};
