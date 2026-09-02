# 環境設置 (Environment Setup)

> **AI Agent Target:** Contains configuration for local development environment, OS dependencies, SDK versions, and initialization workflows.
> **Human Target:** 建立本地開發環境的逐步指南，包含作業系統相依性與 SDK 版本。

## 作業系統與前置作業 (Windows 11 Pro 標準)

- **Flutter SDK:** Flutter 3.27+ (Dart `>=3.6.0 <4.0.0`)
- **JDK 版本鎖定 (關鍵):** **JDK 21 LTS** (`C:/Program Files/Microsoft/jdk-21.0.11.10-hotspot` 或 OpenJDK 21)。嚴禁使用 Java 25+ 以防 Gradle / Kotlin 崩潰。
- **Android NDK 鎖定 (關鍵):** **NDK `28.2.13676358`**（配合 CMake 3.22.1+）。
- **Python 環境:** Python 3.10+ (包含 `google-genai`, `firebase-admin`, `google-cloud-storage`, `google-cloud-firestore`, `ebooklib`)。
- **版本控制:** Git

## 初次複製設定 (First Clone Setup)

1. **下載相依性 (Fetch Dependencies):**
   ```bash
   flutter pub get
   ```

2. **設定機密資料 (Secrets Setup):**
   從範本建立 `secrets.json`，並填寫所需的 Google Cloud 與 Firebase API 金鑰（Gemini, Firebase Project ID）。

3. **Android 憑證與建置檔案 (Credential Files):**
   請確保以下檔案已配置於本地端：
   - `secrets.json` (根目錄)
   - `android/key.properties`
   - `android/local.properties` (指定 `flutter.sdk` 與 `sdk.dir`)
   - `android/play-store-credentials.json`
   - `android/keystore/upload-keystore.jks`
   - `scripts/service-account.json`

4. **CLI 工具安裝:**
   ```bash
   npm install -g firebase-tools
   firebase login
   gcloud auth login
   ```
