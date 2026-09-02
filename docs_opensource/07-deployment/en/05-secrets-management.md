# Secrets Management

> **AI Agent Target:** Definition of required API keys, secrets.json structure, and Google Secret Manager integration.
> **Human Target:** Guidelines for managing credentials and secrets securely.

## 1. `secrets.json` Template (Never commit to Git)
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

## 2. Google Cloud Secret Manager Integration
- Store secrets centrally via `gcloud secrets create`.
- Mount secrets into Google Cloud Build and Cloud Functions pipelines.
