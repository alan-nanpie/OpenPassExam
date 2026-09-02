# Firebase Crashlytics 與 Google Cloud 監控記錄設定指南

## 1. 架構概述
PassExam 採用純血 Google 診斷與品質監控體系：
- **Firebase Crashlytics**：捕捉 Flutter UI、Dart 非同步與 Android 原生崩潰。
- **Google Cloud Logging & Monitoring**：集中化管理後端 Cloud Functions 日誌、RAG 檢索效能與 API 延遲指標。
- **Firebase App Distribution 內建意見回饋**：提供測試人員即時螢幕截圖與錯誤回報。

## 2. SDK 安裝
```yaml
dependencies:
  firebase_crashlytics: ^4.3.0
  firebase_performance: ^0.10.0
```

## 3. 程式碼整合
```dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void initErrorTracking() {
  // 捕捉 Flutter 框架層致命錯誤
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  
  // 捕捉非同步與背景 Isolate 錯誤
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
}

class LogService {
  static Future<void> logEvent(String message, {String? userId, Map<String, dynamic>? parameters}) async {
    await FirebaseCrashlytics.instance.log(message);
    if (userId != null) {
      await FirebaseCrashlytics.instance.setUserIdentifier(userId);
    }
    if (parameters != null) {
      parameters.forEach((key, value) {
        FirebaseCrashlytics.instance.setCustomKey(key, value.toString());
      });
    }
  }
}
```

## 4. ProGuard / R8 映射表自動上傳
在 `android/app/build.gradle` 加入 Crashlytics Gradle 外掛程式：
```groovy
apply plugin: 'com.google.firebase.crashlytics'
```
建置 Release AAB 時會自動上傳 ProGuard 對應檔，確保堆疊追蹤還原清晰的程式碼行號。
