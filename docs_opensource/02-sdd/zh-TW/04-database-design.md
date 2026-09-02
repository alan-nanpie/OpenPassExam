# 04. 資料庫設計 (Database Design)

## 1. Google Cloud 多層級架構
PassExam 資料庫架構由 Google Cloud 原生服務組成：
1. **Google Cloud Firestore**: 儲存 18+ 科目考題文件、使用者作答歷程與錯題本。
2. **Firebase Realtime Database (RTDB)**: 提供輕量級 `approvedKeys` 布林索引與 `ai_model_config` 全域廣播。
3. **Google Cloud Storage (GCS)**: 儲存 RAG 教科書切片與考題拓撲圖檔。
4. **Vertex AI Vector Search**: 支援 768 維度語意向量搜尋。

## 2. Cloud Firestore 集合結構
```text
exam_subjects/                     # 考科頂層集合
  ├── cisco-200-301/               # CCNA 核心科目
  │     └── questions/ {questionId}
  ├── cisco-300-410/               # CCNP ENARSI
  │     └── questions/ {questionId}
  └── cisco-350-401/               # CCNP ENCOR
        └── questions/ {questionId}

users/ {uid}                       # 使用者資料夾
  ├── profiles/ {profileDoc}
  └── exam_sessions/ {sessionId}
```

## 3. Firebase RTDB `approvedKeys` 索引設計
```json
{
  "approvedKeys": {
    "cisco-200-301": {
      "q_1001": true,
      "q_1002": true
    }
  },
  "ai_model_config": {
    "primary_model": "gemini-3.7-flash",
    "fallback_model": "gemini-2.5-flash",
    "temperature": 1.0,
    "max_tokens": 4096
  }
}
```
