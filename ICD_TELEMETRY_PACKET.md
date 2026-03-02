# Interface Control Document (ICD)
## Telemetry Packet Specification

**Document Version:** 2.0  
**Date:** 26 February 2026  
**Protocol:** Binary UDP Telemetry Stream  

---

## Packet Overview

| Property | Value |
|----------|-------|
| **Protocol Type** | Binary (Big-Endian) |
| **Transport** | UDP |
| **Direction** | Server → Client |
| **Frequency** | Periodic (1 Hz default) |
| **Min Packet Size** | 7 bytes (legacy) |
| **Core Packet Size** | 9 bytes (fixed core) |
| **Max Packet Size** | Variable (9 + string lengths) |

---

## Core Section (Fixed - 9 Bytes)

| Byte Position | Field Name | Data Type | Size | Description | Value Range |
|--------------|------------|-----------|------|-------------|-------------|
| 0 | Header | uint8 | 1 byte | Packed status flags | See bit layout below |
| 1-2 | Active Mode | uint16 BE | 2 bytes | System operation mode | 0=MANUAL, 1=AUTO |
| 3-4 | CPU Usage | uint16 BE | 2 bytes | CPU utilization percentage | 0-100 |
| 5-6 | Memory Usage | uint16 BE | 2 bytes | Memory utilization percentage | 0-100 |
| 7 | Storage Percent | uint8 | 1 byte | Disk usage percentage | 0-100 |
| 8 | Signal Strength | int8 | 1 byte | WiFi signal strength (dBm) | -128 to 127 (typical: -30 to -100) |

### Header Byte (Byte 0) - Bit Layout

| Bits | Field Name | Values |
|------|------------|--------|
| 7-4 | Reserved | 0 (unused) |
| 3-2 | System Status | 0=OFFLINE, 1=IDLE, 2=ONLINE, 3=Reserved |
| 1-0 | Connection State | 0=DISCONNECTED, 1=CONNECTED, 2-3=Reserved |

**Extraction Formula:**
```
systemStatus = (headerByte >> 2) & 0x03
connectionState = headerByte & 0x03
```

---

## Extended Section (Variable Length)

| Byte Position | Field Name | Data Type | Size | Description |
|--------------|------------|-----------|------|-------------|
| 9 | Temp Length | uint8 | 1 byte | Length of internalTemp string (N1) |
| 10 to 10+N1-1 | Internal Temp | UTF-8 String | N1 bytes | System temperature (e.g., "42°C") |
| 10+N1 | IP Length | uint8 | 1 byte | Length of ipAddress string (N2) |
| 11+N1 to 11+N1+N2-1 | IP Address | UTF-8 String | N2 bytes | Network IP (e.g., "192.168.1.50") |
| 11+N1+N2 | FW Length | uint8 | 1 byte | Length of firmwareVersion string (N3) |
| 12+N1+N2 to 12+N1+N2+N3-1 | Firmware Version | UTF-8 String | N3 bytes | Firmware version (e.g., "v1.2.4-stable") |

**String Encoding:** UTF-8  
**Max String Length:** 255 bytes per string (uint8 length limit)

---

## Field Specifications

### 1. System Status (2 bits)
| Code | Value | Description |
|------|-------|-------------|
| 0 | OFFLINE | System is offline/shutdown |
| 1 | IDLE | System is idle, no active operations |
| 2 | ONLINE | System is operational |
| 3 | Reserved | Future use |

### 2. Connection State (2 bits)
| Code | Value | Description |
|------|-------|-------------|
| 0 | DISCONNECTED | Network disconnected |
| 1 | CONNECTED | Network connected |
| 2-3 | Reserved | Future use |

### 3. Active Mode (16-bit)
| Code | Value | Description |
|------|-------|-------------|
| 0 | MANUAL | Manual control mode |
| 1 | AUTO | Autonomous operation mode |
| 2+ | Reserved | Future modes |

### 4. CPU Usage (16-bit)
- **Units:** Percentage (%)
- **Range:** 0-100
- **Resolution:** 1%
- **Type:** Instantaneous value

### 5. Memory Usage (16-bit)
- **Units:** Percentage (%)
- **Range:** 0-100
- **Resolution:** 1%
- **Type:** Instantaneous value

### 6. Storage Percent (8-bit)
- **Units:** Percentage (%)
- **Range:** 0-100
- **Resolution:** 1%
- **Type:** Disk usage percentage

