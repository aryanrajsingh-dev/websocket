# Clean Binary Parsing Architecture

## Overview

This project implements **production-quality binary parsing** following clean architecture principles. The implementation uses `ByteData.sublistView()` and structured model classes to eliminate scattered byte indexing and offset tracking from the UI layer.

## Architecture Layers

```
┌─────────────────────────────────────┐
│         UI Layer (Widgets)          │  ← No binary parsing logic
│   Accesses: TelemetryPacket fields  │
└─────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────┐
│      Parser Layer (MessageParser)   │  ← Type-safe routing
│   Routes to appropriate model       │
└─────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────┐
│     Model Layer (fromBytes())       │  ← Binary parsing with ByteData
│   TelemetryPacket, ScreenListPacket │
└─────────────────────────────────────┘
```

## Key Components

### 1. **TelemetryPacket** ([models/telemetry_packet.dart](../lib/src/models/telemetry_packet.dart))

Strongly-typed model for telemetry data with clean field access.

**Features:**
- Uses `ByteData.sublistView()` for structured parsing
- Proper endianness handling (`Endian.big`)
- Type-safe field accessors
- No `offset` variables scattered in UI code
- Factory constructor `fromBytes()` encapsulates all parsing logic

**Usage:**
```dart
final packet = TelemetryPacket.fromBytes(bytes);

// Clean, readable access
print(packet.systemStatus);    // → "ONLINE"
print(packet.cpuUsage);         // → "42%"
print(packet.timestamp);        // → DateTime object

// Generic type-safe accessor
final mode = packet.getField<String>('activeMode');
```

### 2. **ScreenListPacket** ([models/screen_list_packet.dart](../lib/src/models/screen_list_packet.dart))

Parses screen list responses with structured entries.

**Usage:**
```dart
final packet = ScreenListPacket.fromBytes(bytes);

for (final screen in packet.screens) {
  print('${screen.screenId}: ${screen.title}');
}
```

### 3. **MessageParser** ([parser.dart](../lib/src/parser.dart))

Provides both legacy Map-based and modern typed APIs.

**Typed API (Recommended):**
```dart
final packet = MessageParser.parseTyped(bytes);

if (packet is TelemetryPacket) {
  // Handle telemetry
} else if (packet is ScreenListPacket) {
  // Handle screen list
}
```

**Legacy API (Backwards Compatible):**
```dart
final result = MessageParser.parse(bytes);
if (result['type'] == 'data') {
  print(result['cpuUsage']);
}
```

## Binary Packet Formats

### Telemetry Packet (Type 2)

```
┌─────────┬────────────┬──────────┬───────────┬────────┬──────────────┐
│  Type   │ Timestamp  │ ID Len   │ Screen ID │ Pairs  │  Key-Value   │
│ (uint8) │ (uint64)   │ (uint8)  │ (string)  │(uint8) │   Pairs...   │
└─────────┴────────────┴──────────┴───────────┴────────┴──────────────┘
   1 byte    8 bytes     1 byte     variable   1 byte    variable
```

**Each Key-Value Pair:**
```
┌─────────┬─────────┬───────────┬─────────┐
│ Key Len │   Key   │ Value Len │  Value  │
│ (uint8) │(string) │ (uint16)  │(string) │
└─────────┴─────────┴───────────┴─────────┘
```

### Screen List Packet (Type 1)

```
┌─────────┬───────────┬────────────────────────┐
│  Type   │   Count   │      Screen Entries    │
│ (uint8) │  (uint8)  │       (variable)       │
└─────────┴───────────┴────────────────────────┘
```

**Each Screen Entry:**
```
┌─────────┬─────────┬───────────┬─────────┐
│ ID Len  │   ID    │ Title Len │  Title  │
│ (uint8) │(string) │  (uint8)  │(string) │
└─────────┴─────────┴───────────┴─────────┘
```

## Benefits of This Architecture

### ✅ What We Achieved

1. **No Offset Variables in UI**
   - All offset tracking is encapsulated in model constructors
   - UI code never touches byte indices

2. **Type Safety**
   - Compile-time checking for field access
   - IDE autocomplete for telemetry fields

3. **Clean Separation of Concerns**
   - Parsing logic: Model layer (`fromBytes()`)
   - Business logic: Service layer
   - Presentation: UI layer (widgets)

