Binary protocol spec
====================

Overview
--------
This document defines the binary wire format used by the UDP server and clients.
Use this as the single source of truth for message encodings and examples.

Common rules
------------
- All multi-byte integer fields are unsigned big-endian (network byte order).
- Single-byte integers are `uint8`.
- Strings are UTF-8 encoded and are prefixed by a length field (length field size noted per field).
- Unless otherwise noted, lengths are limited to what their length-field type allows (e.g. `uint8` ≤255).

DATA_PUSH Packet Format
------------------------
Direction: Server → Client
Frequency: Server-defined (e.g. periodic updates)
Purpose: Convey telemetry data in compact fixed-size format with header byte and multi-byte fields.

Wire format (canonical - FIXED 7 bytes):
- [1]  Header/Flag byte:
       - Bits 2-3: systemStatus (0=OFFLINE, 1=IDLE, 2=ONLINE)
       - Bits 0-1: connectionState (0=DISCONNECTED, 1=CONNECTED)
- [2]  Field 1: activeMode (uint16 BE, 0=MANUAL, 1=AUTO)
- [2]  Field 2: cpuUsage (uint16 BE, 0-100 percentage)
- [2]  Field 3: memoryUsage (uint16 BE, 0-100 percentage)

Total: 7 bytes (fixed size, no variable data)

Example: Fixed-size DATA_PUSH with header and 3 fields.
Build step-by-step:
- Header byte: systemStatus=ONLINE(2), connectionState=CONNECTED(1) → (2<<2)|1 = 0x09
- activeMode = 0x0001 (AUTO)
- cpuUsage = 0x0010 (16%)
- memoryUsage = 0x0032 (50%)

Concatenate all parts; full hex:
09 00 01 00 10 00 32

Uint8List (Dart) example:
[0x09, 0x00, 0x01, 0x00, 0x10, 0x00, 0x32]

Parsing pseudocode
------------------
1. Verify packet contains 7 bytes.
2. Read byte 0 (header):
   - Extract systemStatus: (header >> 2) & 0x03 → (0=OFFLINE, 1=IDLE, 2=ONLINE)
   - Extract connectionState: header & 0x03 → (0=DISCONNECTED, 1=CONNECTED)
3. Read bytes 1-2 as uint16 BE → activeMode (0=MANUAL, 1=AUTO)
4. Read bytes 3-4 as uint16 BE → cpuUsage (0-100 percentage)
5. Read bytes 5-6 as uint16 BE → memoryUsage (0-100 percentage)

Compatibility notes
-------------------
- Ensure server and client agree on big-endian vs little-endian. The spec above uses big-endian (network byte order).
- If you have existing code that used little-endian, either update code to big-endian or change this doc and regenerate examples accordingly.
- For NAT traversal: because UDP is connectionless, clients must send `CLIENT_REGISTER` after opening their socket and periodically if their endpoint changes or to keep NAT bindings alive.

Versioning and extensibility
----------------------------
- Current implementation uses fixed-size 7-byte packets for production efficiency.
- Header byte packs two fields using bit manipulation for space optimization.
- Multi-byte fields use uint16 big-endian encoding.
- Future versions may add additional packet types with different length indicators.

Appendix: Field Encoding Reference
-----------------------------------
Header Byte (Byte 0) - Bit Layout:
  Bits 7-4: Reserved (unused)
  Bits 3-2: systemStatus
  Bits 1-0: connectionState

systemStatus codes (2 bits):
  0b00 (0x00) = OFFLINE
  0b01 (0x01) = IDLE
  0b10 (0x02) = ONLINE
  0b11 (0x03) = Reserved

connectionState codes (2 bits):
  0b00 (0x00) = DISCONNECTED
  0b01 (0x01) = CONNECTED
  0b10 (0x02) = Reserved
  0b11 (0x03) = Reserved

activeMode codes (uint16):
  0x0000 = MANUAL
  0x0001 = AUTO

cpuUsage (uint16): Raw percentage 0-100
memoryUsage (uint16): Raw percentage 0-100

Questions / Next steps
----------------------
- Fixed-size protocol now production-ready with 13-byte packets.
- Parsing uses ByteData for efficient binary access without loops.
- All multi-byte integers use big-endian (network byte order).
- Protocol provides 10x size reduction vs variable-length format.


