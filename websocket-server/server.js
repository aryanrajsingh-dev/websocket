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
    if (clients.size === 0) return;

    const payloadObj = telemetry.createPayload();

    const pairs = Object.entries(payloadObj).map(([k, v]) => {
        const keyBuf = Buffer.from(String(k));
        const valStr = JSON.stringify(v);
        const valBuf = Buffer.from(valStr);
        return { keyBuf, valBuf };
    });

    const id = Buffer.from('1');

        let total = 1 + 8 + 1 + id.length + 1;
    for (const p of pairs) {
        total += 1 + p.keyBuf.length + 2 + p.valBuf.length;
    }

    const buf = Buffer.alloc(total);
    let offset = 0;
    buf.writeUInt8(2, offset); offset += 1;

    buf.writeUInt32BE(0, offset); offset += 4;
    buf.writeUInt32BE(0, offset); offset += 4;

    buf.writeUInt8(id.length, offset); offset += 1;
    id.copy(buf, offset); offset += id.length;

    buf.writeUInt8(pairs.length, offset); offset += 1;

    for (const p of pairs) {
        buf.writeUInt8(p.keyBuf.length, offset); offset += 1;
        p.keyBuf.copy(buf, offset); offset += p.keyBuf.length;
        buf.writeUInt16BE(p.valBuf.length, offset); offset += 2;
        p.valBuf.copy(buf, offset); offset += p.valBuf.length;
    }

    try {
        console.log('sending buf hex:', buf.toString('hex'));
    } catch (e) {
        console.log('sending buf (length):', buf.length);
    }
    for (const [key, c] of clients.entries()) {
        server.send(buf, c.port, c.address, (err) => {
            if (err) {
                console.error('Error sending to', c.address, c.port, err);
                clients.delete(key);
            }
        });
    }
    console.log('Sent custom binary payload to', clients.size, 'client(s):', buf.length, 'bytes');
}, 1000);

process.on('SIGINT', () => {
    clearInterval(pushInterval);
    server.close();
    process.exit(0);
});