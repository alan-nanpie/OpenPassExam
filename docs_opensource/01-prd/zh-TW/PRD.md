# 產品需求文件 (PRD) - PassExam

## 1. 產品願景與目標

### 1.1 問題陳述
準備各類專業認證考試（如 Cisco CCNA/CCNP、雲端架構、資訊安全等）的過程通常所費不貲，官方教材篇幅浩瀚、各考科題庫分散且缺乏智慧化引導。傳統題庫 App 多為單一科目、靜態解析，既無法提供跨領域通用學習支援，也缺乏能配合個人化進度手把手教學的 AI 助教。

### 1.2 解決方案
**PassExam** 是一個開源、跨領域、結合最新 Google AI 旗艦推理（Gemini 3.7 Flash Dynamic Thinking）與端側離線模型（Gemma 4 2B）、支援 Google Cloud Firestore 本地優先離線持久化快取的多科目認證練習與學習輔助平台。系統內建 18+ Cisco 專業科目題庫（5,000+ 題）、NotebookLM 學習工作區（直連 GCS 官方教科書精華知識庫）、上下分屏圖文對照檢視系統、企業級三位一體防側錄矩陣，以及 Google Play 圖書與語音有聲書全自動化發布工具鏈。

### 1.3 目標市場
準備 IT 網路（CCNA/CCNP/CCIE）、雲端架構（GCP/AWS/Azure）、資安與各類專業技術認證的考生、在職工程師與自學人員。

### 1.4 成功指標
*   **學習成效：** 模擬考通過率與錯題消滅率提升 > 40%。
*   **AI 助教滿意度：** Gemini 3.7 Flash 生活化比喻與手把手 CLI 指令指引滿意度 > 95%。
*   **離線強韌性：** 在完全斷網狀態下，題庫與端側 Gemma 4 仍能維持 100% 正常運作。
*   **內容覆蓋率：** 涵蓋 18+ 主流專業認證科目，題庫總量達 5,000+ 題。

---

## 2. 目標用戶 (用戶角色)

1.  **考生 (主要用戶)：** 練習 18+ 科目題庫、進行計時模擬考、複習錯題，透過 NotebookLM 工作區研讀官方教材，並利用 AI 家教獲取深入淺出的生活化概念解析與 CLI 逐步指引。
2.  **管理員 (Admin)：** 管理題庫 CRUD、進行 AI 模型與 Firebase Remote Config 全域廣播/本機覆寫調度、維護社群審核 (Community Approval)、重設裝置綁定與設定全域安全規則。
3.  **訪客 (Guest)：** 註冊前體驗部分樣題與介面。
4.  **內部測試人員 (Internal Tester)：** 測試 Google Play 內部測試版本、驗證最新 Gemini 3.7 思考深度與實驗性功能。
5.  **公開測試人員 (Public Tester)：** 參與 Beta 測試，驗證離線 Firestore 快取同步與端側 Gemma 4 表現。
6.  **檢視者 / 待審核者：** 帳號審核中或受稽核之唯讀使用者。

---

## 3. 用戶故事

| 角色 | 動作 (我想要...) | 效益 (以便於...) |
| :--- | :--- | :--- |
| **考生** | 自由切換 18+ Cisco 與專業認證科目 | 我可以在同一個 App 內準備多張專業認證。 |
| **考生** | 在考題中開啟上下分屏圖文對照視窗 | 邊對照複雜拓撲圖邊閱讀題目與多語系解析，無需來回滾動。 |
| **考生** | 點擊「☁️ 載入 Google 雲端官方 RAG 精華知識庫」 | 2 秒內瞬間載入官方 4 大教科書 6,688 個高品質切片進行研讀。 |
| **考生** | 獲得以「生活化通俗比喻」破題的 AI 深度解析 | 即使無深厚電腦背景也能 1 秒秒懂網路核心觀念。 |
| **考生** | 在離線狀態下使用 Gemma 4 獲取長篇完整解析 | 不受 200 字限制與斷網影響，產出完整 5 階段解析與 CLI 範例。 |
| **考生** | 使用 NotebookLM 學習工作區 5+1 大 Studio 工具 | 自訂聚焦指示產出專屬研讀指南、FAQ、CLI 速查表與學習卡。 |
| **考生** | 進行 50 題計時模擬考並覆蓋動態個人化浮水印 | 體驗全真考場情境，同時保障考題內容安全。 |
| **管理員** | 在 App 內「AI 模型與 Remote Config 管理」切換模型與參數 | 動態下發 `gemini-3.7-flash` 或自訂模型，無需重新發布 App。 |
| **管理員** | 針對 Cloud Firestore 科目執行一鍵批次審核 (Approve All) | 高效管理龐大多科目題庫與社群貢獻。 |
| **出版者** | 執行自動化圖書腳本產出 EPUB 3 與語音有聲書套件 | 批次發布至 Google Play 圖書並自動生成語音旁白有聲書。 |

---

## 4. 功能需求 (FR)

### 4.1 認證與多角色授權
*   **P0:** 支援 Google 登入與 Email/密碼登入 (Firebase Authentication)。
*   **P0:** 角色基礎存取控制 (RBAC)，支援 6 種角色（Admin, Viewer, Pending, InternalTester, PublicTester, Guest）。
*   **P1:** 單一裝置綁定 (Active Device ID 追蹤) 與防共用安全鎖定。

