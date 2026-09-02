# 07. 離線同步架構 (Offline Sync Architecture)

## 1. Cloud Firestore 原生離線持久化
PassExam 捨棄第三方同步中繼，全面採用 Google Cloud Firestore 原生離線持久化快取 (Persistent Cache)：
- **本機快取索引**: 自動於裝置端建立持久化索引，支援離線過濾、領域篩選與錯題複習。
- **寫入佇列 (Mutation Queue)**: 離線作答時立即樂觀更新 UI，資料排入本機寫入佇列，連線後自動背景同步至雲端。
- **零額外伺服器成本**: 無需維護第三方中繼節點，降低架構複雜度與故障率。
