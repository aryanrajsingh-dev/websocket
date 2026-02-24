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
- `msgType` is the first byte of every frame: `uint8`.
- Unless otherwise noted, lengths are limited to what their length-field type allows (e.g. `uint8` ≤255).

Message types
-------------
- 0x00: CLIENT_REGISTER (Client → Server)
- 0x02: DATA_PUSH       (Server → Client)

1) CLIENT_REGISTER (msgType = 0x00)
----------------------------------
Direction: Client → Server
Frequency: Once on connect (or whenever client endpoint/address changes)
Wire format:
- [1] msgType = 0x00

Total length: 1 byte

Hex example (single byte):
00

Uint8List example (Dart):
[0x00]

Semantics: When the server receives this frame it should record the sender's address and port as a registered client endpoint for sending subsequent DATA_PUSH frames.

2) DATA_PUSH (msgType = 0x02)
-----------------------------
Direction: Server → Client
Frequency: Server-defined (e.g. periodic updates)
Purpose: Convey a set of key/value pairs for the client to render. In this project there is no pageId or screenId — the server pushes only pairs.

Wire format (canonical):
- [1]  msgType = 0x02
- [1]  pairsCount (uint8)
- for each pair:
   - [1]  keyLen (uint8)
   - [K]  key (UTF-8 bytes)
   - [2]  valLen (uint16, big-endian)
   - [V]  value (byte sequence of length valLen; interpret as UTF-8 text unless otherwise specified)

Notes:
- `valLen` is `uint16` to allow values up to 65535 bytes.

Example: DATA_PUSH with two pairs: `("temp","21.5")`, `("status","ok")`.
Build step-by-step (values in ASCII / UTF-8):
- msgType = 0x02
- pairsCount = 0x02

Pair 1:
- keyLen = 0x04 ("temp")
- key = 74 65 6d 70
- valLen = 0x0004 (value "21.5" length = 4) as uint16 BE
- value = 32 31 2e 35

Pair 2:
- keyLen = 0x06 ("status")
- key = 73 74 61 74 75 73
- valLen = 0x0002 (value "ok" length = 2)
- value = 6f 6b

Concatenate all parts; full hex:
02 02 04 74 65 6d 70 00 04 32 31 2e 35 06 73 74 61 74 75 73 00 02 6f 6b

Uint8List (Dart) example:
[0x02, 0x02, 0x04, 0x74,0x65,0x6d,0x70, 0x00,0x04,0x32,0x31,0x2e,0x35, 0x06,0x73,0x74,0x61,0x74,0x75,0x73, 0x00,0x02,0x6f,0x6b]

Parsing pseudocode
------------------
1. Read first byte -> msgType.
2. Switch on msgType.
  - 0x00: no further bytes; treat sender as registered.
  - 0x02: read 1 byte -> pairsCount; loop pairsCount times reading keyLen (1 byte), key, valLen (2 bytes BE), val.

Compatibility notes
-------------------
- Ensure server and client agree on big-endian vs little-endian. The spec above uses big-endian (network byte order).
- If you have existing code that used little-endian, either update code to big-endian or change this doc and regenerate examples accordingly.
- For NAT traversal: because UDP is connectionless, clients must send `CLIENT_REGISTER` after opening their socket and periodically if their endpoint changes or to keep NAT bindings alive.

Versioning and extensibility
----------------------------
- Reserve msgType values for future use. Consider adding a `version` byte after msgType in future protocol versions.
- Use `pageId` and `screenId` to allow multiple logical pages/screens per client.

Appendix: Quick mapping from old JSON to binary
---------------------------------------------
- JSON `{"action":"register"}`  -> binary `[0x00]` (CLIENT_REGISTER)
- JSON `{"action":"listScreens"}` -> binary `[0x01]` (DISCOVERY)
- JSON `{"screenId":"1"}` -> binary `[0x03][0x01][0x31]` (REQUEST_SCREEN)
- JSON `{"screenId":"1","pairs": {"temp":"21.5"}}` -> DATA_PUSH as shown above

Questions / Next steps
----------------------
- I created this spec file to define a binary wire format. Do you want me to update the server and client code to strictly follow the big-endian fields in this spec (if they currently use a different endianness)?
- I can also convert any markdown or API docs that currently show JSON examples to include the binary hex examples.


