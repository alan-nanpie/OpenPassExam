# OpenPassExam 📝

![License](https://img.shields.io/badge/License-Proprietary%20%2F%20All%20Rights%20Reserved-red.svg)
![Google Cloud](https://img.shields.io/badge/Google%20Cloud-Native%20Ecosystem-4285F4.svg?logo=googlecloud&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-Core%20%7C%20Firestore%20%7C%20RTDB-FFCA28.svg?logo=firebase&logoColor=black)
![Gemini AI](https://img.shields.io/badge/Google%20AI-Gemini%203.7%20Flash%20%26%20Gemma%204-8E75C2.svg?logo=googlegemini&logoColor=white)
![Flutter](https://img.shields.io/badge/Flutter-3.x%20%7C%20Dart%203.x-02569B.svg?logo=flutter&logoColor=white)
![Android 15 Ready](https://img.shields.io/badge/Android%2015%2F16-Edge--to--Edge-brightgreen.svg)

> **PassExam — 全面基於 Google Cloud & Google AI 生態系之跨領域專業認證題庫與智慧學習平台完整架構規範。**
> 
> **PassExam — An open specification and architecture for multi-subject certification practice powered 100% by Google Cloud, Firebase, and Gemini AI.**

---

## 🌟 核心架構亮點 (Key Highlights)

* ☁️ **純血 Google 雲端架構 (Pure Google Cloud Stack)**：
  - **Google Cloud Firestore**：核心考題庫集合分區隔離、原生持久化快取 (Persistent Cache) 與即時串流。
  - **Firebase Realtime Database (RTDB)**：高併發 `approvedKeys` 輕量索引節點與全域 AI 模型配置廣播 (`ai_model_config`)。
  - **Google Cloud Storage (GCS)**：存放 6,688 個官方教科書 RAG 精華切片與高解析度考題拓撲圖檔。
  - **Vertex AI Vector Search / Firestore Vector Search**：768 維度語意向量檢索與考點關聯分析。
* 🤖 **Google 雙 AI 推理引擎 (Hybrid Dual AI Tutor)**：
  - **雲端旗艦**：**Google Gemini 3.7 Flash** (Dynamic Thinking 混合推理、過濾 `thought: true` 思考標記、生活化比喻手把手引導)。
  - **端側離線**：**Google Gemma 4 (2B) LiteRT-LM** (4096 Tokens 預算解鎖、無字數截斷、100% 斷網離線輔導)。
  - **四層階層式 AI 調度**：`本機覆寫 ➔ RTDB 廣播 ➔ Remote Config ➔ 內建預設值`。
* 🛡️ **企業級三位一體安全矩陣 (Triple-Defense Security)**：
  - **動態個人化浮水印** (`EnhancedSecurityWatermark`)：8 列 4 欄 UID / 姓名 / 時間戳記防拍攝。
  - **原生安全鎖定** (`SecureScreenService`)：Android `FLAG_SECURE` 防截圖、防螢幕錄影、防投影。
  - **Web 端安全防禦** (`WebSecurityWrapper`)：防右鍵、防複製、DevTools 審查工具即時監控。
* 💳 **官方 Google Play Billing 帳單系統**：
  - 整合 Google Play Billing Library 6+ 原生應用程式內購與訂閱。
  - Google Cloud Pub/Sub 即時開發者通知 (RTDN) 與 Firebase Functions 後端防偽驗證。
* 📖 **Google Play Books 與語音有聲書發布工具鏈**：
  - EPUB 3 電子書編譯器 (`build_ccna_epub.py`) 與 ONIX 3.0 自動化上架套件。

---

## 📖 應用程式手冊與快速上手 (`app_docs/`)

所有關於本應用程式的安裝、建置、雲端部署與小白新手指南，均統一收錄於 [`app_docs/`](./app_docs/)：

- 🌟 **[01-新手零基礎全圖文指南](./app_docs/01-新手零基礎全圖文指南.md)**：最直白的免安裝網頁版、Android 安裝與一鍵發布說明。
- 💻 **[02-開發者與進階安裝建置指南](./app_docs/02-開發者與進階安裝建置指南.md)**：開發環境配置、Flutter 編譯與測試步驟。
- ☁️ **[03-Google-Cloud-Run部署維運指南](./app_docs/03-Google-Cloud-Run部署維運指南.md)**：Docker 容器化與 Cloud Run 自動化上架。
- 🤖 **[AI_AGENT_DOC_RULES](./app_docs/AI_AGENT_DOC_RULES.md)**：AI Agent 手冊存放與維護規範。

---

## 📂 完整技術文檔地圖 (Documentation Map)

全套完整雙語（繁體中文 `zh-TW` 與英文 `en`）技術文檔收錄於 [`docs_opensource/`](./docs_opensource/)：

```text
app_docs/                        # 應用程式安裝、建置、部署與新手操作手冊 (AI & 用戶必看)
docs_opensource/                 # 開源架構與系統全規格技術庫
├── INDEX.md                     # 完整雙語文檔索引導覽
├── 01-prd/                      # 產品需求文件 (PRD)
├── 02-sdd/                      # 系統設計文件 (SDD 01-11: 架構、模型、資料庫、AI、離線、金流)
├── 03-bdd/                      # 行為驅動規格 (BDD 12 大 Feature 檔案)
├── 04-test-spec/                # 測試規範 (單元測試、Widget、整合、E2E、測試矩陣)
├── 05-ui-ux/                    # UI/UX 設計系統與畫面規格
├── 06-api-integration/          # API 整合設定 (Firebase, Firestore, GCS, Play Billing, AdMob, Gemini)
├── 07-deployment/               # 部署運維 (環境設置、建置設定、Cloud Build CI/CD、Web 部署)
├── 08-database/                 # 資料庫維護 (種子資料匯入、AI 分類、向量檢索、RTDB 索引同步)
├── 09-agents/                   # AI Agent 權威開發指南 (AGENTS.md)
├── 10-adr/                      # 架構決策記錄 (ADR-001 至 ADR-006)
└── 11-open-source/              # 開源指南、快速上手、更新日誌與安全性政策
```

👉 **[點此進入完整文檔首頁 (Documentation Index)](./docs_opensource/INDEX.md)**

---

## 📄 版權宣告與使用授權 (Copyright & License)

**Copyright (c) 2026 alan-nanpie / PassExam. All Rights Reserved.**
**版權所有 (c) 2026 alan-nanpie / PassExam。保留所有權利。**

本專案採用最嚴格之**全權利保留專有原始碼檢視授權 (Strict Proprietary & Source-Available License)**：
- 僅供公開檢閱、學習參考與架構研究。
- ❌ **嚴禁任何未經書面授權之商業利用、付費課程、訂閱服務或盈利行為**。
- ❌ **嚴禁未經授權之再散布、轉載、分叉發布 (Fork Redistribution) 或二次包裝**。
- ❌ **嚴格禁止將本專案任何內容用於 AI / 機器學習模型訓練、資料集抓取或微調**。

詳細條款請參閱 [LICENSE](./LICENSE)。

---

## ⚖️ 免責聲明與商標宣告 (Disclaimer & Trademarks)

PassExam 乃獨立之技術架構與學習備考輔助資源。Cisco®、CCNA®、CCNP® 與 CCIE® 為 Cisco Systems, Inc. 之註冊商標；Google、Google Cloud、Firebase、Gemini、Gemma、Google Play 均為 Google LLC 之商標或註冊商標。本專案與上述公司無任何官方隸屬、背書或贊助關係。\n