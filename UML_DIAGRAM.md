# UML Class Diagram - WebSocket Application Architecture

```mermaid
---
title: WebSocket Application - Core Architecture (No UI)
---
%%{init: {'titleFontSize': 24, 'primaryFontSize': 14}}%%
classDiagram
    direction LR
    
    class WebSocketService {
        -RawDatagramSocket _socket
        -Stream~Map~ rawStream
        -StreamController~Map~ _ctrl
        -InternetAddress _serverAddress
        -int _serverPort
        +connect(wsUrl: String) Future~void~
        +sendRegister() void
        +sendDiscovery() void
        +dispose() void
    }

    class MessageParser {
        +parse(data: Uint8List)$ Map~String, dynamic~
        +parseTyped(data: Uint8List)$ TelemetryPacket
    }

    class BinaryCodec {
        +parseBinary(bytes: Uint8List)$ Map~String, dynamic~
        +parsePacket(bytes: Uint8List)$ TelemetryPacket
    }

    class TelemetryPacket {
        +String systemStatus
        +String connectionState
        +String activeMode
        +int cpuUsage
        +int memoryUsage
        +fromBytes(bytes: Uint8List)$ TelemetryPacket
        -_decodeStatus(code: int)$ String
        -_decodeConnection(code: int)$ String
        -_decodeMode(code: int)$ String
        +toJson() Map~String, dynamic~
        +toString() String
    }

    %% Relationships - Only between custom classes
    WebSocketService ..> MessageParser : uses
    MessageParser ..> BinaryCodec : delegates
    BinaryCodec ..> TelemetryPacket : creates
```

## Relationship Legend

| Symbol | Meaning | Description |
|--------|---------|-------------|
| `*--` | Composition | Strong ownership (part cannot exist without whole) |
| `o--` | Aggregation | Weak ownership (part can exist independently) |
| `-->` | Association | General relationship |
| `..>` | Dependency | Uses without ownership |
| `--|>` | Inheritance | "is a" relationship |
| `..\|>` | Realization | Implements interface |

## Architecture Flow

1. **WebSocketService** receives UDP packets via **RawDatagramSocket**
2. Raw bytes are passed to **MessageParser.parse()**
3. **MessageParser** delegates to **BinaryCodec.parseBinary()**
4. **BinaryCodec** creates **TelemetryPacket** instances
5. **TelemetryPacket.fromBytes()** uses **ByteData** for structured parsing
6. Parsed data flows through **StreamController** to subscribers

## Key Design Patterns

- **Facade Pattern**: WebSocketService provides simple interface to complex UDP operations
- **Factory Pattern**: TelemetryPacket.fromBytes()
- **Static Utility**: MessageParser and BinaryCodec use static methods
- **Observer Pattern**: StreamController for reactive data flow

## Notes

- UI components (HomeScreen, DataView, MyApp) are intentionally excluded
- All parsing logic is encapsulated in model and codec layers
- Type-safe through TelemetryPacket model
- Clean separation between transport (WebSocketService) and parsing (BinaryCodec)
