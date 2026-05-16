# Moto Intercom

A complete peer-to-peer motorcycle intercom mobile application for Android and iOS that works fully offline.

## Features

- **Real-time Intercom**: Low-latency duplex voice communication using Opus codec and UDP-like P2P streaming.
- **Offline Operation**: Works without internet using Wi-Fi Direct (Android) and Multipeer Connectivity (iOS).
- **Communication Modes**:
    - Push-to-Talk (PTT)
    - Open Mic
    - Voice Activation (VOX)
- **Music Sharing**: Sync music playback across all connected riders.
- **Rider Discovery**: Automatic discovery and easy connection management.
- **Background Support**: Continues to work even when the phone is locked or in your pocket.
- **Safety Features**: Integrated SOS emergency button and GPS location sharing.

## Architecture

Built with **Clean Architecture** and **BLoC State Management**:
- `lib/core`: Cross-cutting concerns like background services.
- `lib/domain`: Pure business logic, models, and repository interfaces.
- `lib/data`: Infrastructure layer with concrete implementations for Networking and Audio.
- `lib/presentation`: Flutter UI with BLoCs for state handling.

## Tech Stack

- **Flutter**: Cross-platform framework.
- **Nearby Connections**: P2P networking for Android.
- **Opus Codec**: High-quality, low-latency audio compression.
- **Flutter PCM Sound**: Low-latency raw audio playback.
- **Record**: High-performance audio recording.

## Setup Instructions

1. **Prerequisites**:
   - Flutter SDK (latest stable)
   - Android Studio / Xcode
   - Physical devices (P2P networking cannot be fully tested on emulators)

2. **Clone and Install**:
   ```bash
   cd moto_intercom
   flutter pub get
   ```

3. **Android Configuration**:
   - Permissions are already configured in `AndroidManifest.xml`.
   - Ensure Location and Bluetooth are enabled on the device.

4. **iOS Configuration**:
   - Run `pod install` in the `ios` directory.
   - Usage descriptions are configured in `Info.plist`.

5. **Run**:
   ```bash
   flutter run
   ```

## Performance Goals

- **Latency**: Designed for < 150ms voice latency.
- **Capacity**: Supports up to 6 riders in a group.
- **Battery**: Optimized for long rides with background efficiency.

## Future Roadmap

- [ ] Mesh relay support for extended range.
- [ ] Wind noise cancellation algorithms.
- [ ] Advanced ride logging and telemetry.
