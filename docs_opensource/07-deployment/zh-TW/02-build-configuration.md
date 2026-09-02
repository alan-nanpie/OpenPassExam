# 建置設定 (Build Configuration)

> **AI Agent Target:** Build flavors, compilation flags, ProGuard rules, and Gradle configuration.
> **Human Target:** 如何為 Android 與 Web 平台建置除錯 (Debug) 與發布 (Release) 版本。

## 建置變體 (Build Flavors)

- **Development (dev):** 連接 Firebase Local Emulator Suite 進行本地開發。
- **Production (prod):** 連接正式版 Google Cloud Firestore、Firebase RTDB 與 Google Play Billing。

## 編譯旗標與指令 (Compilation Commands)

### Android App Bundle (AAB)
```bash
flutter build appbundle --flavor prod --target lib/main.dart --release --obfuscate --split-debug-info=build/app/outputs/symbols
```

### Web 發布版本
```bash
flutter build web --release --web-renderer canvaskit
```

## ProGuard 與 R8 最佳化 (`android/app/proguard-rules.pro`)
```proguard
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.errorprone.annotations.**
```
