# Firebase Setup Guide

## 1. Account & Project Setup
- Go to [Firebase Console](https://console.firebase.google.com/) and create a new project.
- **Enable Auth Providers**: In Authentication, enable Google Sign-In, Email/Password, and Anonymous sign-in.
- **Enable Cloud Firestore**: Create a Firestore instance, configure security rules, and enable native offline persistence.
- **Create Realtime Database**: Create an RTDB instance and deploy `database.rules.json` (including `approvedKeys` lightweight index nodes and `ai_model_config` broadcasts).
- **Enable Remote Config**: Configure cloud parameters for dynamic `gemini-3.7-flash` model and thinking depth rollout.
- **Enable Crashlytics**: Navigate to Crashlytics and enable it for your project, integrated with Google Cloud Logging.
- **Enable App Check**: Go to App Check and register your app using Play Integrity for Android and reCAPTCHA Enterprise for Web.

## 2. Console / Dashboard Configuration
1. Register your Android and Web apps in the Firebase Console.
2. Download `google-services.json` for Android.
3. **Android Startup ANR Defense**: Ensure deprecated `FirebaseSessionsRegistrar` is removed from `AndroidManifest.xml` to prevent Android 15/16 startup deadlocks.

## 3. SDK Installation
### pubspec.yaml Dependencies
Add the following to `pubspec.yaml`:
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

### Platform Configuration
- **Android**: Place `google-services.json` in `android/app/`. Add Google Services and Crashlytics plugins in `build.gradle`.
- **Web**: Add Firebase initialization config in `web/index.html` or configure via Dart `DefaultFirebaseOptions.currentPlatform`.

## 4. Code Integration
```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Configure Firestore Native Offline Persistence
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  
  // Register Crashlytics fatal error handler
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  
  runApp(const MyApp());
}
```

## 5. Required Environment Variables
| Variable | Description |
|---|---|
| `FIREBASE_API_KEY` | API Key for Firebase project |
| `FIREBASE_APP_ID` | App ID for Firebase project |
| `FIREBASE_MESSAGING_SENDER_ID` | Messaging Sender ID |
| `FIREBASE_PROJECT_ID` | Google Cloud / Firebase Project ID |
| `FIREBASE_DATABASE_URL` | Firebase RTDB instance URL |

## 6. Security Rules
Deploy `database.rules.json` and `firestore.rules` via Firebase CLI.

```json
{
  "rules": {
    ".read": "auth != null",
    ".write": "auth != null && root.child('users').child(auth.uid).child('role').val() == 'admin'"
  }
}
```

## 7. Troubleshooting
- **Missing google-services.json**: Ensure the file is in `android/app/`.
- **App Check Blocking Requests**: Verify that the correct SHA-256 fingerprint is registered in Firebase Console.
