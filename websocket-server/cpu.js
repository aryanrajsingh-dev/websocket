const fs = require('fs');

let previousSample = null;
let previousUsage = null;

function readCpuSample() {
  const data = fs.readFileSync('/proc/stat', 'utf8');
  const line = data.split('\n').find(l => l.startsWith('cpu '));
  if (!line) {
    return null;
  }
  const parts = line
    .trim()
    .split(/\s+/)
    .slice(1)
    .map(v => parseInt(v, 10))
    .filter(n => Number.isFinite(n));
  if (parts.length < 4) {
    return null;
  }
  const idle = parts[3];
  const total = parts.reduce((sum, v) => sum + v, 0);
  if (total <= 0) {
    return null;
  }
  return { idle, total };
}

function getCpuUsagePercent() {
  try {
    const current = readCpuSample();
    if (!current) {
      return 0;
    }
    if (!previousSample) {
      previousSample = current;
      return 0;
    }
    const idleDiff = current.idle - previousSample.idle;
    const totalDiff = current.total - previousSample.total;
    previousSample = current;
    if (totalDiff <= 0) {
      return 0;
    }
    let usage = 100 * (1 - idleDiff / totalDiff);
    if (!Number.isFinite(usage)) {
      usage = 0;
    }
    if (usage < 0) {
      usage = 0;
    }
    if (usage > 100) {
      usage = 100;
    }
    if (previousUsage != null) {
      const maxStep = 15;
      if (usage > previousUsage + maxStep) {
        usage = previousUsage + maxStep;
      } else if (usage < previousUsage - maxStep) {
        usage = previousUsage - maxStep;
      }
    }
    if (previousUsage == null) {
      previousUsage = usage;
    } else {
      const alpha = 0.25;
      previousUsage = previousUsage + (usage - previousUsage) * alpha;
    }
    return Math.round(previousUsage);
  } catch (e) {
    return 0;
  }
}

module.exports = {
  getCpuUsagePercent,
};
