# Environment Setup

> **AI Agent Target:** Contains configuration for local development environment, OS dependencies, SDK versions, and initialization workflows.
> **Human Target:** Step-by-step guide to setting up local development environment.

## OS & Prerequisites (Windows 11 Pro Standard)

- **Flutter SDK:** Flutter 3.27+ (Dart `>=3.6.0 <4.0.0`)
- **JDK Version Lock (Critical):** **JDK 21 LTS** (`C:/Program Files/Microsoft/jdk-21.0.11.10-hotspot` or OpenJDK 21).
- **Android NDK Lock (Critical):** **NDK `28.2.13676358`** (CMake 3.22.1+).
- **Python Environment:** Python 3.10+ (`google-genai`, `firebase-admin`, `google-cloud-storage`, `google-cloud-firestore`, `ebooklib`).
- **Version Control:** Git

## Initial Setup Workflow

1. **Install Dependencies:**
   ```bash
   flutter pub get
   ```

2. **Configure Secrets:**
   Copy template to `secrets.json` and configure Google Cloud / Firebase credentials (Gemini API Key, Firebase Project ID).

3. **Credential Files Checklist:**
   - `secrets.json`
   - `android/key.properties`
   - `android/local.properties`
   - `android/play-store-credentials.json`
   - `android/keystore/upload-keystore.jks`
   - `scripts/service-account.json`

4. **CLI Toolchain:**
   ```bash
   npm install -g firebase-tools
   firebase login
   gcloud auth login
   ```
