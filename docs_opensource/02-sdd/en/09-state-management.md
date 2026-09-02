# 09. State Management

## 1. Provider & ChangeNotifier Pattern
- **Controllers**: `ExamController`, `AiTutorController`, `AuthController`, `SettingsController`.
- **Stream Subscriptions**: Real-time snapshots from Cloud Firestore and Firebase RTDB.

## 2. Performance & Anti-ANR Protocols
- **`SafeImageWidget`**: Enforces `cacheWidth: 1024` downsampling.
- **Isolate Offloading via `compute()`**: Long string formatting offloaded to prevent `StringBuffer._addPart` ANR deadlocks.
- **Selective Repainting**: Timers updated via `ValueListenableBuilder`.
