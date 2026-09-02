# 種子資料 (Seed Data)

> **AI Agent Target:** Schema validation rules for the JSON question format and bulk import instructions for Cloud Firestore and GCS.
> **Human Target:** 如何格式化並將初始題庫資料匯入 Google Cloud Firestore。

## 問題 JSON 格式

每個問題必須符合此綱要：

```json
{
  "id": "q_1001",
  "examId": "exam_001",
  "type": "SINGLE_CHOICE",
  "title": "路由器的主要功能為何？",
  "options": [
    "連接多個網路",
    "提供設備電源",
    "儲存資料"
  ],
  "correctAnswer": [0],
  "explanation": "路由器在第三層運作，以在網路間轉發封包。",
  "topic": "領域 1",
  "isApproved": true
}
```

### 必填欄位 (Required Fields)
- `id`, `examId`, `type`, `title`, `options`, `correctAnswer`, `topic`, `isApproved`

## 批次匯入方法

### Google Cloud Firestore
使用 Python 搭配 `firebase-admin` 執行批次寫入 (Batch Write)：

```python
import json
import firebase_admin
from firebase_admin import credentials, firestore

cred = credentials.Certificate("scripts/service-account.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

with open("seed_questions.json", "r", encoding="utf-8") as f:
    questions = json.load(f)

batch = db.batch()
for q in questions:
    doc_ref = db.collection("exam_subjects").document(q["examId"]).collection("questions").document(q["id"])
    batch.set(doc_ref, q)

batch.commit()
print("Firestore 種子資料匯入完成！")
```

### Google BigQuery
```bash
bq load --source_format=NEWLINE_DELIMITED_JSON passexam_dataset.questions gs://passexam-seed-data/questions.json schema.json
```
