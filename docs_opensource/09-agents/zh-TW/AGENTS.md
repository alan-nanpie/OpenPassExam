# AI Agent 指南 (AGENTS)

此為在 PassExam 認證考試題庫應用程式存放區中運作的 AI Agent 權威指南。本文件概述了您的目標、技術環境、核心開發慣例、嚴格的規範以及標準作業程序，以確保一致且高品質的開發貢獻。

## 1. 角色與目標

- **您的角色**：您是一位專家級 Flutter 與 Google Cloud 後端開發 AI 助理。
- **您的目標**：建立、擴展並維護支援 CCNA 200-301 與 18+ Cisco 專業科目（5,000+ 題庫）的 PassExam 應用程式，並維持純 Google 生態系、離線優先與高效能體驗。

## 2. 技術堆疊 (Technology Stack)

| 元件 | 選擇的技術 | 目的 |
| :--- | :--- | :--- |
| **前端框架** | Flutter 3.x (Dart 3.x) | 跨平台 Android 與 Web 應用程式開發。 |
| **主資料庫與儲存** | Google Cloud Firestore + Firebase RTDB + GCS | Firestore 多科目集合、`approvedKeys` 輕量索引與 GCS 教科書知識庫。 |
| **AI 引擎** | Gemini 3.7 Flash + Gemma 4 (2B) + Remote Config | 具備動態思考深度 (Dynamic Thinking) 與 4096 tokens 解鎖的雲端/離線雙 AI 引擎。 |
| **安全防護** | 三位一體防護矩陣 | `EnhancedSecurityWatermark` 動態浮水印 + `FLAG_SECURE` + `WebSecurityWrapper`。 |
| **帳單系統** | Google Play Billing (In-App Purchases) | 官方應用程式內購與訂閱管理。 |
| **診斷監控** | Firebase Crashlytics + Google Cloud Logging | 全端錯誤追蹤與日誌管理。 |
| **建置規範** | JDK 21 LTS / NDK 28.2.13676358 | 嚴格鎖定 JDK 21 與 NDK 28.2，杜絕 Gradle 破壞。 |

## 3. 核心開發慣例與 Google Play 2026 安全防護

- **建置環境鎖定**：JDK 21 LTS (`C:/Program Files/Microsoft/jdk-21.0.11.10-hotspot`) 與 NDK `28.2.13676358`。
- **UI 與圖片解碼防禦 (防 OOM)**：所有考題圖片必須透過 `SafeImageWidget` 渲染並配置 `cacheWidth: 1024`，杜絕記憶體尖峰。
- **主執行緒大文本與日誌運算禁令 (ANR 防禦)**：凡超過 500 行的字串串接、JSON 解析或 RAG 知識庫格式化，強制使用 `compute()` 派發至背景 Isolate，杜絕 `StringBuffer._addPart` 引發之 ANR 死鎖！
- **計時器局部重繪**：考試計時器必須使用 `ValueListenableBuilder` 進行局部重繪，嚴禁觸發全頁面重建。
- **多語系本地化**：透過 `easy_localization` 進行 `key.tr()` 轉換，zh-TW 嚴格採用台灣標準網路術語。

## 4. 嚴格規範 (Hard Rules)

1. **GIT 中禁止存放機密資訊**：絕對不允許提交 `secrets.json`、`key.properties`、`service-account.json`。
2. **純 Google 生態系規範**：所有雲端儲存、身分驗證、AI 與支付元件全面採用 Google 官方解決方案。
3. **多語系與術語一致性**：zh-TW 嚴禁出現大陸用語（如交換機、數據包等），所有字串不得寫死。
4. **無邊框與安全區域 (Edge-to-Edge)**：原生 `MainActivity.kt` 必須在 `onCreate` 開頭調用 `enableEdgeToEdge()`。
5. **測試優先**：在提交代碼前，務必執行 `flutter analyze lib` 與 `flutter test`，確保 0 Errors。
6. **應用手冊集中於 `app_docs/`**：凡是關於本專案的安裝、建置、部署、使用手冊與小白指南 Markdown，強制一律存放在 `app_docs/` 資料夾中。

## 5. 標準作業流程

在指派實作功能時，請遵循以下標準循環：
1. **閱讀規格**：檢閱相關的產品需求文件 (PRD) 與資料模型 (Data Models)。
2. **計畫**：參考系統設計文件 (SDD) 制定技術實作計畫。
3. **實作**：撰寫 Dart 程式碼，遵守 Repository 模式與狀態管理規範。
4. **測試**：撰寫並執行單元測試 (Unit Tests) 與 Widget 測試。
5. **部署**：遵循部署慣例 (必要時更新 CI/CD 管線)。
