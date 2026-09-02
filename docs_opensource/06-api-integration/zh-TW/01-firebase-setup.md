# Firebase 設定指南

## 1. 帳號與專案設定
- 前往 [Firebase Console](https://console.firebase.google.com/) 建立新專案。
- **啟用驗證提供者**：在 Authentication 區塊，啟用 Google 登入、電子郵件/密碼、與匿名登入。
- **啟用 Cloud Firestore**：建立 Firestore 實例（選取預設資料庫或多資料庫模式），設定安全性規則與原生離線持久化快取。
- **建立 Realtime Database**：建立 Realtime Database 實例並部署 `database.rules.json`（包含 `approvedKeys` 輕量索引節點與 `ai_model_config` 全域廣播）。
- **啟用 Remote Config**：啟用雲端參數配置，支援 `gemini-3.7-flash` 模型與思考深度超參數動態發布。
- **啟用 Crashlytics**：導覽至 Crashlytics 並為您的專案啟用，結合 Google Cloud Logging 進行全面診斷。
- **啟用 App Check**：前往 App Check 並使用 Android 的 Play Integrity 以及 Web 的 reCAPTCHA Enterprise 來保護後端 API。

## 2. 控制台/儀表板設定
1. 在 Firebase Console 註冊您的 Android 及 Web 應用程式。
2. 下載 Android 的 `google-services.json` 檔案。
3. **Android 啟動 ANR 死鎖防護**：確保在 `AndroidManifest.xml` 中移除已廢棄之 `FirebaseSessionsRegistrar`，防止 Android 15/16 系統啟動死鎖。

## 3. SDK 安裝
### pubspec.yaml 依賴項目
將以下內容加入 `pubspec.yaml`：
```yaml
dependencies:
  firebase_core: ^3.12.0
  firebase_auth: ^5.5.0
  cloud_firestore: ^5.6.0
  firebase_database: ^11.3.0
  firebase_remote_config: ^5.4.0
  firebase_crashlytics: ^4.3.0
  firebase_app_check: ^0.3.2
  firebase_storage: ^12.4.0
```

### 平台設定
- **Android**：將 `google-services.json` 放置於 `android/app/`。在 `build.gradle` 加上 Google Services 與 Crashlytics Gradle 外掛程式。
- **Web**：在 `web/index.html` 加入 Firebase 初始化設定或於 Dart 程式碼中使用 `DefaultFirebaseOptions.currentPlatform`。

## 4. 程式碼整合
```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化 Firebase
  await Firebase.initializeApp();
  
  // 設定 Firestore 離線持久化快取 (Unlimited Persistent Cache)
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  
  // 註冊 Crashlytics 錯誤處理程序
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  
  runApp(const MyApp());
}
```

## 5. 必要的環境變數
| 變數 | 說明 |
|---|---|
| `FIREBASE_API_KEY` | Firebase 專案的 API 金鑰 |
| `FIREBASE_APP_ID` | Firebase 專案的 App ID |
| `FIREBASE_MESSAGING_SENDER_ID` | 訊息發送者 ID |
| `FIREBASE_PROJECT_ID` | Google Cloud / Firebase 專案 ID |
| `FIREBASE_DATABASE_URL` | Firebase RTDB 實例 URL |

## 6. 安全性規則
透過 Firebase CLI 部署 `database.rules.json` 與 `firestore.rules`。

```json
{
  "rules": {
    ".read": "auth != null",
    ".write": "auth != null && root.child('users').child(auth.uid).child('role').val() == 'admin'"
  }
}
```

## 7. 常見問題排除
- **遺失 google-services.json**：確保該檔案精確地放置於 `android/app/` 目錄中。
- **App Check 阻擋請求**：確保您在 Firebase Console 已註冊正確的 SHA-256 簽署憑證指紋。
