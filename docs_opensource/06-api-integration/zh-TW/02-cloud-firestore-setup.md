# Google Cloud Firestore 設定指南

## 1. 帳號與專案架構
PassExam 全面採用 Google Cloud Firestore 作為主力核心資料庫，支援多科目集合分區、原生離線持久化與 Vertex AI 向量檢索整合：
- **核心集合分區 (`exam_subjects/`)**：
  - 存放 CCNA 200-301 與 18+ Cisco 專業科目 (`cisco-300-*`, `cisco-350-*` 等 5,000+ 題) 考題庫。
  - 採用結構化 Collections 與 Sub-collections 進行科目層級隔離。
- **社群審核與狀態 (`question_reviews/`)**：
  - 存放社群提交與管理員批次審核流程 (Community Approval)。
- **使用者設定檔與作答紀錄 (`users/{uid}/exam_sessions`)**：
  - 儲存個人化學習進度、錯題本與模擬考成績。

## 2. 資料庫綱要與安全性規則 (Firestore Security Rules)
- 啟用 Firestore 向量檢索擴充功能 (Firestore Vector Search / Vertex AI Extension)，支援 768 維度語意向量檢索。
- 建立 `questions` 文件綱要（支援 `camelCase` 與 `snake_case` 相容欄位）與 `users` 使用者權限表。
- 設定基於 Firebase Auth Custom Claims 的安全性規則，確保未審核題目僅管理員可存取。

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /exam_subjects/{subjectId}/questions/{questionId} {
      allow read: if request.auth != null && (resource.data.isApproved == true || request.auth.token.role == 'admin');
      allow write: if request.auth != null && request.auth.token.role == 'admin';
    }
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## 3. SDK 安裝與客戶端初始化
### pubspec.yaml 依賴項目
```yaml
dependencies:
  cloud_firestore: ^5.6.0
  firebase_auth: ^5.5.0
```

### 程式碼初始化與 RepositoryFactory 路由
```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreQuestionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getQuestions(String subjectId) async {
    final snapshot = await _firestore
        .collection('exam_subjects')
        .doc(subjectId)
        .collection('questions')
        .where('isApproved', isEqualTo: true)
        .get(const GetOptions(source: Source.cacheServer)); // 優先快取，無縫離線
    return snapshot.docs.map((doc) => doc.data()).toList();
  }
}
```

## 4. 必要的環境變數
| 變數 | 說明 |
|---|---|
| `GCP_PROJECT_ID` | Google Cloud 專案識別碼 |
| `FIRESTORE_DATABASE_ID` | Firestore 資料庫 ID (預設為 `(default)`) |
| `GOOGLE_APPLICATION_CREDENTIALS` | 伺服器端管理員服務帳戶金鑰路徑 |

## 5. Google Cloud Functions (2nd gen) / Cloud Run
透過 Firebase CLI / gcloud 部署無伺服器後端函式：
1. `generateEmbeddings`：調用 Gemini 產生 768 維向量嵌入並寫入 Firestore。
2. `searchQuestionsSemantic`：執行 Vertex AI Vector Search 向量相似度比對。
3. `syncUserRoles`：更新使用者 Custom Claims 與權限紀錄。
4. `processPlayBillingWebhook`：處理 Google Play 即時開發者通知 (RTDN)。
5. `exportUserData`：產出個人學習歷程 JSON/CSV 封裝至 Google Cloud Storage。

## 6. 常見問題排除
- **複合查詢索引缺失 (Missing Index)**：點擊 Firebase 控制台日誌中提供的自動索引建立連結即可一鍵建立。
- **離線讀取逾時**：確保已在初始化時配置 `persistenceEnabled: true`。
