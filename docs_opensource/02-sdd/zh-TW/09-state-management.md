# 09. 狀態管理 (State Management)

## 1. ChangeNotifier 與 Provider 模式
- **Controllers**: `ExamController`, `AiTutorController`, `AuthController`, `SettingsController`。
- **即時串流監聽**: 監聽 Cloud Firestore Snapshots 與 Firebase RTDB `approvedKeys` 節點。

## 2. 效能與 ANR 防禦規範
- **`SafeImageWidget`**: 鎖定 `cacheWidth: 1024`，防止考題拓撲大圖引發 JVM OOM。
- **`compute()` Isolate 隔離**: 超過 500 行的日誌串接與 RAG 格式化強制於背景 Isolate 運算，杜絕 `StringBuffer._addPart` ANR 死鎖。
- **計時器局部重繪**: 測驗倒數計時器使用 `ValueListenableBuilder` 局部更新。