### 4.2 多科目考試練習與圖文對照
*   **P0:** 支援 18+ 認證科目（CCNA 200-301、CCNP 300-215、300-410、300-435、350-401、350-601 等 5,000+ 題）。
*   **P0:** 支援 4 種題型（單選、複選、拖曳、實作模擬）。
*   **P0:** 全平台考題圖片常駐懸浮預覽與上下分屏圖文對照檢視視窗 (`QuestionImageReferenceDialog`)，支援深淺色主題高對比渲染。
*   **P0:** 答案即時驗證、多語系解析切換（英、日、繁中、簡中）與「從考題中學習英文」語法分析。

### 4.3 全真模擬考
*   **P0:** 自訂考題數（10/30/50/100 題）與視覺化倒數計時器。
*   **P0:** 計時器局部重繪（`ValueListenableBuilder`），杜絕全頁刷新與圖片解碼抖動。
*   **P1:** 領域診斷報告與歷史戰績追蹤。

### 4.4 錯題消滅與弱點強化
*   **P0:** 自動收集錯題並依錯誤頻率/領域分群。
*   **P1:** 錯題重複測驗與答對自動移出機制。

### 4.5 雙 AI 引擎與四層階層調度
*   **P0:** 雲端旗艦 **Gemini 3.7 Flash**（Dynamic Thinking 混合推理、過濾 `thought: true`、自適應 Temperature 1.0）。
*   **P0:** 四層階層式 AI 調度：`本機覆寫 ➔ RTDB 廣播 ➔ Remote Config ➔ 內建預設值`。
*   **P0:** 端側離線 **Gemma 4 (2B)**：輸出預算鎖定 4096 tokens，解除字數截斷，支援生活化比喻與手把手 Cisco CLI 實戰逐步指引。
*   **P1:** 雙軌 Persona：教材庫切片不足時自動無縫切換為「業界頂尖顧問 / CCIE 首席架構專家」。

### 4.6 通用 NotebookLM 學習工作區與 GCS RAG 知識庫
*   **P0:** 跨領域通用學習工作區，支援 Markdown 表格與代碼高亮。
*   **P0:** 一鍵直連 GCS 雲端載入 6,688 個去雜訊高精度官方教科書切片。
*   **P0:** 四層防禦 RAG 管道（智慧頁面分類、5 大維度品質評分、頁面範圍過濾、檢索端品質加權）。
*   **P1:** 5+1 大 Studio 工具（研讀指南、FAQ、簡介、時間軸、速查表、自訂專屬產出 Custom Artifact）與自訂聚焦提示詞。

### 4.7 搜尋與向量檢索
*   **P1:** 多欄位條件過濾（題號、題型、領域、圖片）。
*   **P2:** 768 維度 AI 向量語意檢索 (Vertex AI Vector Search / Firestore Vector Search)。

### 4.8 官方金流與訂閱系統
*   **P0:** 官方 Google Play Billing 整合 (Play In-App Purchases & Subscriptions)。
*   **P1:** 訂閱週期管理與購買恢復。

### 4.9 管理員專屬控制台
*   **P0:** 考題 CRUD 編輯器（支援 snake_case 與 camelCase 雙格式）。
*   **P0:** 「🤖 AI 模型與 Remote Config 管理」介面（視覺化調控模型代號、溫度與 Max Tokens）。
*   **P0:** 社群題目審核與一鍵全部核准 (Approve All)。

### 4.10 Google Play 圖書與語音有聲書發布工具鏈
*   **P1:** 全量考題與圖表自動提取 (`fetch_firestore_books.py`)。
*   **P1:** EPUB 3 標準電子書編譯與語音無障礙導讀標籤 (`build_ccna_epub.py`)。
*   **P1:** ONIX 3.0 與 Google Play Books 批次上架中繼資料套件 (`publish_to_play_books.py`)。

---

## 5. 非功能需求 (NFR)

*   **效能與安全防護 (Google Play 2026 品質標準)：**
    *   冷啟動時間 < 2.5 秒，列表滑動穩定 60fps。
    *   Android 15/16 (API 35+) 全面支援 Edge-to-Edge 沉浸式無邊框。
    *   `SafeImageWidget` 鎖定 `cacheWidth: 1024` 進行解碼降取樣，杜絕圖片解碼 OOM。
    *   主執行緒大文字與日誌串接全面使用 `compute()` 派生 Isolate，防止 Samsung 與 Android 16 主執行緒 `StringBuffer._addPart` ANR 死鎖。
*   **三位一體安全矩陣 (Defense-in-Depth)：**
    *   1. 動態個人化浮水印 (`EnhancedSecurityWatermark`)：8 列 4 欄 UID 姓名浮水印，防實體側錄。
    *   2. 原生安全防護 (`SecureScreenService`)：`FLAG_SECURE` 防截圖、防螢幕錄影、防投影。
    *   3. Web 端安全防禦 (`WebSecurityWrapper`)：禁用右鍵選單、禁用複製、DevTools 開發者工具開啟即時監控。
    *   NTP 防竄改時間驗證、Google Play Integrity 與單一裝置綁定。
*   **多層級資料庫強韌性：**
    *   Google Cloud Firestore (多科目集合分區) + Firebase RTDB (approvedKeys 索引) + Firestore 原生離線持久化快取。
*   **多語系在地化：**
    *   四國語系 (en, ja, zh_TW, zh_CN)，繁體中文嚴格對齊台灣網路專業術語。

---

## 6. 免責聲明與商標宣告

PassExam 乃獨立之學習與認證備考輔助平台。Cisco®、CCNA®、CCNP® 與 CCIE® 為 Cisco Systems, Inc. 之註冊商標。本平台與 Cisco Systems, Inc. 無任何隸屬、贊助或官方背書關係。
