# 資料庫綱要設定 (Schema Setup)

> **AI Agent Target:** Outlines the initialization sequence and setup commands for Firebase, Google Cloud Firestore, GCS RAG knowledge packs, and BigQuery analytics schemas.
> **Human Target:** 設定 Google Cloud Firestore、Firebase RTDB 索引與 Cloud Storage 的逐步指南。

## 1. Firebase RTDB
Firebase 即時資料庫用於高頻率即時狀態、設定與全域廣播。

- **部署規則:** 部署 `database.rules.json` 以保護節點。
- **輕量索引 (`approvedKeys`):** 建立 `approvedKeys/{examId}/{questionId}` 輕量布林索引，防止客戶端載入全量考題引發記憶體尖峰與 JVM OOM。
- **全域廣播節點:** `ai_model_config` 支援即時廣播主力與降級 AI 模型 (`gemini-3.7-flash`, `gemini-2.5-flash`)。

## 2. Google Cloud Firestore 核心題庫架構
- **集合階層結構 (`exam_subjects/{subjectId}/questions/{questionId}`)：**
  - 存放 CCNA 200-301 與 18+ Cisco 專業科目 (`cisco-300-*`, `cisco-350-*` 等 5,000+ 題)。
  - 整合 Vertex AI 向量擴充套件，建立 768 維度向量嵌入索引。
  - 與使用者進度資料夾實施集合隔離，由 `RepositoryFactory` 自動路由。

## 3. Google Cloud Storage (GCS)
存放 6,688 個官方教材 RAG 精華知識庫切片與高解析度考題網路拓撲圖。

## 4. Cloud Firestore 原生離線持久化快取 (Persistent Cache)
- 客戶端啟用 `persistenceEnabled: true` 與 `CACHE_SIZE_UNLIMITED`，支援無縫斷網作答與連線後自動背景增量同步。
