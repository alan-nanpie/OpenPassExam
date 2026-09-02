# Firebase Crashlytics & Google Cloud Logging Setup Guide

## 1. Architecture Overview
PassExam uses Google Cloud diagnostic and quality monitoring solutions:
- **Firebase Crashlytics**: Captures Flutter UI, Dart asynchronous, and Android native crashes.
- **Google Cloud Logging & Monitoring**: Centralized telemetry for Cloud Functions, RAG latency, and API metrics.
- **Firebase App Distribution**: Built-in tester feedback and issue reporting.

## 2. SDK Installation
```yaml
dependencies:
  firebase_crashlytics: ^4.3.0
  firebase_performance: ^0.10.0
```

## 3. Code Integration
```dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void initErrorTracking() {
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  
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

## 4. ProGuard / R8 Mapping Upload
Add the Crashlytics Gradle plugin in `android/app/build.gradle`:
```groovy
apply plugin: 'com.google.firebase.crashlytics'
```
Release AAB builds automatically upload de-obfuscation mapping files.
