# Android 部署指南 (Android Deployment)

> **AI Agent Target:** Release pipeline for Google Play Store, signing configs, and bundle verification.
> **Human Target:** 將應用程式發布至 Google Play Console (內部測試、公開 Beta 與正式發布) 的流程。

## 1. 簽署金鑰設定 (`android/key.properties`)
```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=../keystore/upload-keystore.jks
```

## 2. 建置與驗證 AAB
```bash
flutter build appbundle --release
```

## 3. 上傳至 Google Play Console
- 登入 [Google Play Console](https://play.google.com/console)。
- 導覽至「測試 ➔ 內部測試 (Internal Testing)」。
- 建立新版本並上傳產出的 `build/app/outputs/bundle/release/app-release.aab`。
- 驗證 Google Play Integrity 與 App Bundle 報表。