4. **Proper ByteData Usage**
   - Uses `ByteData.sublistView()` for efficient memory access
   - Proper endianness handling
   - No raw buffer manipulation

5. **Testable**
   - Each layer can be unit tested independently
   - Mock data generation is straightforward

### ❌ What We Eliminated

- ❌ Scattered `offset` variables throughout code
- ❌ Raw indexing like `bytes[0]`, `bytes[1]` in UI
- ❌ Manual byte arithmetic in presentation layer
- ❌ Unclear data structures (Map with dynamic values)
- ❌ Error-prone manual buffer walking

## Usage Examples

### Example 1: UI Widget (Clean Access)

```dart
class TelemetryDisplay extends StatelessWidget {
  final TelemetryPacket data;

  @override
  Widget build(BuildContext context) {
    // NO binary parsing here - just clean data access!
    return Column(
      children: [
        Text('Status: ${data.systemStatus}'),
        Text('CPU: ${data.cpuUsage}'),
        Text('Mode: ${data.activeMode}'),
      ],
    );
  }
}
```

### Example 2: Service Layer

```dart
class DataService {
  void handleIncomingData(Uint8List bytes) {
    try {
      final packet = MessageParser.parseTyped(bytes);
      
      if (packet is TelemetryPacket) {
        _updateTelemetry(packet);
      } else if (packet is ScreenListPacket) {
        _updateScreens(packet);
      }
    } catch (e) {
      _handleError(e);
    }
  }
  
  void _updateTelemetry(TelemetryPacket packet) {
    // Clean, type-safe access
    final status = packet.systemStatus ?? 'UNKNOWN';
    final cpu = packet.cpuUsage ?? '0%';
    
    // Business logic here
  }
}
```

### Example 3: Console Listener

Run the terminal listener to see clean parsing in action:

```bash
cd screens/websocket_app
dart run bin/udp_listener.dart
```

Or run the example:

```bash
dart run lib/src/examples/clean_parsing_example.dart
```

## Running the Project

### Start the Server

```bash
cd websocket-server
node server.js
```

### Option 1: Console Listener (No UI)

```bash
cd screens/websocket_app
dart run bin/udp_listener.dart
```

### Option 2: Flutter App

```bash
cd screens/websocket_app
flutter run
```

## Testing

The architecture makes testing straightforward:

```dart
test('Parse telemetry packet', () {
  final bytes = createMockTelemetryBytes();
  final packet = TelemetryPacket.fromBytes(bytes);
  
  expect(packet.messageType, 2);
  expect(packet.systemStatus, 'ONLINE');
  expect(packet.cpuUsage, '42%');
});
```

## Migration Guide

If you have existing code using the old Map-based API:

**Before:**
```dart
final result = parse(bytes);
final cpu = result['cpuUsage'];  // Dynamic, no type safety
```

**After:**
```dart
final packet = MessageParser.parseTelemetry(bytes);
final cpu = packet.cpuUsage;  // String?, type-safe
```

Both APIs are supported for backwards compatibility.

## File Structure

```
lib/src/
├── models/
│   ├── telemetry_packet.dart      ← Binary parsing with ByteData
│   ├── screen_list_packet.dart    ← Structured screen list parsing
│   ├── data_dto.dart              ← Legacy DTO
│   └── screen_dto.dart            ← Screen data transfer object
├── binary_codec.dart              ← Codec layer using models
├── parser.dart                    ← Message routing and parsing
├── ws_service.dart                ← UDP socket service
└── examples/
    └── clean_parsing_example.dart ← Usage examples

bin/
└── udp_listener.dart              ← Console app demonstrating clean API
```

## Key Principles

1. **Single Responsibility**: Each model handles its own binary format
2. **Encapsulation**: Parsing logic is hidden in factory constructors
3. **Type Safety**: Use strongly-typed models over dynamic Maps
4. **Immutability**: Models are immutable (const constructors)
5. **Clean Code**: UI layer has zero binary parsing logic

## References

- [Dart ByteData Documentation](https://api.dart.dev/stable/dart-typed_data/ByteData-class.html)
- [Clean Architecture in Flutter](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- Binary Protocol Specification: See [PROTOCOL_BINARY.md](../../PROTOCOL_BINARY.md)

---

**Result**: Production-quality code that's maintainable, testable, and follows best practices. No scattered byte indexing, no offset variables in UI, and clean separation of concerns.