### 7. Signal Strength (8-bit signed)
- **Units:** dBm
- **Range:** -128 to +127 dBm
- **Typical Range:** -30 to -100 dBm
- **Quality Thresholds:**
  - Excellent: ≥ -50 dBm
  - Good: -50 to -70 dBm
  - Fair: -70 to -85 dBm
  - Poor: < -85 dBm

### 8. Internal Temperature (String)
- **Format:** Free text with unit
- **Example:** "42°C", "108°F"
- **Max Length:** 255 bytes

### 9. IP Address (String)
- **Format:** IPv4 dotted notation or IPv6
- **Example:** "192.168.1.50", "10.0.0.1"
- **Max Length:** 255 bytes

### 10. Firmware Version (String)
- **Format:** Version string
- **Example:** "v1.2.4-stable", "2.0.1-beta"
- **Max Length:** 255 bytes

---

## Example Packets

### Example 1: Minimal Legacy Packet (7 bytes)
```
Hex: 09 00 01 00 23 00 3C
```

| Bytes | Field | Value |
|-------|-------|-------|
| 09 | Header | ONLINE + CONNECTED |
| 00 01 | Mode | AUTO |
| 00 23 | CPU | 35% |
| 00 3C | Memory | 60% |

Extended fields default to: storage=0%, signal=-100dBm, strings="N/A"

### Example 2: Extended Packet (38 bytes)
```
Hex: 09 00 01 00 2D 00 46 52 BF 04 34 32 C2 B0 43 
     0C 31 39 32 2E 31 36 38 2E 31 2E 35 30 0D 76 
     31 2E 32 2E 34 2D 73 74 61 62 6C 65
```

| Field | Value | Hex Bytes |
|-------|-------|-----------|
| Header | ONLINE + CONNECTED | 09 |
| Mode | AUTO | 00 01 |
| CPU | 45% | 00 2D |
| Memory | 70% | 00 46 |
| Storage | 82% | 52 |
| Signal | -65 dBm | BF |
| Temp Length | 4 | 04 |
| Temp String | "42°C" | 34 32 C2 B0 43 |
| IP Length | 12 | 0C |
| IP String | "192.168.1.50" | 31 39 32... |
| FW Length | 13 | 0D |
| FW String | "v1.2.4-stable" | 76 31 2E... |

---

## Backward Compatibility

### Legacy Support (7-byte packets)
- Parser handles packets with length ≥ 7 bytes
- If packet.length < 9: New fields use default values
- If packet.length >= 9 but < expected: Partial parsing with defaults

### Default Values
| Field | Default |
|-------|---------|
| storagePercent | 0 |
| signalStrength | -100 |
| internalTemp | "N/A" |
| ipAddress | "N/A" |
| firmwareVersion | "N/A" |

---

## Parsing Algorithm

```dart
1. Verify minimum packet size (7 bytes)
2. Create ByteData view of packet
3. Parse Header byte:
   - Extract systemStatus: (header >> 2) & 0x03
   - Extract connectionState: header & 0x03
4. Parse fixed fields using ByteData:
   - activeMode: getUint16(1, Endian.big)
   - cpuUsage: getUint16(3, Endian.big)
   - memoryUsage: getUint16(5, Endian.big)
5. If packet.length >= 9:
   - storagePercent: getUint8(7)
   - signalStrength: getInt8(8)
6. If packet.length > 9:
   - Parse variable strings with length prefixes
   - Track offset for each string section
   - Decode UTF-8 strings
7. Apply defaults for missing fields
8. Return TelemetryPacket object
```

---

## Error Handling

| Condition | Action |
|-----------|--------|
| Packet size < 7 bytes | Throw ArgumentError |
| Packet size 7-8 bytes | Parse legacy, default new fields |
| Packet size ≥ 9 bytes | Parse core + attempt extended |
| Invalid string length | Skip that string, use default |
| Offset overflow | Stop parsing, use defaults for remaining |
| UTF-8 decode error | Use default value for that string |

---

## Change Log

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | Initial | 7-byte fixed packet (legacy) |
| 2.0 | 26 Feb 2026 | Extended to 9+ bytes with variable strings |

---

## Notes

1. **Endianness:** All multi-byte integers use Big-Endian (network byte order)
2. **Signed vs Unsigned:** Only `signalStrength` is signed (int8), all others unsigned
3. **String Encoding:** UTF-8 with length prefix (supports international characters)
4. **Extensibility:** Can add more fields after existing strings without breaking compatibility
5. **Performance:** Fixed-size core enables fast parsing; variable strings parsed on-demand

---

**End of Document**
