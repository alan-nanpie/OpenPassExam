# Cloud Firestore 原生離線持久化與快取同步設定指南

## 1. 架構概述
PassExam 採用 Google Cloud Firestore 原生離線持久化快取 (Persistent Cache) 與本機優先機制，提供 100% 斷網容錯與零伺服器維護成本的極致離線刷題體驗：
- **原生快取架構**：Firestore 自動在裝置端維護 IndexedDB (Web) 或 SQLite 原生快取 (Android)。
- **離線查詢能力**：支援離線過濾、領域篩選、已作答紀錄比對與錯題查詢。
- **自動背景雙向同步**：在網路恢復時自動上傳離線作答進度並套用衝突解決機制。

## 2. 快取設定與初始化
在應用程式啟動時啟用無上限快取容量設定：

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

void setupFirestoreOfflineCache() {
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
}
```

## 3. 離線資料束 (Data Bundles) 預載機制
管理員可透過 Cloud Functions 預先編譯包含熱門考科題庫的 Firestore Bundle，客戶端啟動時僅需單次下載即可永久離線使用：

```dart
Future<void> preloadOfflineExamBundle(String bundleUrl) async {
  final response = await http.get(Uri.parse(bundleUrl));
  if (response.statusCode == 200) {
    final LoadBundleTask task = FirebaseFirestore.instance.loadBundle(response.bodyBytes);
    await task.stream.last;
  }
}
```

## 4. 離線優先查詢策略
```dart
Future<List<Question>> fetchQuestionsOfflineFirst(String subjectId) async {
  final query = FirebaseFirestore.instance
      .collection('exam_subjects')
      .doc(subjectId)
      .collection('questions')
      .where('isApproved', isEqualTo: true);

  try {
    // 優先從本地快取瞬間載入 (0ms 延遲)
    final cacheSnapshot = await query.get(const GetOptions(source: Source.cache));
    if (cacheSnapshot.docs.isNotEmpty) {
      return cacheSnapshot.docs.map((d) => Question.fromFirestore(d)).toList();
    }
  } catch (_) {
    // 快取為空時 fallback 至伺服器
  }

  final serverSnapshot = await query.get(const GetOptions(source: Source.serverAndCache));
  return serverSnapshot.docs.map((d) => Question.fromFirestore(d)).toList();
}
```

## 5. 常見問題排除
- **快取容量控管**：預設使用無上限快取 (`CACHE_SIZE_UNLIMITED`)，如需限制可設定特定位元組上限 (如 `100 * 1024 * 1024`)。
- **離線寫入排隊**：所有離線提交的作答紀錄會保留在本地寫入佇列中，連線後自動送出。
