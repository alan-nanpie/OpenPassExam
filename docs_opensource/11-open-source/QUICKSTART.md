# 快速開始指南 (Quick Start Guide)

本指南將帶領您在本地端快速運行 PassExam 應用程式。

## 1. 前置作業 (Prerequisites)
- **OS**: Windows 11 Pro / macOS / Linux
- **Flutter SDK**: 3.27+
- **JDK**: **JDK 21 LTS**
- **Android NDK**: `28.2.13676358`
- **Google Cloud & Firebase 帳號**

## 2. 下載依賴與配置金鑰
```bash
# 1. 下載 Flutter 套件
flutter pub get

# 2. 配置 secrets.json
cp secrets.example.json secrets.json
```

## 3. 運行應用程式
```bash
# 運行於 Android 裝置或模擬器
flutter run

# 運行於 Web
flutter run -d chrome
```
