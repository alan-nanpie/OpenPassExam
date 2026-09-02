# 機密管理規範 (Secrets Management)

> **AI Agent Target:** Definition of required API keys, secrets.json structure, and Google Secret Manager integration.
> **Human Target:** 如何安全管理 API 金鑰、服務帳戶與機密資訊。

## 1. `secrets.json` 結構範本 (禁止提交至 Git)
```json
{
  "GEMINI_API_KEY": "AIzaSy...",
  "FIREBASE_API_KEY": "AIzaSy...",
  "FIREBASE_PROJECT_ID": "passexam-production",
  "FIREBASE_DATABASE_URL": "https://passexam-production-default-rtdb.firebaseio.com",
  "GCS_RAG_BUCKET": "passexam-rag-knowledge",
  "ADMOB_APP_ID_ANDROID": "ca-app-pub-...",
  "ADMOB_BANNER_ID": "ca-app-pub-.../..."
}
```

## 2. Google Cloud Secret Manager 整合 (CI/CD 與 Cloud Functions)
- 透過 `gcloud secrets create` 建立金鑰。
- 在 Cloud Build 或 Cloud Run 中以環境變數形式安全掛載。
