# Google Cloud Storage (GCS) 設定指南

## 1. 帳號與儲存庫架構
Google Cloud Storage (GCS) 用於存放官方教材 RAG 精華知識庫、考題拓撲圖檔與電子書發布套件：
- **RAG 知識庫儲存桶 (`passexam-rag-knowledge`)**：
  - 存放 6,688 個高品質官方教科書切片 JSON 檔，供 NotebookLM 學習工作區直連載入。
- **考題媒體儲存桶 (`passexam-media-assets`)**：
  - 存放考題網路拓撲圖、架構圖，支援 CDN 高速快取與 `SafeImageWidget` 降取樣渲染。
- **電子書與出版封裝 (`passexam-publication-artifacts`)**：
  - 存放自動化工具鏈編譯之 EPUB 3 與 Google Play 圖書 ONIX 3.0 上架封裝。

## 2. 儲存貯體設定與存取權限
- 前往 [Google Cloud Storage 控制台](https://console.cloud.google.com/storage)。
- 建立具備標準儲存類別 (Standard Storage) 的儲存桶，位置設定為亞太地區 (如 `asia-east1`)。
- 設定 CORS 規則以允許 Web 端與行動端安全讀取圖片與 RAG 切片：
```json
[
  {
    "origin": ["*"],
    "method": ["GET", "HEAD"],
    "responseHeader": ["Content-Type", "Access-Control-Allow-Origin"],
    "maxAgeSeconds": 3600
  }
]
```

## 3. SDK 安裝
### Flutter 客戶端
```yaml
dependencies:
  firebase_storage: ^12.4.0
```

### Python 自動化腳本
```bash
pip install google-cloud-storage google-genai
```

## 4. 程式碼整合
### Flutter 客戶端載入 RAG 知識庫切片
```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<Map<String, dynamic>>> loadGcsRagChunks(String gcsPublicUrl) async {
  final response = await http.get(Uri.parse(gcsPublicUrl));
  if (response.statusCode == 200) {
    final List<dynamic> rawList = json.decode(utf8.decode(response.bodyBytes));
    return rawList.cast<Map<String, dynamic>>();
  }
  throw Exception('載入 GCS RAG 知識庫失敗: ${response.statusCode}');
}
```

## 5. 必要的環境變數
| 變數 | 說明 |
|---|---|
| `GCS_RAG_BUCKET_NAME` | RAG 知識庫 GCS 儲存貯體名稱 |
| `GCS_PUBLIC_URL` | 公開教材 JSON 與媒體資源基礎 URL |
| `GOOGLE_APPLICATION_CREDENTIALS` | 管理員服務帳戶金鑰路徑 |

## 6. 常見問題排除
- **CORS 跨來源錯誤**：使用 `gcloud storage buckets update gs://<BUCKET_NAME> --cors-file=cors.json` 套用 CORS 配置。
