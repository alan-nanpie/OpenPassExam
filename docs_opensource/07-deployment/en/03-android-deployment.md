# Android Deployment Guide

> **AI Agent Target:** Release pipeline for Google Play Store, signing configs, and bundle verification.
> **Human Target:** Step-by-step workflow for publishing to Google Play Console.

## 1. Signing Configuration (`android/key.properties`)
```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=../keystore/upload-keystore.jks
```

## 2. Build & Verify AAB
```bash
flutter build appbundle --release
```

## 3. Upload to Google Play Console
- Log in to [Google Play Console](https://play.google.com/console).
- Navigate to "Testing ➔ Internal Testing".
- Create new release and upload `build/app/outputs/bundle/release/app-release.aab`.
