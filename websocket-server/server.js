const fs = require('fs');
const path = require('path');
const dgram = require('dgram');

const cfgPath = path.join(__dirname, 'screens.json');
let cfg = { port: 8080, screens: [] };
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
            console.log('Registered client (binary) ', rinfo.address, rinfo.port);
            return;
        }
        if (msgType === 1) {
            console.log('Received msgType=1 (screens request) from', rinfo.address, rinfo.port);
            return;
        }
        if (msgType === 3) {
            try {
                let offset = 1;
                const idLen = msg.readUInt8(offset); offset += 1;
                const idBuf = msg.slice(offset, offset + idLen);
                const screenId = idBuf.toString();
                console.log('Received REQUEST_SCREEN for', screenId, 'from', rinfo.address, rinfo.port);
            } catch (e) {
                console.error('Failed to parse REQUEST_SCREEN', e);
            }
            return;
        }
    }

    let req = null;
    try {
        req = JSON.parse(msg.toString());
    } catch (e) {}

    if (req && req.action === 'register') {
        const key = `${rinfo.address}:${rinfo.port}`;
        clients.set(key, { address: rinfo.address, port: rinfo.port, lastSeen: Date.now() });
        const reply = { type: 'registered' };
        server.send(Buffer.from(JSON.stringify(reply)), rinfo.port, rinfo.address, (err) => {
            if (err) console.error('Error replying to register:', err);
        });
        console.log('Registered client (json)', rinfo.address, rinfo.port);
        return;
    }
});

server.on('listening', () => {
    const address = server.address();
    console.log(`UDP server is listening on ${address.address || '0.0.0.0'}:${address.port}`);
});

server.bind(PORT);


const pushInterval = setInterval(() => {
    const payloadObj = telemetry.createPayload();

    const statusMap = { 'OFFLINE': 0, 'IDLE': 1, 'ONLINE': 2 };
    const connectionMap = { 'DISCONNECTED': 0, 'CONNECTED': 1 };
    const modeMap = { 'MANUAL': 0, 'AUTO': 1 };

    const buf = Buffer.alloc(7);
    let offset = 0;

    const status = payloadObj['systemStatus'] || 'OFFLINE';
    const conn = payloadObj['connectionState'] || 'DISCONNECTED';
    const headerByte = ((statusMap[status] || 0) << 2) | (connectionMap[conn] || 0);
    buf.writeUInt8(headerByte, offset); offset += 1;

    const mode = payloadObj['activeMode'] || 'MANUAL';
    buf.writeUInt16BE(modeMap[mode] || 0, offset); offset += 2;

    const cpuStr = payloadObj['cpuUsage'] || '0%';
    const cpuNum = parseInt(cpuStr);
    buf.writeUInt16BE(Math.min(cpuNum, 100), offset); offset += 2;

    const memStr = payloadObj['memoryUsage'] || '0%';
    const memNum = parseInt(memStr);
    buf.writeUInt16BE(Math.min(memNum, 100), offset); offset += 2;

    try {
        const headerByte = buf.readUInt8(0);
        const statusCode = (headerByte >> 2) & 0x03;
        const connCode = headerByte & 0x03;
        const modeValue = buf.readUInt16BE(1);
        const cpuValue = buf.readUInt16BE(3);
        const memValue = buf.readUInt16BE(5);
        
        console.log('\n=== BINARY PAYLOAD STRUCTURE ===');
        console.log(`Byte 0:   [Header] = 0x${buf.readUInt8(0).toString(16).padStart(2, '0')} (status=${statusCode}, conn=${connCode})`);
        console.log(`Byte 1-2: [Mode]   = 0x${modeValue.toString(16).padStart(4, '0')} (${modeValue})`);
        console.log(`Byte 3-4: [CPU]    = 0x${cpuValue.toString(16).padStart(4, '0')} (${cpuValue}%)`);
        console.log(`Byte 5-6: [Memory] = 0x${memValue.toString(16).padStart(4, '0')} (${memValue}%)`);
        console.log(`Full Hex: ${buf.toString('hex')}`);
        console.log('================================\n');
    } catch (e) {
        console.log('sending buf (length): 7 bytes');
    }

    if (clients.size === 0) {
        return;
    }

    for (const [key, c] of clients.entries()) {
        server.send(buf, c.port, c.address, (err) => {
            if (err) {
                console.error('Error sending to', c.address, c.port, err);
                clients.delete(key);
            }
        });
    }
    console.log('Sent binary payload to', clients.size, 'client(s): 7 bytes');
}, 1000);

process.on('SIGINT', () => {
    clearInterval(pushInterval);
    server.close();
    process.exit(0);
});