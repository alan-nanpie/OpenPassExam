# 更新日誌 (Changelog)

## [2.0.0] - 2026-09-01
### 全面升級至純血 Google Cloud 與 AI 生態系 (Google Cloud Native Architecture)
- **資料庫全面重構**: 採用 Google Cloud Firestore 進行多科目集合分區與原生離線持久化快取。
- **即時索引**: 整合 Firebase Realtime Database `approvedKeys` 輕量索引節點。
- **AI 雙引擎**: 升級為 Google Gemini 3.7 Flash (Dynamic Thinking) 與端側 Gemma 4 (2B) LiteRT (4096 tokens)。
- **向量檢索**: 整合 Google Vertex AI Vector Search / Firestore Vector Search 768 維度語意檢索。
- **官方金流**: 全面整合 Google Play Billing (Play Billing Library 6+)。
- **診斷監控**: 採用 Firebase Crashlytics 與 Google Cloud Logging。
- **安全防護**: Android 15/16 原生 Edge-to-Edge、`FLAG_SECURE` 與動態個人化浮水印。
