# ADR-002: Cloud Firestore 原生離線持久化與本地快取策略 (Offline-First Persistence Strategy)
## 狀態: 已接受 (Accepted)
## 日期: 2026-09-01
## 背景 (Context)
考生經常在通勤、機艙或無網路環境中進行認證考試練習。應用程式必須提供 100% 可靠的離線作答能力，並在連線恢復時無損同步。

## 決策 (Decision)
全面採用 Google Cloud Firestore 原生離線持久化快取 (Persistent Cache) 與端側 Gemma 4 (2B) 模型：
1. **Firestore 原生持久化**: 啟用 `Settings(persistenceEnabled: true, cacheSizeBytes: CACHE_SIZE_UNLIMITED)`，自動在裝置端建立安全索引快取。
2. **Firestore Data Bundles**: 支援預先編譯題庫 Bundle 一鍵下載至本機快取。
3. **離線 AI 輔導**: 整合 Google Gemma 4 2B (LiteRT)，於斷網狀態下提供 4096 tokens 長篇概念解析與 Cisco CLI 指令引導。

## 考慮過的替代方案 (Alternatives Considered)
- **第三方中繼同步方案**:
  - 缺點：需要額外架設第三方中繼伺服器、增加架構複雜度與費用。
- **Google Cloud Firestore 原生持久化快取 (最終方案)**:
  - 優點：零外部伺服器維護成本、SDK 內建自動增量同步與寫入佇列、開箱即用。

## 後果 (Consequences)
- **正面影響**: 真正的離線可用性、即時 UI 反應 (樂觀更新)、極致精簡的基礎設施架構。
