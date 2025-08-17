# yk_tools

A versatile Flutter package providing essential utilities for common mobile development tasks, including IM management, RTC (Real-Time Communication), storage, audio handling, and more.

## Features

- **IM Management**: Handle instant messaging with connection state tracking, message handling, and group operations.
- **RTC Utilities**: Manage real-time communication including room management, audio/video controls.
- **Disk Management**: Register and manage disk modules for various storage operations.
- **Media Handling**: Record audio, play audio files with progress tracking.
- **Media Picking**: Select images from gallery and capture photos using device camera.
- **Socket Communication**: WebSocket implementation with auto-reconnect functionality.
- **Task Scheduling**: Execute tasks in sequence with rollback capabilities.
- **Storage Utilities**: Manage persistent storage with support for one-time and cached data.
- **In-app Push**: Handle in-app push notifications with queuing mechanism.

## Getting started

### Prerequisites
- Flutter SDK (>=1.17.0)
- Dart SDK (^3.5.4)

### Installation
Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  yk_tools:
    git:
      url: https://github.com/yykedward/yk_tools.git
      ref: main
```

Then run:
```bash
flutter pub get
```

## Usage

### IM Manager Example

```dart
import 'package:yk_tools/yk_im_manager.dart';

// Implement the delegate
class MyImDelegate with YkImManagerDelegate {
  // Implement all required methods
  @override
  Future<void> init(
    MessageCallback onMessageReceived,
    KickedOfflineCallback onKickedOffline,
    dynamic params,
  ) async {
    // Initialize your IM service
  }

  // Other method implementations...
}

// Initialize IM Manager
void setupIm() async {
  await YkImManager.instance.config(delegate: MyImDelegate());
  await YkImManager.instance.init(
    params: {'apiKey': 'your_api_key'},
    onKickedOffline: () {
      // Handle kicked offline
    },
  );
  
  // Listen to messages
  YkImManager.instance.messageStream.listen((message) {
    // Handle incoming messages
  });
}
```

### Storage Example

```dart
import 'package:yk_tools/yk_storage.dart';

// Implement storage delegate
class MyStorageDelegate with YkStorageDelegate {
  // Implement required methods
  @override
  Future<void> init() async {
    // Initialize storage
  }

  @override
  Future<void> save({required String key, required dynamic data}) async {
    // Save implementation
  }

  @override
  Future<dynamic> get({required String key}) async {
    // Get implementation
    return null;
  }
}

// Use storage
void setupStorage() async {
  await YkStorage.init(delegate: MyStorageDelegate());
  
  // Save data
  await YkStorage.save(key: 'user_name', data: 'John Doe', isOnce: false);
  
  // Retrieve data
  final userName = await YkStorage.get<String>(key: 'user_name');
}
```

## Additional information

### Contributing
- Fork the repository
- Create your feature branch (`git checkout -b feature/amazing-feature`)
- Commit your changes (`git commit -m 'Add some amazing feature'`)
- Push to the branch (`git push origin feature/amazing-feature`)
- Open a Pull Request

### Issues
Please file issues [here](https://github.com/yykedward/yk_tools/issues) to report bugs or request features.

### License
This package is released under the MIT License. See [LICENSE](LICENSE) for details.