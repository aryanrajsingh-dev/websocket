const fs = require('fs');
const path = require('path');
const dgram = require('dgram');

const cfgPath = path.join(__dirname, 'screens.json');
let cfg = { port: 8080 };
try {
    const raw = fs.readFileSync(cfgPath, 'utf8');
    cfg = JSON.parse(raw);
} catch (e) {
    console.log('Warning: could not read screens.json, using defaults', e.message || e);
}

const PORT = process.env.PORT ? Number(process.env.PORT) : (cfg.port || 8080);

const server = dgram.createSocket('udp4');

const clients = new Map();
const telemetry = require('./telemetry');

const MAV_STX_V2 = 0xFD;
const TELEMETRY_MSG_ID = 1;
const TELEMETRY_CRC_EXTRA = 50;
let mavSeq = 0;

function crcAccumulate(crc, value) {
    let tmp = (value ^ (crc & 0xff)) & 0xff;
    tmp ^= (tmp << 4) & 0xff;
    return (((crc >> 8) ^ (tmp << 8) ^ (tmp << 3) ^ (tmp >> 4)) & 0xffff);
}

function buildMavlinkV2Frame(payload) {
    const len = payload.length;
    const incompatFlags = 0;
    const compatFlags = 0;
    const seq = mavSeq & 0xff;
    mavSeq = (mavSeq + 1) & 0xff;
    const sysId = 1;
    const compId = 1;

    const msgId = TELEMETRY_MSG_ID >>> 0;
    const msgIdLow = msgId & 0xff;
    const msgIdMid = (msgId >> 8) & 0xff;
    const msgIdHigh = (msgId >> 16) & 0xff;

    const frameLen = 1 + 1 + 1 + 1 + 1 + 1 + 1 + 3 + len + 2;
    const frame = Buffer.alloc(frameLen);
    let o = 0;

    frame.writeUInt8(MAV_STX_V2, o++);
    frame.writeUInt8(len, o++);
    frame.writeUInt8(incompatFlags, o++);
    frame.writeUInt8(compatFlags, o++);
    frame.writeUInt8(seq, o++);
    frame.writeUInt8(sysId, o++);
    frame.writeUInt8(compId, o++);
    frame.writeUInt8(msgIdLow, o++);
    frame.writeUInt8(msgIdMid, o++);
    frame.writeUInt8(msgIdHigh, o++);

    payload.copy(frame, o);
    o += len;

    let crc = 0xffff;
    const headerBytes = [len, incompatFlags, compatFlags, seq, sysId, compId, msgIdLow, msgIdMid, msgIdHigh];
    for (const b of headerBytes) {
        crc = crcAccumulate(crc, b & 0xff);
    }
    for (let i = 0; i < len; i++) {
        crc = crcAccumulate(crc, payload[i] & 0xff);
    }
    crc = crcAccumulate(crc, TELEMETRY_CRC_EXTRA & 0xff);

    frame.writeUInt8(crc & 0xff, o++);
    frame.writeUInt8((crc >> 8) & 0xff, o++);

    return frame;
}

server.on('error', (err) => {
    console.error(`UDP server error:\n${err.stack}`);
    server.close();
    process.exit(1);
});

server.on('message', (msg, rinfo) => {
    if (msg && msg.length > 0) {
        const msgType = msg.readUInt8(0);
        if (msgType === 0) {
            const key = `${rinfo.address}:${rinfo.port}`;
            clients.set(key, { address: rinfo.address, port: rinfo.port, lastSeen: Date.now() });
            console.log('Registered client (binary)', rinfo.address, rinfo.port);
            return;
        }
    }
});

server.on('listening', () => {
    const address = server.address();
    console.log(`UDP server is listening on ${address.address || '0.0.0.0'}:${address.port}`);
});

server.bind(PORT, '127.0.0.1');


const pushInterval = setInterval(() => {
    const payloadObj = telemetry.createPayload();

    const internalTemp = payloadObj.temperature || '0°C';
    const softwareVersion = payloadObj.softwareVersion || 'v1.0.0';

    const tempBuf = Buffer.from(internalTemp, 'utf8');
    const swBuf = Buffer.from(softwareVersion, 'utf8');


    const totalSize = 4 + 1 + tempBuf.length + 1 + swBuf.length;
    const buf = Buffer.alloc(totalSize);
    let offset = 0;

    const cpuVal = Number(payloadObj.cpuUsage);
    const cpuNum = Number.isFinite(cpuVal) ? cpuVal : 0;
    buf.writeUInt16BE(Math.max(0, Math.min(cpuNum, 100)), offset); offset += 2;

    const memVal = Number(payloadObj.memoryUsage);
    const memNum = Number.isFinite(memVal) ? memVal : 0;
    buf.writeUInt16BE(Math.max(0, Math.min(memNum, 100)), offset); offset += 2;

    buf.writeUInt8(tempBuf.length, offset); offset += 1;
    tempBuf.copy(buf, offset);
    offset += tempBuf.length;

    buf.writeUInt8(swBuf.length, offset); offset += 1;
    swBuf.copy(buf, offset);
    offset += swBuf.length;

    const frame = buildMavlinkV2Frame(buf);

    if (clients.size === 0) {
        return;
    }

    for (const [key, c] of clients.entries()) {
        server.send(frame, c.port, c.address, (err) => {
            if (err) {
                console.error('Error sending to', c.address, c.port, err);
                clients.delete(key);
            }
        });
    }
    telemetry.recordActivity({
        messages: Math.max(1, clients.size),
        rawBytes: buf.length,
        frameBytes: frame.length,
        clientCount: clients.size,
    });
    console.log(`Sent MAVLink v2 telemetry frame to ${clients} client(s): payload=${totalSize} bytes, frame=${frame.length} bytes`);
}, 1000);

process.on('SIGINT', () => {
    clearInterval(pushInterval);
    server.close();
    process.exit(0);
});