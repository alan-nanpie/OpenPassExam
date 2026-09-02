# Build Configuration

> **AI Agent Target:** Build flavors, compilation flags, ProGuard rules, and Gradle configuration.
> **Human Target:** Instructions for building Debug and Release packages for Android and Web.

## Build Flavors

- **Development (dev):** Connected to Firebase Local Emulator Suite.
- **Production (prod):** Connected to production Google Cloud Firestore, Firebase RTDB, and Google Play Billing.

## Compilation Commands

### Android App Bundle (AAB)
```bash
flutter build appbundle --flavor prod --target lib/main.dart --release --obfuscate --split-debug-info=build/app/outputs/symbols
```

### Web Release Build
```bash
flutter build web --release --web-renderer canvaskit
```

## ProGuard / R8 Rules (`android/app/proguard-rules.pro`)
```proguard
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.errorprone.annotations.**
```
