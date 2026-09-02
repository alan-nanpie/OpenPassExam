# ADR-001: Google Cloud 多層級資料庫架構 (Google Cloud Multi-Tier Database Architecture)
## 狀態: 已接受 (Accepted)
## 日期: 2026-09-01
## 背景 (Context)
PassExam 應用程式需要同時支援 CCNA 200-301 與 18+ Cisco 專業科目（5,000+ 題庫），並滿足高併發使用者狀態、768 維度 AI 向量搜尋、本地端離線持久化快取與教材知識庫檢索需求。

## 決策 (Decision)
全面採用 Google Cloud 原生多層級資料庫與儲存體系，透過 `RepositoryFactory` 實現智慧路由：
1. **Google Cloud Firestore**: 核心題庫集合 (`exam_subjects`)、使用者紀錄與作答歷程，具備原生離線快取與即時串流。
2. **Firebase RTDB**: 使用者連線狀態、輕量化 `approvedKeys` 索引節點與全域 AI 模型配置廣播 (`ai_model_config`)。
3. **Google Cloud Storage (GCS)**: 存放 6,688 個官方教科書 RAG 精華切片與考題網路拓撲圖檔。
4. **Vertex AI Vector Search / Firestore Vector Search**: 支援 768 維度向量嵌入語意搜尋。
5. **Google BigQuery**: 巨量學習分析與題庫品質報表。

## 考慮過的替代方案 (Alternatives Considered)
- **非 Google 第三方資料庫架構**:
  - 缺點：跨雲連線延遲高、多套憑證管理繁瑣、存在第三方服務中斷與依賴風險。
- **純 Google Cloud 整合架構 (最終方案)**:
  - 優點：單一 Google Cloud 專案統一管理 IAM 與安全性規則、網路連線極低延遲、原生支援 Firebase SDK 與 Google AI 生態系。

## 後果 (Consequences)
- **正面影響**: 架構簡潔、零第三方後端依賴、安全性由 Google Cloud IAM 與 Security Rules 統一守護。
- **負面影響**: 開發者需熟悉 Firebase 與 Google Cloud 控制台設定。
